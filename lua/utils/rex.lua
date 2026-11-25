-- Inside Rex, each nvim listens on a socket named after its pane, so the
-- yazi pane (rex/init.lua's open_in_editor, scripts/rex-open) can find the
-- nvims in its tab and hand them files.
local M = {}

-- scripts/rex-open builds the same path; keep the two in step. Under ~/.cache
-- rather than $TMPDIR, whose length leaves no room under macOS's 104-byte
-- socket path limit.
function M.socket(block)
  return vim.fs.joinpath(vim.env.HOME, ".cache", "rex-nvim", block:gsub("^block:", "") .. ".sock")
end

function M.setup()
  local block = vim.env.REX_BLOCK
  if not block then
    return
  end
  local path = M.socket(block)
  if vim.uv.fs_stat(path) then
    -- An nvim further out in this pane (this one runs in its :terminal)
    -- keeps it; a dead one's leftover is cleared
    local ok, chan = pcall(vim.fn.sockconnect, "pipe", path, { rpc = true })
    if ok and chan > 0 then
      vim.fn.chanclose(chan)
      return
    end
    os.remove(path)
  end
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  pcall(vim.fn.serverstart, path)
end

-- Called by scripts/rex-open over --remote-expr. Deferred so the window
-- changes happen outside the expression's evaluation.
function M.open_files(cmd, files)
  vim.schedule(function()
    for _, file in ipairs(files) do
      vim.cmd[cmd](vim.fn.fnameescape(file))
    end
  end)
  return ""
end

return M

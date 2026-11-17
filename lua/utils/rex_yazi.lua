-- yazi in a floating Rex pane instead of yazi.nvim's embedded terminal.
-- The pane runs a real yazi with NVIM_SERVER pointing back here; its edit
-- opener and <C-v>/<C-x>/<C-t> go through scripts/nvim-remote, which
-- calls open_files() below and quits yazi, closing the pane.
local M = {}

local function rex_bin()
  return vim.env.REX_BIN_DIR .. "/rex"
end

local function rex(args, stdin)
  vim.system(vim.list_extend({ rex_bin() }, args), { stdin = stdin, text = true }, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        vim.notify("rex " .. args[1] .. ": " .. vim.trim(res.stderr), vim.log.levels.ERROR)
      end)
    end
  end)
end

-- Only inside a Rex terminal; elsewhere the callers fall back to yazi.nvim
function M.available()
  return vim.env.REX_SESSION ~= nil and vim.env.REX_BIN_DIR ~= nil
end

-- The Rex tab holding this nvim, so yazi floats over it even if another
-- tab is the active one
local function window_id()
  local res = vim.system({ rex_bin(), "block", "inspect", vim.env.REX_BLOCK, "--json" }):wait()
  local ok, info = pcall(vim.json.decode, res.stdout)
  return ok and info.block.window_id or nil
end

-- Opens yazi on path (a file is revealed, a directory entered)
function M.open(path)
  local layer = {
    session_id = vim.env.REX_SESSION,
    window_id = window_id(),
    bounds = { 0.05, 0.05, 0.9, 0.9 },
    focus = true,
    layout = {
      block = {
        flavor = "com.superlogical.terminal.shell",
        label = "yazi",
        options = {
          -- Hand focus back to nvim before the pane closes, however yazi
          -- exits; left to itself Rex may pick a neighbouring split
          command = {
            "env", "NVIM_SERVER=" .. vim.v.servername,
            "sh", "-c", 'yazi "$1"; "$2" focus -s "$3" "$4" >/dev/null',
            "sh", path, rex_bin(), vim.env.REX_SESSION, vim.env.REX_BLOCK,
          },
          cwd = vim.fn.getcwd(),
        },
      },
    },
  }
  rex({ "api", "call", "-s", vim.env.REX_SESSION, "session.new_layer", "-" }, vim.json.encode(layer))
end

function M.open_current_file()
  local file = vim.fn.expand("%:p")
  M.open(vim.uv.fs_stat(file) and file or vim.fn.getcwd())
end

-- Called by scripts/nvim-remote over --remote-expr. Deferred so the
-- window changes happen outside the expression's evaluation.
function M.open_files(cmd, files)
  vim.schedule(function()
    for _, file in ipairs(files) do
      vim.cmd[cmd](vim.fn.fnameescape(file))
    end
  end)
  return ""
end

return M

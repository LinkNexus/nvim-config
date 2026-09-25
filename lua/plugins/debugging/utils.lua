local M = {}

function M.get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
  local args_str = type(args) == "table" and table.concat(args, " ") or args

  config = vim.deepcopy(config)
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str))
    return require("dap.utils").splitstr(new_args)
  end

  return config
end

--- Collect every breakpoint currently set, as quickfix-shaped items.
--- Only buffers loaded in this session are known to nvim-dap, so breakpoints
--- in files that were closed since being set will not appear here.
function M.get_breakpoints()
  local ok, breakpoints = pcall(require, "dap.breakpoints")
  if not ok then
    return {}
  end

  local items = {}

  for bufnr, buf_breakpoints in pairs(breakpoints.get()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      local name = vim.api.nvim_buf_get_name(bufnr)

      for _, bp in ipairs(buf_breakpoints) do
        local line = vim.api.nvim_buf_get_lines(bufnr, bp.line - 1, bp.line, false)[1] or ""
        local marks = {}

        if bp.condition then
          table.insert(marks, "cond: " .. bp.condition)
        end
        if bp.hitCondition then
          table.insert(marks, "hits: " .. bp.hitCondition)
        end
        if bp.logMessage then
          table.insert(marks, "log: " .. bp.logMessage)
        end

        local text = vim.trim(line)
        if #marks > 0 then
          text = text .. "  [" .. table.concat(marks, ", ") .. "]"
        end

        table.insert(items, {
          bufnr = bufnr,
          filename = name ~= "" and name or nil,
          lnum = bp.line,
          col = 1,
          text = text,
        })
      end
    end
  end

  table.sort(items, function(a, b)
    local a_name, b_name = a.filename or "", b.filename or ""
    if a_name == b_name then
      return a.lnum < b.lnum
    end
    return a_name < b_name
  end)

  return items
end

--- Send all breakpoints to the quickfix list and open it.
function M.list_breakpoints()
  local items = M.get_breakpoints()

  if vim.tbl_isempty(items) then
    vim.notify("No breakpoints set", vim.log.levels.INFO)
    return
  end

  vim.fn.setqflist({}, " ", { title = "DAP Breakpoints", items = items })
  vim.cmd("copen")
end

--- Browse breakpoints in fzf-lua, falling back to the quickfix list.
function M.pick_breakpoints()
  local ok_fzf, fzf = pcall(require, "fzf-lua")

  if ok_fzf and fzf.dap_breakpoints then
    fzf.dap_breakpoints()
    return
  end

  M.list_breakpoints()
end

function M.get_mason_adapter(executable_name)
  local system_path = vim.fn.exepath(executable_name)

  if system_path ~= "" then
    return system_path
  end

  local ok_registry, mr = pcall(require, "mason-registry")

  if ok_registry and mr.is_installed(executable_name) then
    local mason_shim = vim.fn.stdpath("data") .. "/mason/bin/" .. executable_name

    if vim.fn.executable(mason_shim) == 1 then
      return mason_shim
    end
  end

  return executable_name
end

return M

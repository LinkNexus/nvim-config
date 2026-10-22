return {
  {
    "nvim-mini/mini.nvim",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    version = "*",
    config = function()
      require("mini.cmdline").setup()

      require("mini.pairs").setup({
        modes = { insert = true, command = true, terminal = false },
        skip_next = [=[[%w%%%'%[%%"%.%`%$]]=],
        skip_ts = { "string" },
        skip_unbalanced = true,
        markdown = true,
      })

      local MiniAi = require("mini.ai")

      MiniAi.setup({
        n_lines = 500,
        custom_textobjects = {
          o = MiniAi.gen_spec.treesitter({
            a = {
              "@block.outer",
              "@conditional.outer",
              "@loop.outer",
            },
            i = {
              "@block.inner",
              "@conditional.inner",
              "@loop.inner",
            },
          }),
          f = MiniAi.gen_spec.treesitter({
            a = "@function.outer",
            i = "@function.inner",
          }),
          c = MiniAi.gen_spec.treesitter({
            a = "@class.outer",
            i = "@class.inner",
          }),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
          e = {
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },
          g = function()
            local from = { line = 1, col = 1 }
            local to = { line = vim.fn.line("$"), col = vim.fn.getline("$"):len() }
            return { from = from, to = to }
          end,
          u = MiniAi.gen_spec.function_call(),
          U = MiniAi.gen_spec.function_call({ name_pattern = "[%w_]" }),
        },
      })
    end,
  },
}

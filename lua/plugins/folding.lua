return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    -- foldcolumn/foldlevel/foldlevelstart/foldenable are set globally in
    -- core/options.lua. ufo owns foldmethod/foldexpr itself once set up
    -- (that's how it renders fold preview/virtual text) -- previously
    -- plugins/lsp/attach.lua set foldexpr to the native
    -- `v:lua.vim.lsp.foldexpr()` per LSP-capable buffer, which would have
    -- fought ufo for control of the same option, so that block was
    -- removed in favor of this provider chain instead.
    opts = {
      -- ufo only accepts a 2-slot {main, fallback} combo (confirmed live
      -- -- a 3-item list throws at runtime), so the LSP tier has to be
      -- conditional on the buffer actually having a client that supports
      -- textDocument/foldingRange, with treesitter as fallback either way.
      provider_selector = function(bufnr, _, _)
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
          if client:supports_method("textDocument/foldingRange") then
            return { "lsp", "treesitter" }
          end
        end
        return { "treesitter", "indent" }
      end,
    },
    keys = {
      { "zR", function() require("ufo").openAllFolds() end,           desc = "Open all folds" },
      { "zM", function() require("ufo").closeAllFolds() end,          desc = "Close all folds" },
      { "zr", function() require("ufo").openFoldsExceptKinds() end,   desc = "Open folds except kinds" },
      { "zm", function() require("ufo").closeFoldsWith() end,         desc = "Close folds with level" },
      {
        "zK",
        function()
          -- Falls back to LSP hover when the cursor isn't over a fold,
          -- so this chord stays useful everywhere rather than needing a
          -- separate binding just for the no-fold case.
          local winid = require("ufo").peekFoldedLinesUnderCursor()
          if not winid then
            vim.lsp.buf.hover()
          end
        end,
        desc = "Peek fold (or hover)",
      },
    },
  },
}

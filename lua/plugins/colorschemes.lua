return {
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    opts = {
      options = {
        transparent = true,
        styles = {
          -- comments = "italic",
          constants = "bold",
          -- keywords = "italic",
          types = "bold",
          -- strings = "italic",
          functions = "bold",
          -- conditionals = "italic",
        },
      },
      groups = {
        all = {
          CursorLine = { bg = "palette.bg2" },
          CursorLineNr = { bg = "palette.bg2", fg = "palette.yellow" },

          TreesitterContext = { bg = "palette.bg1" },
          TreesitterContextLineNumber = { bg = "palette.bg1", fg = "palette.fg3" },
          TreesitterContextSeparator = { fg = "palette.bg2" },
          TreesitterContextBottom = { sp = "palette.bg2", style = "underline" },

          StatusLine = { bg = "palette.bg1", fg = "palette.fg1" },
          StatusLineNC = { bg = "palette.bg1", fg = "palette.fg3" },

          Pmenu = { bg = "palette.bg2", },

          Visual = { bg = "palette.bg2", }
        },
      },
    },
  },
}

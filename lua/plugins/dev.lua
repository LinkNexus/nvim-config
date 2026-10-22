return {
  {
    "DrKJeff16/wezterm-types",
    version = false,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "wezterm-types",      mods = { "wezterm" } },
      },
      enabled = function(root_dir)
        return (not vim.uv.fs_stat(root_dir .. "/.luarc.json"))
            and (vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled)
      end,
    },
  },
  {
    -- Re-evaluates a directory's .envrc from inside a running Neovim.
    --
    -- Launching nvim from within a project already inherits the devShell
    -- direnv loaded in the shell -- child processes inherit the parent's
    -- environment, so LSPs and :! commands get the project's toolchain
    -- for free. This only covers the cases that inheritance cannot,
    -- because the environment is otherwise frozen at startup:
    --   - one session spanning two projects, where an LSP started for a
    --     file in the second runs with the first one's PATH
    --   - nvim started outside any project, which gets only the global
    --     baseline toolchain
    --   - a project's flake edited while nvim is still open
    --
    -- An .envrc still has to be `direnv allow`ed; this does not bypass
    -- that, it just reacts to one that is already trusted.
    --
    -- The export is asynchronous: after a :cd the new PATH lands a moment
    -- later, not on the same tick. Worth knowing when something reads the
    -- environment immediately after changing directory.
    --
    -- Left noisy on purpose. g:direnv_silent_load = 1 would suppress the
    -- (very long) "direnv: export +AR +AS ..." line it prints on every
    -- DirChanged, but it gates the plugin's whole stderr relay, so it
    -- would also swallow ".envrc is blocked. Run `direnv allow`" and any
    -- nix evaluation error -- i.e. exactly the messages that explain why
    -- the toolchain is not what you expected. With one nvim per project
    -- DirChanged rarely fires anyway, so the noise costs little and the
    -- visibility is worth keeping.
    "direnv/direnv.vim",
  },
  {
    "nvim-lua/plenary.nvim",
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      ---@module "ibl"
      ---@type ibl.config
      local opts = {
        indent = {
          char = require("ibl.utils").get_listchars(0).space_char,
        },
        scope = {
          enabled = true,
          char = "▎",
        },
        whitespace = {
          remove_blankline_trail = true
        }
      }

      require("ibl").setup(opts)
    end
  },
  {
    'stevearc/overseer.nvim',
    ---@module 'overseer'
    ---@type overseer.SetupOpts
    opts = {},
  },
  {
    "zbirenbaum/copilot.lua",
    dependencies = {
      "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
    },
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        nes = {
          enabled = false
        }
      })
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    version = "^1948B6-8B13.0.0",
    opts = {
      log_level = "DEBUG",
      interactions = {
        chat = {
          adapter = "copilot_acp"
        },
        cli = {
          agent = "copilot",
          agents = {
            copilot = {
              cmd = "copilot",
              args = {},
              description = "Code Companion CLI using Copilot",
              provider = "terminal"
            }
          }
        }
      }
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function(_, opts)
      require("codecompanion").setup(opts)
    end,
  },
  {
    "NeogitOrg/neogit",
    lazy = true,
    dependencies = {
      "sindrets/diffview.nvim", -- optional
      "m00qek/baleia.nvim",     -- optional
      "ibhagwan/fzf-lua",       -- optional
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gU", "<cmd>Neogit<cr>", desc = "Show Neogit UI" }
    }
  },
  {
    'Bekaboo/dropbar.nvim',
    -- optional, but required for fuzzy finder support
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make'
    },
    config = function()
      local dropbar_api = require('dropbar.api')
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end
  }
}

return {
  {
    "bluz71/vim-nightfly-guicolors",
    priority = 1000,
    config = function()
      vim.g.nightflyItalics = true
      vim.g.nightflyCursorColor = true
      vim.g.nightflyNormalFloat = true
      vim.g.nightflyWinSeparator = 2
    end,
  },
  {
    "folke/tokyonight.nvim",
  },
  {
    "catppuccin/nvim",
    config = function ()
        require("catppuccin").setup({
            flavour = "frappe", -- latte, frappe, macchiato, mocha
            background = { -- :h background
                light = "frappe",
                dark = "mocha",
            },
            transparent_background = false, -- disables setting the background color.
            show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
            term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
            dim_inactive = {
                enabled = false, -- dims the background color of inactive window
                shade = "dark",
                percentage = 0.15, -- percentage of the shade to apply to the inactive window
            },
            no_italic = false, -- Force no italic
            no_bold = false, -- Force no bold
            no_underline = false, -- Force no underline
            styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
                comments = { "italic" }, -- Change the style of comments
                conditionals = { "italic" },
                loops = {},
                functions = {},
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
                operators = {},
                -- miscs = {}, -- Uncomment to turn off hard-coded styles
            },
            color_overrides = {},
            custom_highlights = {},
            default_integrations = true,
            integrations = {
                cmp = true,
                gitsigns = true,
                neotree = false,
                treesitter = true,
                notify = false,
                mini = {
                    enabled = true,
                    indentscope_color = "",
                },
                -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
            },
        })
    end
  },

  {
    "rebelot/kanagawa.nvim",
  },

  {
    "ellisonleao/gruvbox.nvim",
  },

  {
    "bluz71/vim-moonfly-colors",
  },

  {
    "rmehri01/onenord.nvim",
  },

  {
    "Shatur/neovim-ayu",
  },

  {
    "craftzdog/solarized-osaka.nvim",
  },
}

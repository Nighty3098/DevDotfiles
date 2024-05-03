return {
  {
    "drewtempelmeyer/palenight.vim",
  },

  {
    "bluz71/vim-nightfly-guicolors",
    priority = 1000,
    config = function()
      vim.g.nightflyItalics = true
      vim.g.nightflyCursorColor = true
      vim.g.nightflyNormalFloat = true
      vim.g.nightflyWinSeparator = 2
      vim.cmd([[colorscheme nightfly]])
    end,
  },
  {
    "folke/tokyonight.nvim",
    config = function()
      --      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },
  {
    "catppuccin/nvim",
    config = function()
      --  vim.cmd([[colorscheme catppuccin-macchiato]])
    end,
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
    "connorholyday/vim-snazzy",
  },

  {
    "rmehri01/onenord.nvim",
  },

  {
    "Shatur/neovim-ayu",
  },

  {
    "craftzdog/solarized-osaka.nvim",
    priority = 1000,
    config = function()
      -- Themery block
      -- This block will be replaced by Themery.
      -- vim.cmd("colorscheme solarized-osaka-night")
      vim.g.theme_id = 12
      -- end themery block
    end,
  },
}

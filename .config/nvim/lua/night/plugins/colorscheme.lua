return {
  {
    "bluz71/vim-nightfly-guicolors",
    priority = 1000,
    config = function()
      --      vim.cmd([[colorscheme nightfly]])
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
    "craftzdog/solarized-osaka.nvim",
    priority = 1000,
    config = function()
      -- Themery block
-- This block will be replaced by Themery.
vim.cmd("colorscheme nightfly")
vim.g.theme_id = 1
-- end themery block
    end,
  },
}

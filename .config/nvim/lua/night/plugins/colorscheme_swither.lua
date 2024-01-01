return {
  "zaldih/themery.nvim",
  config = function()
    -- Minimal config
    require("themery").setup({
      themes = {
        "nightfly",
        "tokyonight-night",
        "tokyonight-storm",
        "tokyonight-moon",
        "tokyonight-day",
        "catppuccin-macchiato",
        "catppuccin-mocha",
        "catppuccin-frappe",
        "kanagawa-dragon",
        "kanagawa-wave",
        "kanagawa-lotus",
        "solarized-osaka",
        "solarized-osaka-day",
        "solarized-osaka-moon",
        "gruvbox",
        "ayu-dark",
        "ayu-light",
        "ayu-mirage",
        "moonfly",
        "onenord",
        "onenord-light",
      }, -- Your list of installed colorschemes
      themeConfigFile = "~/.config/nvim/lua/night/plugins/colorscheme.lua", -- Described below
      livePreview = true, -- Apply theme while browsing. Default to true.
    })
  end,
}

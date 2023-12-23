return {
  "zaldih/themery.nvim",
  config = function()
    -- Minimal config
    require("themery").setup({
      themes = {
        "nightfly",
        "tokyonight-night",
        "catppuccin-macchiato",
        "catppuccin-mocha",
        "catppuccin-frappe",
        "kanagawa-dragon",
        "solarized-osaka",
        "solarized-osaka-day",
      }, -- Your list of installed colorschemes
      themeConfigFile = "~/.config/nvim/lua/night/plugins/colorscheme.lua", -- Described below
      livePreview = true, -- Apply theme while browsing. Default to true.
    })
  end,
}

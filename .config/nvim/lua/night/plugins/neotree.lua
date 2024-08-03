return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim",
    },
    config = function()

        require("neo-tree").setup({
            source_selector = {
                winbar = false,
                statusline = false
            },
            popup_border_style = "rounded",
            enable_git_status = false,
            enable_diagnostics = true,
        })
    end,
}
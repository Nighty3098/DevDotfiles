return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "arkav/lualine-lsp-progress" },
    config = function()
        local lualine = require("lualine")
        local lazy_status = require("lazy.status") -- to configure lazy pending updates count

        lualine.setup({
            options = {
                theme = "auto",
                component_separators = " ",
                section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_a = {
                    { "mode", separator = { left = "", right = "" }, right_padding = 0 },
                },

                lualine_b = { "filename", "branch", "diff"},
                lualine_c = {  },
                lualine_x = {  },
                lualine_y = { "filesize", "encoding", "diagnostics" },
                lualine_z = {
                    { "location", separator = { right = "", left = "" }, left_padding = 00 },
                },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            extensions = {},
        })
    end,
}

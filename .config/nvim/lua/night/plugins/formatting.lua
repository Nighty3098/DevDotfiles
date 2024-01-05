return {
    "stevearc/conform.nvim",
    config = function()
        require("conform").setup({
            logging = false,
            preferences = {
                disable = false,
                -- configuration
            },
            source = {
                path = ".",
                max_lines = 1000,
                max_indent_level = 4,
                -- file types to exclude from formatting
                exclude_file_types = {
                    "TelescopePrompt",
                    "packer",
                    "Conform",
                },
                -- function to execute after formatting, with filename as argument
                post_format_hook = function(file) end,
            },
            config = {
                indent = {
                    width = 4,
                    -- tabs are used instead of spaces if true, otherwise spaces are used
                    use_tabs = true,
                    tab_width = 4,
                },
                end_of_line = {
                    eol = "lf", -- or 'crlf'
                    fix_by_file_format = true,
                },
                charset = {
                    encode = "utf-8",
                    fix_by_file_format = true,
                },
                trim_whitespace = true,
                insert_final_newline = true,
            },
        })
    end
}


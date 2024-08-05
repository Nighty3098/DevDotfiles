return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "arkav/lualine-lsp-progress" },
    config = function()
        local lualine = require("lualine")
        local lazy_status = require("lazy.status") -- to configure lazy pending updates count

        local attached_clients = {
            get_attached_clients,
            color = {
                gui = "bold"
            }
        }

        lualine.setup({
            options = {
                theme = "auto",
                component_separators = " ",
                globalstatus = true,
                section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_a = {
                    {
                      "mode",
                      fmt = function(str)
                        if str == "" then
                          mode_width = 0
                          return ""
                        end
                        mode_width = #str + 2 -- 2 is the length of padding
                        return str
                      end,
                    },
                  },
                  lualine_b = {
                    {
                      "branch",
                      icon = "",
                      cond = function()
                        local should_show = vim.opt.columns:get() > 60
                        if not should_show then
                          branch_width = 0
                        end
                        return should_show
                      end,
                      fmt = function(str)
                        if str == "" then
                          branch_width = 0
                          return ""
                        end
                        branch_width = #str + 2 + 2 -- 4 is the length of icon (unicode), 2 is the length of padding
                        return str
                      end,
                    },
                    { "diff", colored = true, symbols = { added = " ", modified = " ", removed = " " } },
                    {
                      "diff",
                      cond = function()
                        local should_show = vim.opt.columns:get() > 60
                        if not should_show then
                          diff_width = 0
                        end
                        return should_show
                      end,
                      fmt = function(str)
                        if str == "" then
                          diff_width = 0
                          return ""
                        end
                        local evaled_str = vim.api.nvim_eval_statusline(str, {}).str
                        diff_width = #evaled_str + 2 -- 2 is the length of padding
                        return str
                      end,
                    },
                  },
                  lualine_c = {
                    {
                      -- fill space to center the filetype + filename
                      function()
                        local used_space = mode_width + branch_width + diff_width
                        local win_width = vim.opt.columns:get()
                        local fill_space = string.rep(" ", math.floor((win_width - filename_width - filetype_width) / 2) - used_space)
                        return fill_space
                      end,
                      padding = { left = 0, right = 0 },
                      cond = function()
                        return vim.opt.columns:get() > 60
                      end,
                    },
                    {
                      "filetype",
                      fmt = function(str)
                        if str == "" then
                          filetype_width = 0
                          return ""
                        end
                        filetype_width = 1 + 2 -- 4 is the length of icon (unicode), 2 is the length of padding
                        return str
                      end,
                      icon_only = true,
                    },
                    {
                      "filename",
                      fmt = function(filename)
                        if filename == "" then
                          filename_width = 0
                          return ""
                        end
                
                        local used_space = mode_width + branch_width + diff_width
                        local win_width = vim.opt.columns:get()
                        local free_space = (math.floor(win_width / 2) - used_space) * 2
                
                        -- if the filename is longer than the free space, use the filename
                        if free_space < #filename + filetype_width + 10 then
                          filename = vim.fn.expand("%:t")
                        end
                
                        -- if the filename is still longer than the free space, cut the filename
                        if free_space < #filename + filetype_width + 10 then
                          local end_idx = free_space - filetype_width - 13
                          if end_idx < 0 then
                            return ""
                          end
                          filename = string.sub(filename, 1, end_idx) .. "..."
                        end
                
                        filename_width = #filename + 2 -- 2 is the length of padding
                
                        return filename
                      end,
                      file_status = true, -- Displays file status (readonly status, modified status)
                      newfile_status = false, -- Display new file status (new file means no write after created)
                      path = 1, -- 0: Just the filename
                      -- 1: Relative path
                      -- 2: Absolute path
                      -- 3: Absolute path, with tilde as the home directory
                      -- 4: Filename and parent dir, with tilde as the home directory
                
                      shorting_target = 0, -- Shortens path to leave 40 spaces in the window for other components. (terrible name, any suggestions?)
                
                      symbols = {
                        modified = "[+]", -- Text to show when the file is modified.
                        readonly = "[-]", -- Text to show when the file is non-modifiable or readonly.
                        unnamed = "[No Name]", -- Text to show for unnamed buffers.
                        newfile = "[New]", -- Text to show for newly created file before first write
                      },
                    },
                  },
                  lualine_x = {
                    { "diagnostics" },
                    {
                      "copilot",
                      show_colors = false,
                      symbols = {
                        status = {
                          icons = {
                            enabled = " ",
                            sleep = " ", -- auto-trigger disabled
                            disabled = " ",
                            warning = " ",
                            -- unknown = " ",
                            unknown = "",
                          },
                        },
                      },
                      show_loading = false,
                    },
                    {
                      function()
                        local autoformat = require("plugins.formatting.autoformat").autoformat
                        return autoformat and "󰚔 on" or "󰚔 off"
                      end,
                    },
                  },
                  lualine_y = {
                    {
                      "encoding",
                      cond = function()
                        return vim.opt.columns:get() > 80
                      end,
                    },
                  },
                  lualine_z = {
                    {
                      "location",
                      padding = { left = 1, right = 0 },
                    },
                    "progress",
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
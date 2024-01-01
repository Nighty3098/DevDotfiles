return {
  "rcarriga/nvim-notify",
  lazy = true,
  config = function(_, opts)
    local notify = require("notify")
    notify.setup(opts)
    vim.notify = notify
  end,
  opts = {
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { zindex = 175 })
      if not vim.g.ui_notifications_enabled then
        vim.api.nvim_win_close(win, true)
      end
      if not package.loaded["nvim-treesitter"] then
        pcall(require, "nvim-treesitter")
      end
      vim.wo[win].conceallevel = 3
      local buf = vim.api.nvim_win_get_buf(win)
      if not pcall(vim.treesitter.start, buf, "markdown") then
        vim.bo[buf].syntax = "markdown"
      end
      vim.wo[win].spell = false
    end,
  },
}

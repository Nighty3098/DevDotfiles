return {
  "echasnovski/mini.bracketed",
  event = "BufReadPost",
  config = function()
    local bracketed = require("mini.bracketed")
    bracketed.setup({
      file = { suffix = "" },
      window = { suffix = "" },
      quickfix = { suffix = "" },
      yank = { suffix = "" },
      treesitter = { suffix = "n" },
    })
  end,
}

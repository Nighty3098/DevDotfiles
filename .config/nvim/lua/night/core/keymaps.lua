-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>")

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>") -- increment
keymap.set("n", "<leader>-", "<C-x>") -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally

keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>cs", ":close<CR>") -- close current split window

keymap.set("n", "<leader>nt", ":tabnew<CR>") -- open new tab
keymap.set("n", "<C-q>", ":BufferClose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab

----------------------
-- Plugin Keybinds
----------------------
keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references
keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration
keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions
keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations
keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions
keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection
keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename
keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file
keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line
keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer
keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer
keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor
keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

-- zen mode
keymap.set("n", "<leader>zm", ":ZenMode<CR>")

keymap.set("n", "<A-1>", ":BufferGoto 1<CR>")
keymap.set("n", "<A-2>", ":BufferGoto 2<CR>")
keymap.set("n", "<A-3>", ":BufferGoto 3<CR>")
keymap.set("n", "<A-4>", ":BufferGoto 4<CR>")
keymap.set("n", "<A-5>", ":BufferGoto 5<CR>")
keymap.set("n", "<A-6>", ":BufferGoto 6<CR>")
keymap.set("n", "<A-7>", ":BufferGoto 7<CR>")
keymap.set("n", "<A-8>", ":BufferGoto 8<CR>")
keymap.set("n", "<A-9>", ":BufferGoto 9<CR>")
keymap.set("n", "<A-0>", ":BufferGoto 0<CR>")

-- vim-maximizer
keymap.set("n", "<leader>mt", ":MaximizerToggle<CR>") -- toggle split window maximization

-- FOR NEO TREE
keymap.set("n", "<leader>e", ":Neotree left<CR>") -- toggle file explorer
keymap.set("n", "<leader>ef", ":Neotree float<CR>")
keymap.set("n", "<leader>ec", ":Neotree close<CR>")
keymap.set("n", "<leader>ee", ":Neotree float git_status git_base=main<CR>")

-- tagbar
keymap.set("n", "<leader>t", ":TagbarToggle<CR>")

-- terminal
keymap.set("n", "<leader>ot", ":terminal<CR>")

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fw", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags

-- telescope git commands
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout) ["gc" for git commits]
keymap.set("n", "<leader>gbc", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout) ["gb" for git branch]
keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>") -- list current changes per file with diff preview ["gs" for git status]

-- restart lsp server 
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary

keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory

keymap.set(
    "n",
    "<leader>hm",
    "<cmd>lua require('harpoon.mark').add_file()<cr>",
    { desc = "Mark file with harpoon" }
)
keymap.set("n", "<leader>hn", "<cmd>lua require('harpoon.ui').nav_next()<cr>", { desc = "Go to next harpoon mark" })
keymap.set(
    "n",
    "<leader>hp" ,
    "<cmd>lua require('harpoon.ui').nav_prev()<cr>",
    { desc = "Go to previous harpoon mark" }
)

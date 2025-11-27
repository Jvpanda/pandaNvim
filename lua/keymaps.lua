-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

--Exits Insert mode another way
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode shortcut" })
vim.keymap.set("i", "JJ", "<Esc>", { desc = "Exit insert mode shortcut" })

--Remaps jumps to also center screen
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Jump a half page down and reset cursor to middle" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Jump a half page up and reset cursor to middle" })

-- Keybinds to make split navigation easier.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- [[ Simple Custom Keybinds]]
-- development
vim.keymap.set("n", "<leader>x", ":w<CR>:source %<CR>", { noremap = true, desc = "Saves then runs current file" })

-- line numbers for school
vim.keymap.set("n", "<leader>pp", function()
    vim.cmd "%s/^/\\=line('.').\". \""
    vim.cmd "nohlsearch"
end, { desc = "Create line numbers in Text" })

--Open explorer on the current directory
vim.keymap.set("n", "<leader>pa", function()
    local filepath = vim.fn.expand "%:p:h"
    vim.fn.system("start " .. filepath)
end, { desc = "Open Current Window in Explorer" })

-- Open parent directory in current window
vim.keymap.set("n", "<space>p-", "<CMD>Oil<CR>", { desc = "Open parent directory in non floating window" })

-- Open parent directory in floating window
vim.keymap.set("n", "-", require("oil").toggle_float)
vim.keymap.set("n", "<space>ps", function()
    require("oil").toggle_float "~/Source/"
end, { desc = "Open Source Dir" })

-- [[Set current window to half the width of the screen]]
vim.keymap.set("n", "<leader>po", function()
    local width = math.floor(vim.o.columns * 0.5)
    vim.api.nvim_win_set_width(0, width)
end, { desc = "Set current window to hald the editor width" })

--Getting and clearing messages
vim.keymap.set("n", "<leader>pm", ":messages<CR>", { desc = "See messages" })
vim.keymap.set("n", "<leader>pn", function()
    vim.cmd.messages "clear"
end, { desc = "Clear messages" })

-- Inspect what's under the cursor
vim.keymap.set("n", "<leader>i", vim.show_pos, { desc = "Inspect whatever is under the cursor" })

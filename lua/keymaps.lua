-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--Exits Insert mode another way
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit insert mode shortcut' })
--Remaps jumps to also center screen
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Jump a half page down and reset cursor to middle' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Jump a half page up and reset cursor to middle' })

-- disbables arrows in normal mode with text
vim.keymap.set('i', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('i', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('i', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('i', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<F9>', ':!start nvim<CR>', { desc = 'Create new nvim window' })
vim.keymap.set('n', '<F10>', ':cd %:p:h<CR>', { desc = 'Changes directory to the one of the current editing file' })
vim.keymap.set('n', '<F11>', ':w<CR>:!g++ -g *.cpp -o "%:p:h\\main.exe"<CR>', { silent = true, desc = 'Build with c++' })
vim.keymap.set('n', '<F12>', ':cd %:p:h<CR> :vsplit<CR> :term cmd /C main.exe<CR>i', { silent = true, desc = 'Launches current main exe of current folder' })

vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>', { silent = true, noremap = true, desc = 'Toggles Undotree' })

vim.keymap.set('i', '{', '{<CR>}<C-[>k$a<CR>')

-- [[ Basic Autocommands ]]
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

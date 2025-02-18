-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--Exits Insert mode another way
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit insert mode shortcut' })
vim.keymap.set('i', 'JJ', '<Esc>', { desc = 'Exit insert mode shortcut' })

--Remaps jumps to also center screen
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Jump a half page down and reset cursor to middle' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Jump a half page up and reset cursor to middle' })

-- disbables arrows in normal mode with text
vim.keymap.set({ 'i', 'n' }, '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set({ 'i', 'n' }, '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set({ 'i', 'n' }, '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set({ 'i', 'n' }, '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Undotree
vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>', { silent = true, noremap = true, desc = 'Toggles Undotree' })

-- [[ Simple Custom Keybinds]]
-- development
vim.keymap.set('n', '<leader>x', ':w<CR>:source %<CR>', { noremap = true, desc = 'Saves then runs current file' })
vim.keymap.set('n', '<leader>pz', function()
    vim.cmd.suspend()
end, { noremap = true, desc = 'Suspends current nvim instance' })

-- line numbers for school
-- :%s/^/\=line('.').". "
vim.keymap.set('n', '<leader>p', '', { desc = 'Custom Commands' })
vim.keymap.set('n', '<leader>pp', function()
    vim.cmd '%s/^/\\=line(\'.\').". "'
    vim.cmd 'nohlsearch'
end, { desc = 'Create line numbers in Text' })

--Open explorer on the current directory
vim.keymap.set('n', '<leader>pa', function()
    local filepath = vim.fn.expand '%:p:h'
    vim.fn.system('start ' .. filepath)
end, { desc = 'Open Current Window in Explorer' })

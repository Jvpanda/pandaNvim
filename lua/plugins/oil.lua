return {
    {
        'stevearc/oil.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            CustomOilBar = function()
                local path = vim.fn.expand '%'
                path = path:gsub('oil://', '')

                return '  ' .. vim.fn.fnamemodify(path, ':.')
            end

            require('oil').setup {
                columns = { 'icon' },
                keymaps = {
                    ['<C-h>'] = false,
                    ['<C-l>'] = false,
                    ['<C-k>'] = false,
                    ['<C-j>'] = false,
                    ['<M-h>'] = 'actions.select_split',
                },
                win_options = {
                    winbar = '%{v:lua.CustomOilBar()}',
                },
                view_options = {
                    show_hidden = true,
                    is_always_hidden = function(name, _)
                        local folder_skip = { 'dev-tools.locks', 'dune.lock', '_build' }
                        return vim.tbl_contains(folder_skip, name)
                    end,
                },
                float = {
                    padding = 2,
                    max_width = 100,
                    max_height = 35,
                    border = 'rounded',
                    win_options = {
                        winblend = 0,
                        winbar = '%{v:lua.CustomOilBar()}',
                    },
                },
            }

            -- Open parent directory in current window
            vim.keymap.set('n', '<space>p-', '<CMD>Oil<CR>', { desc = 'Open parent directory in non floating window' })
            vim.keymap.set('n', '<space>ps', function()
                require('oil').toggle_float '~/source/'
            end, { desc = 'Open Source Dir' })

            -- Open parent directory in floating window
            vim.keymap.set('n', '-', require('oil').toggle_float)
        end,
    },
}

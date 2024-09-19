return
{
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    -- I MADE THIS CONFIG AND IM SO DAMN PROUD. I LEARNED THE DIFFERENCE BETWEEN OPTS AND CONFIG AND HOW TO MAKE A CUSTOM CONFIG THAT SUITED MY NEEDS. YES. FUCK YOU FUCK YES.
    config = function()
      require('nvim-treesitter.install').compilers = { 'zig' }
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
        auto_install = true,
        sync_install = false,
        ignore_install = {},
        modules = {},
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { 'ruby', 'c++' },
        },
        indent = { enable = true, disable = { 'ruby', 'c++' } },
      }
    end,
  },
}
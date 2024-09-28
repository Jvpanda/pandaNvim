return {
  {
    -- colorschemes, to see all telescope colorscheme
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme 'tokyonight'

      -- You can configure highlights by doing something like:
      vim.cmd.hi 'Comment gui=none'
      -- Set background to transparent
      vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
    end,
  },
}


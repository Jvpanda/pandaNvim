-- [[ Basic Autocommands ]]
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ My Commands ]]
-- Starts the godot server listener
vim.api.nvim_create_user_command('Godot', function(opts)
  if opts.args == 'start' then
    vim.fn.serverstart '127.0.0.1:6004'
    print 'Listen Server Started'
  elseif opts.args == 'stop' then
    vim.fn.serverstop '127.0.0.1:6004'
    print 'Listen Server Stopped'
  else
    print 'Please enter valid command'
  end
end, { nargs = 1 })

vim.api.nvim_create_user_command('GodotPassCMD', function(opts)
  local opt2Num = tonumber(opts.fargs[2]) + 1
  local opt3Num = tonumber(opts.fargs[3])

  if vim.fn.has 'win32' == 0 then
    local wslpath = vim.fn.system('wslpath ' .. opts.fargs[1])
    vim.cmd.n(wslpath)
    vim.api.nvim_win_set_cursor(0, { opt2Num, opt3Num })
  else
    vim.cmd.n(opts.fargs[1])
    vim.api.nvim_win_set_cursor(0, { opt2Num, opt3Num })
  end
end, { nargs = '*' })

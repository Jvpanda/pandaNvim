local terminal_creation = require "tools.environment_setup.terminal_creation"
local terminal_get = require "tools.environment_setup.get_user_terminal"
local M = { terminal = "", backup_terminal = "" }

M.setup_terminal_env = function()
    terminal_get.getTerminal(M)
end

M.run_command_on_terminal = function(command, terminal_layout, floating_opts)
    floating_opts = floating_opts or nil
    terminal_layout = terminal_layout or "external"

    local terminal = M.terminal
    if terminal == "" or terminal == nil then
        terminal = M.backup_terminal
    end

    terminal_creation.run_command_on_terminal(command, terminal, terminal_layout, floating_opts)
end

return M

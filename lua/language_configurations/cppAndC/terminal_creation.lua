local M = {}

local opts = require "language_configurations.cppAndC.general_opts"
local general = require "tools.general_functions"

M.create_terminal_from_type = function(filepath)
    if opts.runWindow == "floatingWindow" then
        local buf, win = general.create_floating_window(opts.vimFloatingWindowSize)
        vim.api.nvim_set_current_win(win)
        local jobid = vim.fn.jobstart(filepath, { term = true })
        general.setDelWinKeymapForBuffer()
    elseif opts.runWindow == "window" then
        vim.cmd "vsplit"
        vim.cmd.terminal(filepath)
        general.setDelWinKeymapForBuffer()
    elseif opts.runWindow == "external" then
        M.create_terminal_instance(filepath, false)
    elseif opts.runWindow == "external_permanent" then
        M.create_terminal_instance(filepath, true)
    end
end

M.create_terminal_instance = function(filepath, permanent)
    local terminalCommands = {
        gnome = {
            begin = [[gnome-terminal -- bash -ic ']],
            ending = [[; read -p "Press Enter to Exit"']],
            permanentEnding = [[;read -p "Press Enter to Exit";exec bash']],
        },
        xfce = {
            begin = [[xfce4-terminal -e "bash -ic ']],
            ending = [[;read -p \"Press Enter to Exit\"'"]],
            permanentEnding = [[;read -p \"Press Enter to Exit\";exec bash'"]],
        },
        tmux = {
            begin = [[tmux split-window -h -l 10 ']],
            ending = [[;read -p "Press Enter to Exit"']],
            permanentEnding = [[;read -p "Press Enter to Exit";exec bash']],
        },
        alacritty = {
            begin = [[alacritty -e bash -ic ']],
            ending = [[;read -p "Press Enter to Exit"']],
            permanentEnding = [[;read -p "Press Enter to Exit";exec bash']],
        },
    }

    local command = ""

    if not permanent then
        if general.isOnWindows() == true then
            command = "start " .. filepath
        elseif opts.terminal == "ghostty" then
            command = terminalCommands[opts.backupTerminal].begin .. filepath .. terminalCommands[opts.backupTerminal].ending
        else
            command = terminalCommands[opts.terminal].begin .. filepath .. terminalCommands[opts.terminal].ending
        end
    else
        if general.isOnWindows() == true then
            command = "!start cmd /k " .. filepath
        elseif opts.terminal == "ghostty" then
            command = terminalCommands[opts.backupTerminal].begin .. filepath .. terminalCommands[opts.backupTerminal].permanentEnding
        else
            command = terminalCommands[opts.terminal].begin .. filepath .. terminalCommands[opts.terminal].permanentEnding
        end
    end

    vim.fn.system(command)
end

return M

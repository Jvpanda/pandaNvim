local M = {}
local general = require "tools.general_functions"
local windowing = require "tools.ui.windowing"

M.run_command_on_terminal = function(command, terminal, terminal_layout, floating_opts)
    local floating_window_opts = floating_opts or nil

    if terminal_layout == "floatingWindow" then
        local buf, win = windowing.create_floating_window(floating_window_opts)
        vim.api.nvim_set_current_win(win)
        local jobid = vim.fn.jobstart(command, { term = true })
        vim.keymap.set({ "n" }, "<esc>", function()
            windowing.deleteCurrentWindow(true)
        end, { buffer = true })
    elseif terminal_layout == "window" then
        vim.cmd "vsplit"
        vim.cmd.terminal(command)
        vim.keymap.set({ "n" }, "<esc>", function()
            windowing.deleteCurrentWindow(true)
        end, { buffer = true })
    elseif terminal_layout == "external" then
        M.create_terminal_instance(command, terminal, false)
    elseif terminal_layout == "external_permanent" then
        M.create_terminal_instance(command, terminal, true)
    end
end

M.create_terminal_instance = function(command, terminal, permanent)
    local is_permanent = permanent or false

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

    if not is_permanent then
        if general.isOnWindows() == true then
            command = "start " .. command
        else
            command = terminalCommands[terminal].begin .. command .. terminalCommands[terminal].ending
        end
    else
        if general.isOnWindows() == true then
            command = "!start cmd /k " .. command
        else
            command = terminalCommands[terminal].begin .. command .. terminalCommands[terminal].permanentEnding
        end
    end

    vim.fn.system(command)
end

return M

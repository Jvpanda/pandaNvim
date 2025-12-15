local gdscript_setup = {}
local workspace_tracker = require "tools.workspace_tracker"
local general = require "tools.general_functions"

gdscript_setup.LSPSetup = function()
    vim.lsp.enable "gdscript"
    local cmd = vim.lsp.rpc.connect("127.0.0.1", 6005)

    vim.lsp.config("gdscript", {
        cmd = cmd,
        filetypes = { "gd", "gdscript", "gdscript3" },
        root_markers = { "project.godot", ".git" },
    })
end

-- Starts the godot server listener
gdscript_setup.startListenServerForFileJumps = function()
    local serverList = vim.fn.serverlist()

    for _, server in pairs(serverList) do
        if server == "127.0.0.1:6004" then
            return
        end
    end

    print "listen server started"
    vim.fn.serverstart "127.0.0.1:6004"
end

gdscript_setup.setupKeybinds = function()
    vim.keymap.set("n", "<F11>", function()
        if workspace_tracker.isWorkspaceSet() then
            local arguments = workspace_tracker.relativeWorkspacePath() .. vim.fn.expand "%:t:r" .. ".tscn"
            local command = [[!gnome-terminal -- bash -c "godot ]] .. arguments .. [[; read -p 'Press Enter to close...' "]]
            if general.isOnWindows() then
                command = "!start godot " .. arguments
            end
            vim.cmd(command)
            print "launched"
        else
            print "Please set home first"
        end
    end, { desc = "Launches Current Scene" })
    vim.keymap.set("n", "<F12>", function()
        if workspace_tracker.isWorkspaceSet() then
            local command = [[!gnome-terminal -- bash -c "godot; read -p 'Press Enter to close...' "]]
            if general.isOnWindows() then
                command = "!start godot "
            end
            vim.cmd(command)
        else
            print "Please set home first"
        end
    end, { desc = "Launces Main Scene" })
end

return gdscript_setup

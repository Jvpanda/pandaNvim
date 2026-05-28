local gdscript_setup = {}
local workspace_tracker = require "tools.workspace_tracker"
local general = require "tools.general_functions"
local dap = require "dap"

dap.adapters.godot = {
    type = "server",
    host = "127.0.0.1",
    port = 6006,
}

gdscript_setup.LSPSetup = function()
    vim.lsp.enable "gdscript"
    local cmd = vim.lsp.rpc.connect("127.0.0.1", 6005)

    vim.lsp.config("gdscript", {
        cmd = cmd,
        filetypes = { "gd", "gdscript", "gdscript3" },
        root_markers = { "project.godot", ".git" },
    })
end

dap.configurations.gdscript = {
    {
        name = "Launch Main scene",
        type = "godot",
        request = "launch",
        project = "${workspaceFolder}",
        scene = "main",
    },

    {
        name = "Launch Current scene",
        type = "godot",
        request = "launch",
        project = "${workspaceFolder}",
        scene = "current",
    },

    {
        name = "Launch Script scene",
        type = "godot",
        request = "launch",
        project = "${workspaceFolder}",
        scene = function()
            return vim.fn.expand "%:p:r" .. ".tscn"
        end,
    },
}

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
    require("language_configurations.cppAndC.keybinds").setupDapKeybinds()
    require("language_configurations.cppAndC.debug.debugMenu").cppSetupDapMenu()
    vim.keymap.set("n", "<F12>", function()
        dap.continue()
        require("dap-view").open()
    end)
end

return gdscript_setup

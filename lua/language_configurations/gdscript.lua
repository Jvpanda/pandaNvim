local gdscript_setup = {}

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

    for _, server in ipairs(serverList) do
        if server == "127.0.0.1:6004" then
            return
        end
    end

    vim.fn.serverstart "127.0.0.1:6004"
end

return gdscript_setup

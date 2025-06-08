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
gdscript_setup.createServerPassCommands = function()
    vim.api.nvim_create_user_command("Godot", function(opts)
        if opts.args == "start" then
            vim.fn.serverstart "127.0.0.1:6004"
            print "Listen Server For Pass Commands Started"
        elseif opts.args == "stop" then
            vim.fn.serverstop "127.0.0.1:6004"
            print "Listen Server Stopped"
        else
            print "Please enter valid command"
        end
    end, { nargs = 1 })

    vim.api.nvim_create_user_command("GodotPassCMD", function(opts)
        local opt2Num = tonumber(opts.fargs[2]) + 1
        local opt3Num = tonumber(opts.fargs[3])
        if vim.fn.has "win32" == 0 then
            local wslpath = vim.fn.system("wslpath " .. opts.fargs[1])
            vim.cmd.n(wslpath)
            vim.api.nvim_win_set_cursor(0, { opt2Num, opt3Num })
        else
            vim.cmd.n(opts.fargs[1])
            vim.api.nvim_win_set_cursor(0, { opt2Num, opt3Num })
        end
    end, { nargs = "*" })
end

--Dap Setup
gdscript_setup.dapSetup = function()
    local dap = require "dap"
    dap.adapters.godot = {
        type = "server",
        host = "127.0.0.1",
        port = 6006,
    }

    dap.configurations.gdscript = {
        {
            type = "godot",
            request = "launch", -- could be launch or attack
            name = "Launch Main Scene",
            --specific to gdscript
            --project = '${workspaceFolder}', dont need this
            launch_scene = true,
        },
    }
end

return gdscript_setup

local arduino_setup = {}
local workspace = require "tools.workspace_tracker"

--[[LSP Settings]]
arduino_setup.LSPSetup = function()
    vim.lsp.enable "arduino_language_server"
    vim.lsp.config("arduino_language_server", {
        capabilities = {
            textDocument = {
                semanticTokens = vim.NIL,
            },
            workspace = {
                semanticTokens = vim.NIL,
            },
        },
        cmd = {
            --'arduino-language-server -cli-config C:/Users/jvpan/.arduinoIDE/arduino-cli.yaml -fqbn arduino:avr:uno -cli arduino-cli -clangd clangd -log debug',
            "C:/Users/jvpan/lsp&compilers&tools/arduino-language-server_0.7.7_Windows_64bit/arduino-language-server.exe",
            "-clangd",
            "C:/Users/jvpan/lsp&compilers&tools/clangd_19.1.2/bin/clangd.exe",
            "-cli",
            "C:/Users/jvpan/lsp&compilers&tools/arduino-cli_1.2.2_Windows_64bit/arduino-cli.exe",
            "-cli-config",
            "C:/Users/jvpan/.arduinoIDE/arduino-cli.yaml",
            "-fqbn",
            "arduino:avr:uno",
        },

        filetypes = { "arduino" },
        --capabilities = capabilities,
    })
end

arduino_setup.setupKeybinds = function()
    vim.keymap.set("n", "<F11>", function()
        print "Compiling and Uploading..."
        vim.cmd.cd "%:p:h"
        local result = vim.fn.system "arduino-cli compile -u"
        print(result)
    end, { desc = "Compiles and Uploads" })

    vim.keymap.set("n", "<F10>", function()
        print "Attaching board..."
        vim.cmd.cd "%:p:h"
        local result = vim.fn.system "arduino-cli board attach -p COM4 -b arduino:avr:uno"
        print(result)
    end, { desc = "Attaches the board via yaml" })

    vim.keymap.set("n", "<F12>", function()
        vim.cmd.cd "%:p:h"
        print "Launching Serial Monitor"
        --vim.cmd '!start cmd /k arduino-cli monitor'
        vim.cmd "vsplit"
        vim.cmd.terminal "arduino-cli monitor"
    end, { desc = "Launches CLI serial monitor" })
end

return arduino_setup

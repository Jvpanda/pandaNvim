local arduino_setup = {}

local workspace = require "tools.workspace_tracker"

--[[LSP Settings]]
arduino_setup.LSPSetup = function()
    if vim.fn.executable "arduino-language-server" == 0 then
        return
    end

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
            "arduino-language-server",
            "-cli-config",
            "C:/Users/jvpan/.arduinoIDE/arduino-cli.yaml",
            "-fqbn",
            "arduino:avr:uno",
            "-cli",
            "arduino-cli",
            "-clangd",
            "clangd",
        },

        filetypes = { "arduino" },

        root_dir = function(bufnr, on_dir)
            on_dir(vim.fn.expand "%:p:h")
        end,
    })
end

-- [[Keybind Setup]]
local function createInoFileInCD(input)
    if vim.fn.filereadable(input) == 0 or input == vim.fn.expand "%:p" then
        local file = io.open(input, "w")
        if file ~= nil then
            file:write("void setup() {\n}\n\n" .. "void loop() {\n}")
            file:close()
            print("Created " .. input)
        end
    end
end

local function createYamlAttach(input)
    local file = io.open(input, "w")
    if file ~= nil then
        file:write "default_fqbn: arduino:avr:uno\ndefault_port: COM4"
        file:close()
        print("Created " .. input)
    end
end

arduino_setup.setupKeybinds = function()
    vim.keymap.set("n", "<F9>", function()
        if workspace.isWorkspaceSet() then
            local input = vim.fn.input { prompt = "Please input a name for the sketch: ", cancelreturn = "none" }

            if input == "none" then
                return
            else
                input = workspace.getWorkspace() .. "src/" .. input .. ".ino"
                createInoFileInCD(input)
            end
        else
            print "Please set a workspace"
        end
    end, { desc = "Creates a new sketch relative to the workspace" })

    vim.keymap.set("n", "<F10>", function()
        if workspace.isWorkspaceSet() then
            print "Attaching board..."
            createYamlAttach(workspace.getWorkspace() .. "src/sketch.yaml")
        else
            print "Please set a workspace"
        end
    end, { desc = "Attaches the board via yaml" })

    vim.keymap.set("n", "<F11>", function()
        if workspace.isWorkspaceSet() then
            vim.cmd.wa()
            print "Compiling and Uploading..."
            local result = vim.fn.system { "arduino-cli", "compile", workspace.getWorkspace() .. "src/", "-u" }
            print(result)
        else
            print "Please set a workspace"
        end
    end, { desc = "Compiles and Uploads" })

    vim.keymap.set("n", "<F12>", function()
        vim.cmd.cd "%:p:h"
        print "Launching Serial Monitor"
        --vim.cmd '!start cmd /k arduino-cli monitor'
        vim.cmd "vsplit"
        vim.cmd.terminal "arduino-cli monitor"
    end, { desc = "Launches CLI serial monitor" })
end

return arduino_setup

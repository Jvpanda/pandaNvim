local dap = require "dap"
local opts = require "language_configurations.cpp.cpp_opts"
local cppGeneral = require "language_configurations.cpp.cpp_general"

dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
}

dap.configurations.cpp = {
    {
        name = "Launch",
        type = "gdb",
        request = "launch",
        program = cppGeneral.getExecutablePath,
        args = {}, -- provide arguments if needed
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = function()
            if opts.debugRunStart == "Run" then
                return false
            else
                return true
            end
        end,
    },
    {
        name = "Select and attach to process",
        type = "gdb",
        request = "attach",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        pid = function()
            local name = vim.fn.input "Executable name (filter): "
            return require("dap.utils").pick_process { filter = name }
        end,
        cwd = "${workspaceFolder}",
    },
    {
        name = "Attach to gdbserver :1234",
        type = "gdb",
        request = "attach",
        target = "localhost:1234",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
    },
}

local general = require "tools.general_functions"
local opts = require "language_configurations.cppAndC.general_opts"
local terminal = require "tools.environment_setup.terminal_api"
local workspace = require "tools.workspace_tracker"

local M = {}
-- [[ Editor Environment Setup]]
M.cmake_generate_build = function()
    general.generate_environment_file "cpp/.editorconfig"
    general.generate_environment_file "cpp/.clang-format"
    general.generate_environment_file "cpp/CMakeUserPresets.json"
    general.generate_environment_file "cpp/CMakeLists.txt"
    general.generate_environment_file "cpp/.gitignore"

    local result = Await_System {
        "cmake",
        "--preset",
        opts.buildType,
    }

    -- Create symlink for compile commands
    local source = workspace.getWorkspace() .. "/build/" .. opts.buildType .. "/compile_commands.json"
    local destination = workspace.getWorkspace() .. "/build/compile_commands.json"
    -- Error is expected here for non existing synlinks, it is fine
    local success, err = vim.uv.fs_unlink(destination)

    success, err = vim.uv.fs_symlink(source, destination)
    if not success then
        print("ERROR IN SYMLINK CREATION: " .. err)
    end

    return "----------\n" .. result .. "----------\n"
end

-- [[Compiling and running]]
M.cmake_compile = function()
    vim.cmd.wa()
    print("Compiling... with build type " .. opts.buildType)

    local result = Await_System({ "cmake", "--build", "--preset", opts.buildType }, {})

    if string.find(result, "error") ~= nil then
        local str = ("----------\nCOMPILATION ERROR\n----------\n" .. result .. "----------\nCOMPILATION ERROR\n----------\n")
        return false, str
    elseif string.find(result, "warning") ~= nil then
        local str = "----------\nCOMPILATION WARNING\n----------\n" .. result .. "----------\nCOMPILATION WARNING\n----------\n"
        return true, str
    else
        local prettyResult = "-------\n" .. result .. "-------\n"
        return true, prettyResult
    end
end

M.run_cpp = function()
    local filepath = workspace.getWorkspace() .. "/build/" .. opts.buildType .. "/execBinary"
    if general.isOnWindows() then
        filepath = filepath .. ".exe"
    end

    if opts.buildType == "Debug" then
        if opts.debugger == "GDB" then
            require("dap").continue()
            require("dap-view").open()
            return
        end
    else
        terminal.run_command_on_terminal(filepath, opts.runWindow, opts.vimFloatingWindowSize)
    end
end

return M

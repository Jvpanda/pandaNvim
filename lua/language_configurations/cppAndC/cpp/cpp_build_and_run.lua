local general = require "tools.general_functions"
local opts = require "language_configurations.cppAndC.general_opts"
local cppGeneral = require "language_configurations.cppAndC.cppAndC_general"
local terminal = require "language_configurations.cppAndC.terminal_creation"

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
    cppGeneral.create_or_switch_symlinks()
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
    local filepath = cppGeneral.get_executable_path()

    if opts.buildType == "Debug" then
        if opts.debugger == "GDB" then
            require("dap").continue()
            require("dap-view").open()
            return
        end
    else
        terminal.create_terminal_from_type(filepath)
    end
end

return M

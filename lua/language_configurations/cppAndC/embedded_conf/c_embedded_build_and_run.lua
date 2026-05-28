local API = {}

local general = require "tools.general_functions"
local opts = require "language_configurations.cppAndC.general_opts"
local cppGeneral = require "language_configurations.cppAndC.cppAndC_general"

-- [[ Editor Environment Setup]]

local cmake_generate_build = function()
    local result = Await_System {
        "cmake",
        "--preset",
        opts.buildType,
    }
    cppGeneral.create_or_switch_symlinks()
    return "----------\n" .. result .. "----------\n"
end

-- [[Flashing and Bin]]
local cmake_flash = function()
    local result = Await_System {
        "cmake",
        "--build",
        "--preset",
        "flash",
    }
    cppGeneral.create_or_switch_symlinks()
    return "----------\n" .. result .. "----------\n"
end

local cmake_bin = function()
    local result = Await_System {
        "cmake",
        "--build",
        "--preset",
        "bin",
    }
    cppGeneral.create_or_switch_symlinks()
    return "----------\n" .. result .. "----------\n"
end

-- [[Compiling and running]]
local cmake_compile = function()
    vim.cmd.wa()

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

local run = function()
    require("dap-view").open()
    require("dap").continue()
end

--[[ API FOR KEYBINDS]]

API.build = function()
    print("Generating Build Files for " .. opts.buildType)
    cppGeneral.naPrint(cmake_generate_build())
end

API.compile = function()
    if vim.fn.isdirectory("build/" .. opts.buildType) == 0 then
        API.build()
    end

    local isCompiled, result = cmake_compile()
    cppGeneral.naPrint(result)
end

API.flash = function()
    print "Flashing Board..."
    cppGeneral.naPrint(cmake_flash())
end

API.bin = function()
    print "Creating Bin File..."
    cppGeneral.naPrint(cmake_bin())
end

API.run = function()
    run()
end

-- This will also flash
API.compile_and_run = function()
    local isCompiled, compilationResult = cmake_compile()

    if isCompiled then
        cppGeneral.naPrint(compilationResult)
        cmake_flash()
        run()
    else
        vim.notify(compilationResult)
    end
end

return API

local menu = require "language_configurations.cppAndC.cpp.cpp_menus"
local cpp_generic = require "language_configurations.cppAndC.cpp.cpp_build_and_run"
local general = require "tools.general_functions"
local opts = require "language_configurations.cppAndC.general_opts"
local dbg = require "language_configurations.cppAndC.debug.debugKeybinds"

local API = {}
--[[ API FOR KEYBINDS]]
API.build = function()
    print("Generating Build Files for " .. opts.buildType)
    general.naPrint(cpp_generic.cmake_generate_build())
end

API.compile = function()
    if vim.fn.isdirectory("build/" .. opts.buildType) == 0 then
        API.build()
    end

    local isCompiled, result = cpp_generic.cmake_compile()
    general.naPrint(result)
end

API.run = function()
    cpp_generic.run_cpp()
end

API.compile_and_run = function()
    local isCompiled, compilationResult = cpp_generic.cmake_compile()

    if isCompiled then
        general.naPrint(compilationResult)
        cpp_generic.run_cpp()
    else
        vim.notify(compilationResult)
    end
end

API.call_menu = function()
    menu.call_menu()
end

API.setup = function()
    dbg.setupDapKeybinds()
end

return API

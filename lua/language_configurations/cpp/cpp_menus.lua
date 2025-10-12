local cpp_opts = require "language_configurations.cpp.cpp_opts"
local general = require "tools.general_functions"
local build = require "language_configurations.cpp.cpp_build_and_run"

-- [[ CUSTOM MENU CALLBACKS ]]
local customMenuCallbacks = {}

local handle_main_menu = function(option)
    customMenuCallbacks[option]()
end

local function handle_window_type_menu(windowType)
    print("Switched To " .. windowType)
    cpp_opts.runWindow = windowType
end

local handle_cmake_menu = function(option)
    if option == "Add File To Source" then
        build.add_file_to_cmake_lists()
    end
end
local handle_debug_run_menu = function(option)
    cpp_opts.debugRunStart = option
    print("Switched to " .. option)
end

customMenuCallbacks["Release Run Options"] = function()
    general.customOptionsMenu({ "external", "external_permanent", "floatingWindow", "window" }, { rowCount = 4, widthRatio = 0.1 }, handle_window_type_menu)
end

customMenuCallbacks["Switch To Release"] = function()
    print "Switched To Release"
    cpp_opts.buildType = "Release"
    build.create_or_switch_symlinks()
end

customMenuCallbacks["Switch To Debug"] = function()
    print "Switched To Debug"
    cpp_opts.buildType = "Debug"
    build.create_or_switch_symlinks()
end
customMenuCallbacks["Debug Run Options"] = function()
    general.customOptionsMenu({ "Run", "Step Into", "No raddbg" }, { rowCount = 4, widthRatio = 0.1 }, handle_debug_run_menu)
end

customMenuCallbacks["Cmake"] = function()
    general.customOptionsMenu({ "Add file To Source" }, { rowCount = 4, widthRatio = 0.1 }, handle_cmake_menu)
end

-- [[ Main interface api ]]
local M = {}
M.call_menu = function()
    if cpp_opts.buildType == "Debug" then
        general.customOptionsMenu({ "Switch To Release", "Debug Run Options", "Cmake" }, { rowCount = 4, widthRatio = 0.2 }, handle_main_menu)
    else
        general.customOptionsMenu({ "Switch To Debug", "Release Run Options", "Cmake", "" }, { rowCount = 4, widthRatio = 0.2 }, handle_main_menu)
    end
end

return M

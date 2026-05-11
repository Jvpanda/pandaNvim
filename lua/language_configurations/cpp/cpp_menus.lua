local cpp_opts = require "language_configurations.cpp.cpp_opts"
local cpp_quick = require "language_configurations.cpp.cpp_quick_interact"
local general = require "tools.general_functions"
local build = require "language_configurations.cpp.cpp_build_and_run"

-- [[ CUSTOM MENU CALLBACKS HANDLERS]]
local mainMenuCallbacks = {}

local handle_main_menu = function(option)
    mainMenuCallbacks[option]()
end

local function handle_window_type_menu(windowType)
    print("Switched To " .. windowType)
    cpp_opts.runWindow = windowType
end

local handle_cmake_menu = function(option)
    if option == "Add File To Source" then
        cpp_quick.add_file_to_cmake_lists()
    end
end

local handle_quick_action_menu = function(option) end

-- [[ CUSTOM MENU CALLBACKS ]]
mainMenuCallbacks["Release Run Options"] = function()
    general.customOptionsMenu({ "external", "external_permanent", "floatingWindow", "window" }, { rowCount = 4, widthRatio = 0.1 }, handle_window_type_menu)
end

mainMenuCallbacks["Switch To Release"] = function()
    print "Switched To Release"
    cpp_opts.buildType = "Release"
    Async(build.create_or_switch_symlinks)
end

mainMenuCallbacks["Switch To Debug"] = function()
    print "Switched To Debug"
    cpp_opts.buildType = "Debug"
    Async(build.create_or_switch_symlinks)
end

mainMenuCallbacks["Cmake"] = function()
    general.customOptionsMenu({ "Add File To Source" }, { rowCount = 4, widthRatio = 0.1 }, handle_cmake_menu)
end

mainMenuCallbacks["Quick Action"] = function() end

-- [[ Main interface api ]]
local M = {}
M.call_menu = function()
    if cpp_opts.buildType == "Debug" then
        general.customOptionsMenu({ "Quick Action", "Cmake", "Switch To Release" }, { rowCount = 4, widthRatio = 0.15 }, handle_main_menu)
    else
        general.customOptionsMenu({ "Quick Action", "Cmake", "Release Run Options", "Switch To Debug" }, { rowCount = 4, widthRatio = 0.15 }, handle_main_menu)
    end
end

return M

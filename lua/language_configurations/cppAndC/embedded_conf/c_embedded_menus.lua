local opts = require "language_configurations.cppAndC.general_opts"
local cpp_quick = require "language_configurations.cppAndC.cpp.cpp_quick_interact"
local general = require "tools.general_functions"
local build = require "language_configurations.cppAndC.embedded_conf.c_embedded_build_and_run"
local cpp_general = require "language_configurations.cppAndC.cppAndC_general"

-- [[ CUSTOM MENU CALLBACKS HANDLERS]]
local mainMenuCallbacks = {}

local handle_main_menu = function(option)
    mainMenuCallbacks[option]()
end

local handle_cmake_menu = function(option)
    if option == "Add File To Source" then
        cpp_quick.add_file_to_cmake_lists()
    end
end

local handle_quick_action_menu = function(option) end

-- [[ CUSTOM MENU CALLBACKS ]]

mainMenuCallbacks["Flash"] = function()
    Async(build.flash)
end

mainMenuCallbacks["Bin"] = function()
    Async(build.bin)
end

mainMenuCallbacks["Cmake"] = function()
    general.customOptionsMenu({ "Add File To Source" }, { rowCount = 4, widthRatio = 0.1 }, handle_cmake_menu)
end

-- [[ Main interface api ]]
local M = {}
M.call_menu = function()
    general.customOptionsMenu({ "Flash", "Bin", "Cmake" }, { rowCount = 4, widthRatio = 0.15 }, handle_main_menu)
end

return M

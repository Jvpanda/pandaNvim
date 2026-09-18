local general = require "tools.general_functions"
local build = require "language_configurations.cppAndC.embedded_conf.c_embedded_build_and_run"
local options_menu = require "language_configurations.cppAndC.generic_config_menu"

-- [[ CUSTOM MENU CALLBACKS HANDLERS]]
local mainMenuCallbacks = {}

local handle_main_menu = function(option)
    mainMenuCallbacks[option]()
end

-- [[ CUSTOM MENU CALLBACKS ]]

mainMenuCallbacks["Flash"] = function()
    Async(build.flash)
end

mainMenuCallbacks["Bin"] = function()
    Async(build.bin)
end

mainMenuCallbacks["Options"] = function()
    options_menu.call_options_menu()
end

-- [[ Main interface api ]]
local M = {}
M.call_menu = function()
    general.customOptionsMenu({ "Flash", "Bin", "Options" }, { rowCount = 4, widthRatio = 0.15 }, handle_main_menu)
end

return M

local options_menu = require "language_configurations.cppAndC.generic_config_menu"
local menu = require "tools.ui.menuing"
local west_opts = require "language_configurations.cppAndC.west_conf.west_options"
local general = require "tools.general_functions"
local workspace = require "tools.workspace_tracker"

-- [[ CUSTOM MENU CALLBACKS HANDLERS]]
local mainMenuCallbacks = {}

local handle_main_menu = function(option)
    mainMenuCallbacks[option]()
end

-- [[ CUSTOM MENU CALLBACKS ]]

mainMenuCallbacks["Set Board: " .. west_opts.board] = function()
    local selection = menu.customOptionsMenu { "nucleo_f401re", "nucle_g474re", "teensy41", "native_sim" }
    if selection ~= nil then
        west_opts.board = selection
    end
end

mainMenuCallbacks["Set Runner: " .. west_opts.runner] = function()
    local selection = menu.customOptionsMenu { "openocd", "none" }
    if selection == "none" or nil then
        west_opts.runner = nil
    else
        west_opts.runner = selection
    end
end

mainMenuCallbacks["Options"] = function()
    options_menu.call_options_menu()
end

mainMenuCallbacks["Generate Env File"] = function()
    local ws = workspace.getWorkspace()
    if ws ~= nil then
        general.generate_environment_file("zephyr/.clangd", vim.fn.fnamemodify(ws, ":h"))
    end
end

-- [[ Main interface api ]]
local M = {}
M.call_menu = function()
    menu.customOptionsMenu(
        { "Set Board: " .. west_opts.board, "Set Runner: " .. west_opts.runner, "Generate Env File", "Options" },
        { heightRatio = 0, heightOffset = 4, widthRatio = 0.2 },
        handle_main_menu
    )
end

return M

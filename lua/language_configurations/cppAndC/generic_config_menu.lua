local opts = require "language_configurations.cppAndC.general_opts"
local general = require "tools.general_functions"
local cpp_general = require "language_configurations.cppAndC.cppAndC_general"

-- [[ CUSTOM MENU CALLBACKS HANDLERS]]
local optionsMenuCallbacks = {}

local handle_options_menu = function(option)
    optionsMenuCallbacks[option]()
end

-- [[ TERMINAL MENU ]]
local function handle_terminal_menu(terminal_option)
    if terminal_option == "external" or terminal_option == "external_permanent" or terminal_option == "floatingWindow" or terminal_option == "window" then
        opts.runWindow = terminal_option
        print("Switched terminal window to: " .. terminal_option)
    elseif terminal_option == "Height Ratio: " .. opts.vimFloatingWindowSize.heightRatio then
        local new_ratio = vim.fn.input { prompt = "Input a Height Ratio (0-1): ", cancelreturn = nil }
        local new_num = tonumber(new_ratio)
        if new_ratio == nil or new_num == nil then
            print "Nothing Changed"
            return
        end
        opts.vimFloatingWindowSize.heightRatio = new_num
        print("Changed Height to: " .. opts.vimFloatingWindowSize.heightRatio)
    elseif terminal_option == "Width Ratio: " .. opts.vimFloatingWindowSize.widthRatio then
        local new_ratio = vim.fn.input { prompt = "Input a Width Ratio (0-1): ", cancelreturn = nil }
        local new_num = tonumber(new_ratio)
        if new_ratio == nil or new_num == nil then
            print "Nothing Changed"
            return
        end
        opts.vimFloatingWindowSize.widthRatio = new_num
        print("Changed Width to: " .. opts.vimFloatingWindowSize.widthRatio)
    end
end

local function show_currently_selected(tab, arg)
    for key, value in pairs(tab) do
        if value == arg then
            tab[key] = value .. " <- selected"
        end
    end
end

optionsMenuCallbacks["Terminal Configuration"] = function()
    local terminal_conf = {
        "Select Terminal Type",
        "--------------------",
        "external",
        "external_permanent",
        "floatingWindow",
        "window",
        "--------------------",
        "Change Floating Terminal Size",
        "--------------------",
        "Height Ratio: " .. opts.vimFloatingWindowSize.heightRatio,
        "Width Ratio: " .. opts.vimFloatingWindowSize.widthRatio,
    }
    show_currently_selected(terminal_conf, opts.runWindow)
    general.customOptionsMenu(terminal_conf, { rowCount = #terminal_conf + 1, widthRatio = 0.2 }, handle_terminal_menu)
end

-- [[ SUBSYSTEM MENU ]]
local function handle_subsystem_type_menu(subsystem_type)
    opts.configuration = subsystem_type
    print("Subsystem Changed To " .. subsystem_type)
end

optionsMenuCallbacks["Subsystem Type"] = function()
    local typeTable = { "Generic", "Bare Metal Embedded", "Zephyr", "ROS2" }
    show_currently_selected(typeTable, opts.configuration)
    general.customOptionsMenu(typeTable, { rowCount = #typeTable + 1, widthRatio = 0.2 }, handle_subsystem_type_menu)
end

-- [[ BUILD OPTIONS ]]

local function handle_build_options_menu(build_opt)
    if build_opt == "Debug" or build_opt == "Release" then
        opts.buildType = build_opt
        print("Switched Mode To: " .. opts.buildType)
    elseif build_opt == "Build Flags: " .. opts.buildFlags then
        local new_flags = vim.fn.input { prompt = "Input new flags: ", cancelreturn = nil }
        if new_flags == nil then
            print "Nothing Changed"
            return
        end
        opts.buildFlags = new_flags
        print("Build Flags Now: " .. opts.buildFlags)
    elseif build_opt == "Compile Flags: " .. opts.compileFlags then
        local new_flags = vim.fn.input { prompt = "Input new flags: ", cancelreturn = nil }
        if new_flags == nil then
            print "Nothing Changed"
            return
        end
        opts.compileFlags = new_flags
        print("Compile Flags Now: " .. opts.compileFlags)
    end
end

optionsMenuCallbacks["Build Options"] = function()
    local build_table = { "Debug", "Release", "Build Flags: " .. opts.buildFlags, "Compile Flags: " .. opts.compileFlags }
    show_currently_selected(build_table, opts.buildType)
    general.customOptionsMenu(build_table, { rowCount = #build_table + 1, widthRatio = 0.2 }, handle_build_options_menu)
end

-- [[ Main interface api ]]
local M = {}
M.call_options_menu = function()
    local menu_options = {}
    menu_options[1] = "Subsystem Type"
    menu_options[2] = "Build Options"
    menu_options[3] = "Terminal Configuration"

    general.customOptionsMenu(menu_options, { rowCount = 4, widthRatio = 0.15 }, handle_options_menu)
end

return M

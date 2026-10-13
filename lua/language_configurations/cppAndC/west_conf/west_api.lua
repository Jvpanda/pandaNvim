local menu = require "language_configurations.cppAndC.west_conf.west_menus"
local west = require "language_configurations.cppAndC.west_conf.west_build_and_run"
local general = require "tools.general_functions"

local function check_compilation(input)
    if string.find(input, "error") ~= nil then
        local str = ("----------\nCOMPILATION ERROR\n----------\n" .. input .. "----------\nCOMPILATION ERROR\n----------\n")
        vim.notify(str)
    elseif string.find(input, "warning") ~= nil then
        local str = "----------\nCOMPILATION WARNING\n----------\n" .. input .. "----------\nCOMPILATION WARNING\n----------\n"
        vim.notify(str)
    else
        local prettyResult = "-------\n" .. input .. "-------\n"
        general.naPrint(prettyResult)
    end
end

local API = {}
--[[ API FOR KEYBINDS]]
API.build = function()
    print "No build function for west"
end

API.compile = function()
    local result = west.generate_build()
    check_compilation(result)
end

API.run = function()
    print "No run"
end

API.compile_and_run = function()
    local result = west.flash()
    check_compilation(result)
end

API.call_menu = function()
    menu.call_menu()
end

API.setup = function() end

return API

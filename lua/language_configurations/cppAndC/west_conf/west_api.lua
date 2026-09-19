local menu = require "language_configurations.cppAndC.west_conf.west_menus"
local west = require "language_configurations.cppAndC.west_conf.west_build_and_run"
local general = require "tools.general_functions"

local API = {}
--[[ API FOR KEYBINDS]]
API.build = function()
    print "No build function for west"
end

API.compile = function()
    local result = west.generate_build()
    general.naPrint(result)
end

API.run = function()
    print "No run"
end

API.compile_and_run = function()
    local result = west.flash()
    general.naPrint(result)
end

API.call_menu = function()
    menu.call_menu()
end

API.setup = function() end

return API

local configuration_menu = require "language_configurations.cppAndC.generic_config_menu"
local M = {}

M.call_menu = function()
    configuration_menu.call_options_menu()
end

return M

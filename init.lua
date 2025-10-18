-- [[ Sets Colorscheme to Mine ]]
vim.cmd.colorscheme "My_Scheme"

-- [[ Sets up all needed installations and env variables for them ]]
require "tools.installation_manager.install_environment"

-- [[ Sets Up Options]]
require "options"

-- [[ Sets up all plugins ]]
-- NOTE: "plugin-setup" means there's more than one plugin being setup in the file
require "lazy-bootstrap"

-- [[ Basic Keymaps]]
require "keymaps"

-- [[ Sets up LSPS and Autocommands for keybinds ]]
require "languages_setup"

-- [[ Sets up General Tooks like Buffer Selector ]]
require "general_tools_setup"

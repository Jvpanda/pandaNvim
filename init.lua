-- NOTE: "plugin-setup" means there's more than one plugin being setup in the file
vim.cmd.colorscheme "My_Scheme"
-- [[Setting Options]]
require "options"
-- [[ Sets up all plugins ]]
require "lazy-bootstrap"
-- [[ Basic Keymaps]]
require "keymaps"
-- [[Sets Custom Commands and Autocommands]]
require "custom-commands"

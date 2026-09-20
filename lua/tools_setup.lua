local env = require "tools.environment_setup.terminal_api"
local general = require "tools.general_functions"

--[[Tools]]
require "tools.ui.buffer_selector_v2"
require "tools.lua_snippets"

--Terminal Bootstrap
if general.isOnWindows() == false then
    env.setup_terminal_env()
end

--[[My Commands]]

-- [[Autocommands]]
local myAutogroup = vim.api.nvim_create_augroup("ToolsAutogroup", { clear = true })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("HighlightOnYank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Save when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
    desc = "Saves when leaving insert",
    group = myAutogroup,
    pattern = { "*.txt", "*.py", "*.cpp", "*.h", "*.c" },
    callback = function()
        if vim.bo.modified then
            vim.cmd "silent write"
        end
    end,
})

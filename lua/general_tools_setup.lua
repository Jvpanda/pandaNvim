local buffer_selector = require "tools.buffer_selector"
local cpp_opts = require "language_configurations.cpp.cpp_opts"
local env = require "tools.environment_setup"

--[[Tools]]
buffer_selector.setupBufferSelector()
require "tools.lua_snippets"

--cpp Bootstrap
env.getTerminal(cpp_opts)

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
    pattern = { "*.txt", "*.py", "*.cpp", "*.h" },
    callback = function()
        if vim.bo.modified then
            vim.cmd "silent write"
        end
    end,
})

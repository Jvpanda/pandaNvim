local arduino_setup = require "tools.arduino"
local cpp_setup = require "tools.cpp"
local gdscipt_setup = require "tools.gdscript"
local python_setup = require "tools.python"
local lua_setup = require "tools.lua_setup"
require "tools.buffer_selector"

--[[My Commands]]
gdscipt_setup.createServerAndPassCommands()

--[[Enable LSP's]]
cpp_setup.LSPSetup()
arduino_setup.LSPSetup()
gdscipt_setup.LSPSetup()
python_setup.LSPSetup()
lua_setup.LSPSetup()

--[[Enable Dap Protocols]]
gdscipt_setup.dapSetup()
cpp_setup.dapSetup()

-- [[ Basic Autocommands ]]
local myAutogroup = vim.api.nvim_create_augroup("customAutogroup", { clear = true })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("HighlightOnYank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

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

local serverRunning = false
vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Runs listening server when opening a .gd",
    group = myAutogroup,
    pattern = "*", --{ '*.gd', ' *.ino' },
    callback = function()
        local filetype = vim.bo.filetype
        if filetype == "cpp" or filetype == "h" then
            cpp_setup.setupKeybinds()
        elseif serverRunning == false and filetype == "gd" then
            vim.cmd.Godot "start"
            serverRunning = true
        elseif filetype == "arduino" then
            arduino_setup.setupKeybinds()
        end
    end,
})

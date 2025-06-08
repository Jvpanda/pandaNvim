local arduino_setup = require "language_configurations.arduino"
local cpp_setup = require "language_configurations.cpp"
local gdscipt_setup = require "language_configurations.gdscript"
local python_setup = require "language_configurations.python"
local lua_setup = require "language_configurations.lua_setup"
local go_setup = require "language_configurations.go"
local lspKeybindsAndHighlighing = require "language_configurations.lsp-keybindsAndHighlighting"

require "tools.buffer_selector"

--[[My Commands]]
gdscipt_setup.createServerPassCommands()

--[[Enable and Configure LSP's]]
lspKeybindsAndHighlighing.LSPKeybindsSetup()
lspKeybindsAndHighlighing.LSPHighlightSetup()
go_setup.LSPSetup()
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
    pattern = "*",
    callback = function()
        local filetype = vim.bo.filetype
        if filetype == "cpp" or filetype == "h" then
            cpp_setup.setupKeybinds()
        elseif serverRunning == false and filetype == "gdscript" then
            vim.cmd.Godot "start"
            serverRunning = true
        elseif filetype == "arduino" then
            arduino_setup.setupKeybinds()
        end
    end,
})

vim.filetype.add { extension = { se = "se" } }
vim.filetype.add { extension = { cExample = "cExample" } }

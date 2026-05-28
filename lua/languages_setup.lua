local arduino_setup = require "language_configurations.arduino"
local cpp_lsp = require "language_configurations.cppAndC.clangd_lsp_setup"
local gdscript_setup = require "language_configurations.gdscript"
local python_setup = require "language_configurations.python"
local lua_setup = require "language_configurations.lua_setup"
local go_setup = require "language_configurations.go"
local rust_setup = require "language_configurations.rust"
local lspKeybindsAndHighlighing = require "language_configurations.lsp-keybindsAndHighlighting"

--[[Configure LSP's]]
lspKeybindsAndHighlighing.LSPKeybindsSetup()
lspKeybindsAndHighlighing.LSPHighlightSetup()
go_setup.LSPSetup()
cpp_lsp.LSPSetup()
arduino_setup.LSPSetup()
gdscript_setup.LSPSetup()
python_setup.LSPSetup()
lua_setup.LSPSetup()
rust_setup.LSPSetup()

--[[Configure DAP's]]
local cpp_dap = require "language_configurations.cppAndC.debug.dapSettings"
local c_embedded_dap = require "language_configurations.cppAndC.debug.cDapConfig"

-- [[ Basic Autocommands ]]
local myAutogroup = vim.api.nvim_create_augroup("LSPKeybindAutogroup", { clear = true })

-- Decide which keybinds to use when entering buf
vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Runs the necessary keybinds when entering a buffer",
    group = myAutogroup,
    pattern = "*",
    callback = function()
        local filetype = vim.bo.filetype
        if filetype == "gdscript" then
            gdscript_setup.setupKeybinds()
            gdscript_setup.startListenServerForFileJumps()
        end
    end,
})

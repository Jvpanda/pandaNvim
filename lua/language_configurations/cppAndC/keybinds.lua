local cpp_keybinds = {}
local dbg = require "language_configurations.cppAndC.debug.debugMenu"
local opts = require "language_configurations.cppAndC.general_opts"

local conf = {}
conf["Normal"] = require "language_configurations.cppAndC.cpp.cpp_build_and_run"
conf["Embedded"] = require "language_configurations.cppAndC.embedded_conf.c_embedded_build_and_run"
local menu_conf = {}
menu_conf["Normal"] = require "language_configurations.cppAndC.cpp.cpp_menus"
menu_conf["Embedded"] = require "language_configurations.cppAndC.embedded_conf.c_embedded_menus"

-- [[Debug Keybinds ]]
-- raddbg
local raddbg = require "language_configurations.cppAndC.debug.raddbg"

cpp_keybinds.setupRaddbgKeybinds = function()
    vim.keymap.set("n", "<F7>", function()
        vim.fn.system { "raddbg", "--ipc", "step_out" }
    end, {})
    vim.keymap.set("n", "<F6>", function()
        vim.fn.system { "raddbg", "--ipc", "step_into" }
    end, {})
    vim.keymap.set("n", "<F5>", function()
        vim.fn.system { "raddbg", "--ipc", "step_over" }
    end, {})

    vim.keymap.set("n", "<leader>ba", raddbg.add_or_remove_breakpoint, { desc = "[BA]dd or Remove Breakpoint" })

    vim.keymap.set("n", "<leader>bt", raddbg.toggle_breakpoint, { desc = "[B]oggle [T]reakpoint" })

    vim.keymap.set("n", "<leader>br", raddbg.set_breakpoint_signs_from_raddbg, { desc = "[BR]eset Breakpoints" })

    vim.keymap.set("n", "<leader>bw", raddbg.toggle_watch_expr, { desc = "[B]oggle a [W]atch expression" })
end

cpp_keybinds.setupDapKeybinds = function()
    local dap = require "dap"
    local dapView = require "dap-view"

    vim.keymap.set("n", "<F5>", dap.step_out)
    vim.keymap.set("n", "<F6>", dap.step_into)
    vim.keymap.set("n", "<F7>", dap.step_over)

    vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "🛑 Toggle Breakpoint" })

    vim.keymap.set("n", "<Leader>dB", function()
        dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
    end, { desc = "🚩 Set Breakpoint with Condition" })

    vim.keymap.set("n", "<Leader>dw", dapView.add_expr, { desc = "Add watch" })
end

-- [[ALL KEYBINDS ]]
function cpp_keybinds.setup_keybinds()
    --[[ Regular Keybinds ]]
    vim.keymap.set("n", "<F9>", function()
        menu_conf[opts.configuration].call_menu()
    end)

    vim.keymap.set("n", "<F10>", function()
        Async(conf[opts.configuration].build)
    end)

    vim.keymap.set("n", "<F11>", function()
        Async(conf[opts.configuration].compile)
    end)

    vim.keymap.set("n", "<f12>", function()
        Async(conf[opts.configuration].compile_and_run)
    end)

    vim.keymap.set("n", "<S-f12>", function()
        Async(conf[opts.configuration].run)
    end)

    if opts.debugger == "raddbg" then
        dbg.cppSetupRaddbgMenu()
        cpp_keybinds.setupRaddbgKeybinds()
    else
        dbg.cppSetupDapMenu()
        cpp_keybinds.setupDapKeybinds()
    end
end

return cpp_keybinds

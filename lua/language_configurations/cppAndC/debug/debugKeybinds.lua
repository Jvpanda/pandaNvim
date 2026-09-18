local debugMenu = require "language_configurations.cppAndC.debug.debugMenu"
local debugKeybinds = {}

-- [[Debug Keybinds ]]
debugKeybinds.setupDapKeybinds = function()
    local dap = require "dap"
    local dapView = require "dap-view"

    vim.keymap.set("n", "<F5>", dap.step_out)
    vim.keymap.set("n", "<F6>", dap.step_into)
    vim.keymap.set("n", "<F7>", dap.step_over)
    vim.keymap.set("n", "<F8>", debugMenu.open_dap_debug_menu, {})

    vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "🛑 Toggle Breakpoint" })

    vim.keymap.set("n", "<Leader>dB", function()
        dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
    end, { desc = "🚩 Set Breakpoint with Condition" })

    vim.keymap.set("n", "<Leader>dw", dapView.add_expr, { desc = "Add watch" })
end

return debugKeybinds

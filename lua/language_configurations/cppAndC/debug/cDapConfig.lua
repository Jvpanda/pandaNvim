local opts = require "language_configurations.cppAndC.general_opts"
local dap = require "dap"
local cppAndC_general = require "language_configurations.cppAndC.cppAndC_general"
local handle

-- Documentation that helped:
-- help dap.txt
-- https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#c-c-rust-via-gdb
-- https://sourceware.org/gdb/current/onlinedocs/gdb#Debugger-Adapter-Protocol
-- https://microsoft.github.io/debug-adapter-protocol/specification#Events_Initialized

dap.adapters.gdbstm = {
    type = "executable",
    command = "gdb-multiarch",
    args = { "--interpreter=dap" }, -- important: DAP mode
}

-- Auto-start OpenOCD
dap.listeners.before["initialize"]["thing2"] = function(session)
    if session.config.type == "gdbstm" then
        handle = vim.loop.spawn("openocd", {
            args = {
                "-f",
                "interface/stlink.cfg",
                "-f",
                "target/stm32f4x.cfg",
            },
        }, function()
            if handle then
                handle:close()
            end
        end)
        print "OpenOCD Server Opened"
    end
end

-- Auto-stop OpenOCD
-- Note to self, this will run after ANY terminate. So try not to do too much at once
dap.listeners.after["terminate"]["thing"] = function()
    if handle then
        handle:kill "sigterm"
        handle = nil
        print "OpenOCD Server Terminated"
    end
end

local myAutogroup = vim.api.nvim_create_augroup("CustomExit", { clear = true })
-- Decide which keybinds to use when entering buf
vim.api.nvim_create_autocmd("ExitPre", {
    desc = "Kills OpenOCD On Exit",
    group = myAutogroup,
    pattern = "*",
    callback = function()
        if handle then
            handle:kill "sigterm"
            handle = nil
            print "OpenOCD Server Terminated"
        end
    end,
})

dap.configurations.c = {

    {
        name = "Attach to gdbserver :3333",
        type = "gdbstm",
        request = "attach",
        target = "localhost:3333",

        stopAtBeginningOfMainSubprogram = function()
            if opts.debugRunStart == "Run" then
                return false
            else
                return true
            end
        end,

        program = cppAndC_general.find_elf,

        cwd = "${workspaceFolder}",
    },
}

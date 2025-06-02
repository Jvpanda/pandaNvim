return {
    "mfussenegger/nvim-dap",
    dependencies = {
        -- Creates a beautiful debugger UI
        "rcarriga/nvim-dap-ui",

        -- Required dependency for nvim-dap-ui
        "nvim-neotest/nvim-nio",

        -- Add other dap plugin debuggers here
    },
    keys = function(_, keys)
        local dap = require "dap"
        local dapui = require "dapui"
        return {
            -- Basic debugging keymaps, feel free to change to your liking!
            { "<F1>", dap.step_into, desc = "Debug: Step Into" },
            { "<F2>", dap.step_over, desc = "Debug: Step Over" },
            { "<F3>", dap.step_out, desc = "Debug: Step Out" },
            { "<F4>", dapui.toggle, desc = "Debug: Toggle UI" },
            { "<F5>", dap.continue, desc = "Debug: Start/Continue" },
            { "<F6>", dap.terminate, desc = "Debug: Terminate" },
            {
                "<F7>",
                function()
                    vim.notify "F1 Step Into\nF2 Step Over\nF3 Step Out\nF4 Toggle UI\nF5 Start/Continue\nF6 Terminate"
                end,
                desc = "To remember what is what",
            },

            { "<leader>bb", dap.toggle_breakpoint, desc = "Debug: Toggle Breakpoint" },
            {
                "<leader>bB",
                function()
                    dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
                end,
                desc = "Debug: Set Breakpoint",
            },
            unpack(keys),
        }
    end,
    config = function()
        local dap = require "dap"
        local dapui = require "dapui"

        -- Dap UI setup
        -- For more information, see |:help nvim-dap-ui|
        dapui.setup {
            icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
            controls = {
                icons = {
                    pause = "⏸",
                    play = "▶",
                    step_into = "⏎",
                    step_over = "⏭",
                    step_out = "⏮",
                    step_back = "b",
                    run_last = "▶▶",
                    terminate = "⏹",
                    disconnect = "⏏",
                },
            },
        }

        -- Change breakpoint icons
        vim.api.nvim_set_hl(0, "DapBreak", { fg = "#e51400" })
        vim.api.nvim_set_hl(0, "DapStop", { fg = "#ffcc00" })
        local breakpoint_icons = vim.g.have_nerd_font
                and { Breakpoint = "", BreakpointCondition = "", BreakpointRejected = "", LogPoint = "", Stopped = "" }
            or { Breakpoint = "●", BreakpointCondition = "⊜", BreakpointRejected = "⊘", LogPoint = "◆", Stopped = "⭔" }
        for type, icon in pairs(breakpoint_icons) do
            local tp = "Dap" .. type
            local hl = (type == "Stopped") and "DapStop" or "DapBreak"
            vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
        end

        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close
    end,
}

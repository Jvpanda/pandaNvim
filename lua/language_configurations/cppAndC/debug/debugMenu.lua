local menu = require "tools.ui.menuing"
local dap = require "dap"
local dapView = require "dap-view"
local opts = require "language_configurations.cppAndC.general_opts"

local Api = {}

-- [[GDB/DAP MENU OPTIONS ]]

local function handle_dap_menu(option)
    if option == "Toggle Dap View" then
        dapView.toggle()
    elseif option == "Terminate" then
        dap.terminate()
        dapView.close()
    elseif option == "Pause Thread" then
        dap.pause()
    elseif option == "Toggle Virtual Text" then
        dapView.virtual_text_toggle()
    elseif option == "Clear Breakpoints" then
        dap.clear_breakpoints()
    elseif option == "Breakpoint At Start" then
        opts.debugRunStart = "Stop"
    elseif option == "Run Past Start" then
        opts.debugRunStart = "Run"
    elseif option == "Run Last Dap" then
        dap.run_last()
    elseif option == "Open REPL" then
        dap.repl.open()
    end
end

local x = {}
x["Run"] = "Breakpoint At Start"
x["Stop"] = "Run Past Start"

Api.open_dap_debug_menu = function()
    menu.customOptionsMenu({
        "Toggle Dap View",
        "Terminate",
        "Pause Thread",
        "Toggle Virtual Text",
        "Clear Breakpoints",
        x[opts.debugRunStart],
        "Run Last Dap",
        "Open REPL",
    }, { heightOffset = 8, widthRatio = 0.2 }, handle_dap_menu)
end

return Api

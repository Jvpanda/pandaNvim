local general = require "tools.general_functions"
local dap = require "dap"
local dapView = require "dap-view"
local cppOpts = require "language_configurations.cpp.cpp_opts"

local Api = {}

-- [[raddbg MENU OPTIONS ]]
local function handle_raddbg_menu(option, bufData)
    if option == "Kill Instance" then
        vim.system { "raddbg", "--ipc", "kill" }
        print "Killing"
    elseif option == "Run To Line" then
        vim.system { "raddbg", "--ipc", "run_to_line ", bufData.name .. ":" .. bufData.row }
        print "Running to Line"
    elseif option == "Halt" then
        vim.system { "raddbg", "--ipc", "halt" }
    end
end

local raddbg_debug_menu = function()
    local bufData = general.get_buf_data()
    general.customOptionsMenu({ "Kill Instance", "Halt", "Run To Line" }, { rowCount = 5, widthRatio = 0.2 }, handle_raddbg_menu, bufData)
end

Api.cppSetupRaddbgMenu = function()
    vim.keymap.set("n", "<F8>", raddbg_debug_menu, {})
end

-- [[GDB/DAP MENU OPTIONS ]]

local function handle_dap_menu(option)
    if option == "Toggle Dap View" then
        dapView.toggle()
    elseif option == "Toggle Virtual Text" then
        dapView.virtual_text_toggle()
    elseif option == "Clear Breakpoints" then
        dap.clear_breakpoints()
    elseif option == "Breakpoint At Start" then
        cppOpts.debugRunStart = "Stop"
    elseif option == "Run Past Start" then
        cppOpts.debugRunStart = "Run"
    elseif option == "Run Last Dap" then
        dap.run_last()
    elseif option == "Open REPL" then
        dap.repl.open()
    end
end

local x = {}
x["Run"] = "Breakpoint At Start"
x["Stop"] = "Run Past Start"

local dap_debug_menu = function()
    general.customOptionsMenu({
        "Toggle Dap View",
        "Toggle Virtual Text",
        "Clear Breakpoints",
        x[cppOpts.debugRunStart],
        "Run Last Dap",
        "Open REPL",
    }, { rowCount = 8, widthRatio = 0.2 }, handle_dap_menu)
end

Api.cppSetupDapMenu = function()
    vim.keymap.set("n", "<F8>", dap_debug_menu, {})
end

return Api

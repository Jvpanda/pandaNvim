local API = {}

local general = require "tools.general_functions"
local opts = require "language_configurations.cppAndC.general_opts"
local raddbg = require "language_configurations.cppAndC.debug.raddbg"
local cppGeneral = require "language_configurations.cppAndC.cppAndC_general"

-- [[ Editor Environment Setup]]

local cmake_generate_build = function()
    general.generate_environment_file "cpp/.editorconfig"
    general.generate_environment_file "cpp/.clang-format"
    general.generate_environment_file "cpp/CMakeUserPresets.json"
    general.generate_environment_file "cpp/CMakeLists.txt"
    general.generate_environment_file "cpp/.gitignore"

    local result = Await_System {
        "cmake",
        "--preset",
        opts.buildType,
    }
    cppGeneral.create_or_switch_symlinks()
    return "----------\n" .. result .. "----------\n"
end

-- [[Compiling and running]]
local cmake_compile = function()
    vim.cmd.wa()
    print("Compiling... with build type " .. opts.buildType)

    local result = Await_System({ "cmake", "--build", "--preset", opts.buildType }, {})

    if string.find(result, "error") ~= nil then
        local str = ("----------\nCOMPILATION ERROR\n----------\n" .. result .. "----------\nCOMPILATION ERROR\n----------\n")
        return false, str
    elseif string.find(result, "warning") ~= nil then
        local str = "----------\nCOMPILATION WARNING\n----------\n" .. result .. "----------\nCOMPILATION WARNING\n----------\n"
        return true, str
    else
        local prettyResult = "-------\n" .. result .. "-------\n"
        return true, prettyResult
    end
end

local create_terminal_instance = function(filepath, permanent)
    local terminalCommands = {
        gnome = {
            begin = [[gnome-terminal -- bash -ic ']],
            ending = [[; read -p "Press Enter to Exit"']],
            permanentEnding = [[;read -p "Press Enter to Exit";exec bash']],
        },
        xfce = {
            begin = [[xfce4-terminal -e "bash -ic ']],
            ending = [[;read -p \"Press Enter to Exit\"'"]],
            permanentEnding = [[;read -p \"Press Enter to Exit\";exec bash'"]],
        },
        tmux = {
            begin = [[tmux split-window -h -l 10 ']],
            ending = [[;read -p "Press Enter to Exit"']],
            permanentEnding = [[;read -p "Press Enter to Exit";exec bash']],
        },
    }

    local command = ""

    if not permanent then
        if general.isOnWindows() == true then
            command = "start " .. filepath
        elseif opts.terminal == "ghostty" then
            command = terminalCommands[opts.backupTerminal].begin .. filepath .. terminalCommands[opts.backupTerminal].ending
        else
            command = terminalCommands[opts.terminal].begin .. filepath .. terminalCommands[opts.terminal].ending
        end
    else
        if general.isOnWindows() == true then
            command = "!start cmd /k " .. filepath
        elseif opts.terminal == "ghostty" then
            command = terminalCommands[opts.backupTerminal].begin .. filepath .. terminalCommands[opts.backupTerminal].permanentEnding
        else
            command = terminalCommands[opts.terminal].begin .. filepath .. terminalCommands[opts.terminal].permanentEnding
        end
    end

    vim.fn.system(command)
end

local create_terminal_from_type = function(filepath)
    if opts.runWindow == "floatingWindow" then
        local buf, win = general.create_floating_window(opts.vimFloatingWindowSize)
        vim.api.nvim_set_current_win(win)
        local jobid = vim.fn.jobstart(filepath, { term = true })
        general.setDelWinKeymapForBuffer()
    elseif opts.runWindow == "window" then
        vim.cmd "vsplit"
        vim.cmd.terminal(filepath)
        general.setDelWinKeymapForBuffer()
    elseif opts.runWindow == "external" then
        create_terminal_instance(filepath, false)
    elseif opts.runWindow == "external_permanent" then
        create_terminal_instance(filepath, true)
    end
end

local run_cpp = function()
    local filepath = cppGeneral.get_executable_path()

    if opts.buildType == "Debug" then
        if opts.debugger == "Raddbg" then
            raddbg.runRadDbg(filepath, { run = opts.debugRunStart })
            return
        elseif opts.debugger == "GDB" then
            require("dap").continue()
            require("dap-view").open()
            return
        end
    else
        create_terminal_from_type(filepath)
    end
end

--[[ API FOR KEYBINDS]]
API.build = function()
    print("Generating Build Files for " .. opts.buildType)
    cppGeneral.naPrint(cmake_generate_build())
end

API.compile = function()
    if vim.fn.isdirectory("build/" .. opts.buildType) == 0 then
        API.build()
    end

    local isCompiled, result = cmake_compile()
    cppGeneral.naPrint(result)
end

API.run = function()
    run_cpp()
end

API.compile_and_run = function()
    local isCompiled, compilationResult = cmake_compile()

    if isCompiled then
        cppGeneral.naPrint(compilationResult)
        run_cpp()
    else
        vim.notify(compilationResult)
    end
end

return API

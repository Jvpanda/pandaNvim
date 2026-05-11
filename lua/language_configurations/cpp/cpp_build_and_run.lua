local API = {}

local general = require "tools.general_functions"
local cpp_opts = require "language_configurations.cpp.cpp_opts"
local workspace = require "tools.workspace_tracker"
local raddbg = require "language_configurations.cpp.debug.raddbg"
local cppGeneral = require "language_configurations.cpp.cpp_general"

-- [[ Editor Environment Setup]]
local generate_environment_file = function(fileName)
    if vim.fn.filereadable(fileName) == 1 then
        return
    end
    local source = vim.fn.fnamemodify(vim.fn.expand "$MYVIMRC", ":h") .. "/lua/language_configurations/cpp/cpp_project_environment/" .. fileName
    local destination = workspace.getWorkspace()
    general.copy_file(source, destination)
end

API.create_or_switch_symlinks = function()
    if general.isOnWindows() then
        if vim.fn.filereadable(workspace.getWorkspace() .. "/build/compile_commands.json") == 1 then
            Await_System({ "del", workspace.getWindowsWorkspace() .. "build\\compile_commands.json" }, {})
        end
        Await_System({
            "mklink",
            workspace.getWindowsWorkspace() .. "build\\compile_commands.json",
            workspace.getWindowsWorkspace() .. "build\\" .. cpp_opts.buildType .. "\\compile_commands.json",
        }, {})
    else
        if vim.fn.filereadable(workspace.getWorkspace() .. "compile_commands.json") == 1 then
            Await_System({ "unlink", workspace.getWorkspace() .. "build/compile_commands.json" }, {})
        end
        local result = Await_System({
            "ln",
            workspace.getWorkspace() .. "build/" .. cpp_opts.buildType .. "/compile_commands.json",
            workspace.getWorkspace() .. "build/compile_commands.json",
        }, {})
    end
end

local cmake_generate_build = function()
    generate_environment_file ".editorconfig"
    generate_environment_file ".clang-format"
    generate_environment_file "CMakeUserPresets.json"
    generate_environment_file "CMakeLists.txt"
    generate_environment_file ".gitignore"

    local result = Await_System {
        "cmake",
        "--preset",
        cpp_opts.buildType,
    }
    API.create_or_switch_symlinks()
    return "----------\n" + result + "----------\n"
end

-- [[Compiling and running]]
local cmake_compile = function()
    vim.cmd.wa()
    print("Compiling... with build type " .. cpp_opts.buildType)

    local result = Await_System({ "cmake", "--build", "--preset", cpp_opts.buildType }, {})
    local prettyResult = "-------\n" .. result .. "-------\n"

    if string.find(prettyResult, "error") ~= nil then
        return false, "----------\nCOMPILATION ERROR\n----------\n" + result + "----------\nCOMPILATION ERROR\n----------\n"
    elseif string.find(prettyResult, "warning") ~= nil then
        return true, "----------\nCOMPILATION WARNING\n----------\n" + result + "----------\nCOMPILATION WARNING\n----------\n"
    else
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
        elseif cpp_opts.terminal == "ghostty" then
            command = terminalCommands[cpp_opts.backupTerminal].begin .. filepath .. terminalCommands[cpp_opts.backupTerminal].ending
        else
            command = terminalCommands[cpp_opts.terminal].begin .. filepath .. terminalCommands[cpp_opts.terminal].ending
        end
    else
        if general.isOnWindows() == true then
            command = "!start cmd /k " .. filepath
        elseif cpp_opts.terminal == "ghostty" then
            command = terminalCommands[cpp_opts.backupTerminal].begin .. filepath .. terminalCommands[cpp_opts.backupTerminal].permanentEnding
        else
            command = terminalCommands[cpp_opts.terminal].begin .. filepath .. terminalCommands[cpp_opts.terminal].permanentEnding
        end
    end

    vim.fn.system(command)
end

local create_terminal_from_type = function(filepath)
    if cpp_opts.runWindow == "floatingWindow" then
        local buf, win = general.create_floating_window(cpp_opts.vimFloatingWindowSize)
        vim.api.nvim_set_current_win(win)
        local jobid = vim.fn.jobstart(filepath, { term = true })
        general.setDelWinKeymapForBuffer()
    elseif cpp_opts.runWindow == "window" then
        vim.cmd "vsplit"
        vim.cmd.terminal(filepath)
        general.setDelWinKeymapForBuffer()
    elseif cpp_opts.runWindow == "external" then
        create_terminal_instance(filepath, false)
    elseif cpp_opts.runWindow == "external_permanent" then
        create_terminal_instance(filepath, true)
    end
end

local run_cpp = function()
    local filepath = cppGeneral.getExecutablePath()

    if cpp_opts.buildType == "Debug" then
        if cpp_opts.debugger == "Raddbg" then
            raddbg.runRadDbg(filepath, { run = cpp_opts.debugRunStart })
            return
        elseif cpp_opts.debugger == "GDB" then
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
    print("Generating Build Files for " .. cpp_opts.buildType)
    cppGeneral.naPrint(cmake_generate_build())
end

API.compile = function()
    if vim.fn.isdirectory("build/" .. cpp_opts.buildType) == 0 then
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

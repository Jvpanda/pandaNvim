local cpp_keybinds = {}
local general = require "tools.general_functions"
local workspace = require "tools.workspace_tracker"
local raddbg = require "language_configurations.cpp.raddbg"
local menu = require "language_configurations.cpp.cpp_menus"
local cmake = require "language_configurations.cpp.cmake_setup"
local cpp_opts = require "language_configurations.cpp.cpp_opts"

--Compiling and running
local function compileCPPWindows()
    if workspace.isWorkspaceSet() == false then
        return "Please set a home directory"
    end

    vim.cmd.wa()
    print("Compiling... with build flags " .. cpp_opts.buildType)
    local filepath = workspace.getWorkspace() .. "build/"
    local result = vim.fn.system { "cmake", "--build", filepath, "--config " .. cpp_opts.buildType }
    return result
end

local function runCPPWindows()
    if workspace.isWorkspaceSet() == false then
        vim.notify "Please set a home directory"
        return
    end

    local filepath = workspace.getWorkspace() .. "build/" .. cpp_opts.buildType .. "/execBinary.exe"

    if cpp_opts.buildType == "Debug" then
        raddbg.runRadDbg(filepath, { run = cpp_opts.debugRunStart })
        return
    end

    local oldCommandHeight = vim.o.cmdheight
    vim.o.cmdheight = 15

    if cpp_opts.runWindow == "floatingWindow" then
        general.create_floating_window(cpp_opts.vimFloatingWindowSize)
        vim.cmd.terminal(filepath)
        general.setDelWinKeymapForBuffer()
    elseif cpp_opts.runWindow == "window" then
        vim.cmd "vsplit"
        vim.cmd.terminal(filepath)
        general.setDelWinKeymapForBuffer()
    elseif cpp_opts.runWindow == "external" then
        vim.cmd("!start " .. filepath)
    elseif cpp_opts.runWindow == "external_permanent" then
        vim.cmd("!start cmd /k " .. filepath)
    end

    vim.o.cmdheight = oldCommandHeight
end

-- [[ KEYBINDS ]]
function cpp_keybinds.setupKeybinds()
    vim.keymap.set("n", "<F9>", function()
        if cpp_opts.buildType == "Debug" then
            general.customOptionsMenu({ "Switch To Release", "Debug Run Options", "Cmake" }, { rowCount = 4, widthRatio = 0.2 }, menu.handle_main_menu)
        else
            general.customOptionsMenu({ "Switch To Debug", "Release Run Options", "Cmake", "" }, { rowCount = 4, widthRatio = 0.2 }, menu.handle_main_menu)
        end
    end, { buffer = true })

    vim.keymap.set("n", "<F10>", function()
        cmake.createCmakeBuildFolder()
        cmake.createCmakeTxt()
        cmake.cmakeBuild()
    end)

    vim.keymap.set("n", "<F11>", function()
        local compilationResult = compileCPPWindows()
        vim.notify(compilationResult)
    end)

    vim.keymap.set("n", "<f12>", function()
        local compilationResult = "-------\n" .. compileCPPWindows() .. "-------\n"
        if
            string.find(compilationResult, "error") == nil
            and string.find(compilationResult, "warning") == nil
            and compilationResult ~= "Please set a home directory"
        then
            local oldCommandHeight = vim.o.cmdheight
            vim.o.cmdheight = 15
            print(compilationResult)
            vim.o.cmdheight = oldCommandHeight

            runCPPWindows()
        else
            vim.notify(compilationResult)
        end
    end, {})

    vim.keymap.set("n", "<S-f12>", function()
        runCPPWindows()
    end, {})
end

return cpp_keybinds

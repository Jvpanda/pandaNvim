local M = {}
local general = require "tools.general_functions"
local cpp_opts = require "language_configurations.cpp.cpp_opts"
local workspace = require "tools.workspace_tracker"
local raddbg = require "language_configurations.cpp.raddbg"

-- [[ Editor Environment Setup]]

local create_cmake_build_folders = function()
    if vim.fn.isdirectory "build" == 0 then
        vim.fn.mkdir "build"
        print "Created build dir"
    end
    if vim.fn.isdirectory "build/" .. cpp_opts.buildType == 0 then
        vim.fn.mkdir("build/" .. cpp_opts.buildType)
        print("Created " .. cpp_opts.buildType .. " Build Dir")
    end
end

local generate_environment_file = function(fileName)
    if vim.fn.filereadable(fileName) == 1 then
        return
    end
    local source = vim.fn.fnamemodify(vim.fn.expand "$MYVIMRC", ":h") .. "/lua/language_configurations/cpp/cpp_project_environment/" .. fileName
    local destination = workspace.getWorkspace()
    general.copy_file(source, destination)
end

M.create_or_switch_symlinks = function()
    if workspace.isWorkspaceSet() == false then
        return
    end

    --Note vim.system is async and newer, vim.fn.system is not and not newer
    if general.isOnWindows() then
        if vim.fn.filereadable(workspace.getWorkspace() .. "/build/compile_commands.json") == 1 then
            vim.fn.system("del " .. workspace.getWindowsWorkspace() .. "build\\compile_commands.json")
        end
        vim.fn.system(
            "mklink "
                .. workspace.getWindowsWorkspace()
                .. "build\\compile_commands.json "
                .. workspace.getWindowsWorkspace()
                .. "build\\"
                .. cpp_opts.buildType
                .. "\\compile_commands.json"
        )
    else
        if vim.fn.filereadable(workspace.getWorkspace() .. "compile_commands.json") == 1 then
            vim.fn.system("unlink " .. workspace.getWorkspace() .. "build/compile_commands.json")
        end
        vim.fn.system(
            "ln "
                .. workspace.getWorkspace()
                .. "build/"
                .. cpp_opts.buildType
                .. "/compile_commands.json "
                .. workspace.getWorkspace()
                .. "build/compile_commands.json"
        )
    end
end

M.cmake_generate_ninja_files = function()
    if workspace.isWorkspaceSet() == false then
        vim.notify "Please set a home directory"
        return
    end

    generate_environment_file ".editorconfig"
    generate_environment_file ".clang-format"
    generate_environment_file "CMakeUserPresets.json"
    generate_environment_file "CMakeLists.txt"
    create_cmake_build_folders()

    print("Generating Ninja Files for " .. cpp_opts.buildType)
    local result = vim.fn.system {
        "cmake",
        "--preset",
        cpp_opts.buildType,
    }
    vim.notify("----\n" .. result .. "----")
    M.create_or_switch_symlinks()
end

-- [[Compiling and running]]
M.cmake_compile = function()
    if workspace.isWorkspaceSet() == false then
        return "Please set a home directory"
    end

    if vim.fn.isdirectory("build/" .. cpp_opts.buildType) == 0 then
        M.cmake_generate_ninja_files()
    end

    vim.cmd.wa()
    print("Compiling... with build type " .. cpp_opts.buildType)
    local result = vim.fn.system { "cmake", "--build", "--preset", cpp_opts.buildType }
    return result
end

M.run_cpp = function()
    if workspace.isWorkspaceSet() == false then
        vim.notify "Please set a home directory"
        return
    end

    local oldCommandHeight = vim.o.cmdheight
    vim.o.cmdheight = 10

    local filepath = ""
    if general.isOnWindows() then
        filepath = workspace.getWorkspace() .. "build/" .. cpp_opts.buildType .. "/execBinary.exe"
    else
        filepath = workspace.getWorkspace() .. "build/" .. cpp_opts.buildType .. "/execBinary"
    end

    if cpp_opts.buildType == "Debug" and cpp_opts.debugRunStart ~= "No raddbg" and general.isOnWindows() == true then
        raddbg.runRadDbg(filepath, { run = cpp_opts.debugRunStart })
        return
    end

    local terminalName = "xfce4"

    if cpp_opts.runWindow == "floatingWindow" then
        local buf, win = general.create_floating_window(cpp_opts.vimFloatingWindowSize)
        vim.api.nvim_set_current_win(win)
        local jobid = vim.fn.jobstart(filepath, { term = true })
        print(jobid)
        general.setDelWinKeymapForBuffer()
    elseif cpp_opts.runWindow == "window" then
        vim.cmd "vsplit"
        vim.cmd.terminal(filepath)
        general.setDelWinKeymapForBuffer()
    elseif cpp_opts.runWindow == "external" then
        if general.isOnWindows() == true then
            vim.cmd("!start " .. filepath)
        else
            vim.cmd([[!]] .. terminalName .. [[-terminal --command="bash -ic ']] .. filepath .. [[; read -p \"Press Enter to Close\"'"]])
            -- vim.cmd([[!gnome-terminal -- bash -c "nvim -c 'lua vim.fn.jobstart(\"]] .. filepath .. [[\", { term = true });' -c 'autocmd BufLeave * exit' "]])
        end
    elseif cpp_opts.runWindow == "external_permanent" then
        if general.isOnWindows() == true then
            vim.cmd("!start cmd /k " .. filepath)
        else
            vim.cmd([[!gnome-terminal -- bash -c "]] .. filepath .. [[; exec bash"]])
        end
    end

    vim.o.cmdheight = oldCommandHeight
end
DebugKey("<leader>d", M.run_cpp, {})

M.compile_and_run = function()
    if workspace.isWorkspaceSet() == false then
        vim.notify "Please set a home directory"
        return
    end

    local compilationResult = "-------\n" .. M.cmake_compile() .. "-------\n"

    if
        string.find(compilationResult, "error") == nil
        and string.find(compilationResult, "warning") == nil
        and compilationResult ~= "Please set a home directory"
    then
        local oldCommandHeight = vim.o.cmdheight
        vim.o.cmdheight = 15
        print(compilationResult)
        vim.o.cmdheight = oldCommandHeight
        M.run_cpp()
    else
        vim.notify(compilationResult)
    end
end

-- [[ Additional Functions ]]
M.add_file_to_cmake_lists = function()
    if workspace.isWorkspaceSet() == false then
        print "Please set a workspace first"
        return
    end

    local file = io.open("CMakeLists.txt", "r")
    local fileTable = {}
    local sourceLine = 1

    if file ~= nil then
        for line in file:lines() do
            if line == "" then
                table.insert(fileTable, "\n")
            else
                table.insert(fileTable, line .. "\n")
            end
        end

        file:close()
    end

    for i in ipairs(fileTable) do
        if string.find(fileTable[i], "set") and string.find(fileTable[i], "PROJECT_SOURCES") then
            break
        end
        sourceLine = sourceLine + 1
    end

    for i in ipairs(fileTable) do
        if string.find(fileTable[i + sourceLine - 1], ")") then
            sourceLine = i + sourceLine - 1
            break
        end
    end

    local filepath = workspace.relativeWorkspacePath()

    local newLines = string.sub(fileTable[sourceLine], 1, -3)
    newLines = newLines .. "\n    " .. filepath .. vim.fn.expand "%:t"
    newLines = newLines .. "\n    " .. filepath .. vim.fn.expand "%:t:r" .. ".cpp)\n"
    fileTable[sourceLine] = newLines

    local fileOut = io.open("CMakeLists.txt", "w")
    if fileOut ~= nil then
        for i in pairs(fileTable) do
            fileOut:write(fileTable[i])
        end

        fileOut:close()
    end
    print "Cmake writen to succesfully"
end

return M

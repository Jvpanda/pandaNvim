local cpp_setup = {}
local general = require "tools.general_functions"
local workspace = require "tools.workspace_tracker"
local buildType = "Release"

--[[LSP Setttings]]

cpp_setup.LSPSetup = function()
    vim.lsp.enable "clangd"
    --may need to symlink if it doesn't work later
    --ln -s /path/to/myproject/build/compile_commands.json /path/to/myproject/
    vim.lsp.config("clangd", {
        capabilities = {
            offsetEncoding = { "utf-8", "utf-16" },
            textDocument = {
                completion = {
                    editsNearCursor = true,
                },
            },
        },

        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        -- on_attach (use "gF" to view): ../lsp/clangd.lua:60
        root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile_flags.txt", "configure.ac", ".git" },
    })
end

--[[Dap Setup]]
cpp_setup.dapSetup = function()
    local dap = require "dap"
    dap.adapters.lldb = {
        type = "executable",
        command = "lldb-dap", -- or if not in $PATH: "/absolute/path/to/codelldb"
        -- On windows you may have to uncomment this:
        detached = false,
    }

    --[[
    --For now I disable this adapter
    dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    }
    ]]

    dap.configurations.cpp = {
        {
            name = "Launch CPP",
            type = "lldb",
            request = "launch",
            program = function()
                return workspace.getWorkspace() .. "/build/Debug/execBinary.exe"
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
        --[[
            {
                name = "gdbDbg",
                type = "gdb",
                request = "launch",
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
                cwd = '${workspaceFolder}',
                stopAtBeginningOfMainSubprogram = false,
            },
            {
                name = "Attach to gdbserver :1234",
                type = "cppdbg",
                request = "launch",
                MIMode = "gdb",
                miDebuggerServerAddress = "localhost:1234",
                miDebuggerPath = "/usr/bin/gdb",
                --cwd = '${workspaceFolder}',
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
            },
            --]]
    }
end

-- [[Cmake Setup]]
local function createCmakeTxt()
    if vim.fn.filereadable "CMakeLists.txt" == 0 then
        local file = io.open("CMakeLists.txt", "w")
        if file ~= nil then
            file:write(
                "cmake_minimum_required(VERSION 3.10)\n"
                    .. 'project("FillerProjectName")\n'
                    .. "\nset(SOURCES src/main.cpp)\n"
                    .. "\nadd_executable(execBinary ${SOURCES})"
            )
            file:close()
            print "Created cmake txt"
        end
    end
end

local function addFileToCmakeTxt()
    local file = io.open("CMakeLists.txt", "r")
    local fileTable = {}
    local sourceLine = 1

    if workspace.isWorkspaceSet == false then
        vim.notify "Please set a workspace first"
        return
    end

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
        if string.find(fileTable[i], "SOURCE") then
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

    local newLines = string.sub(fileTable[sourceLine], 1, -3)
    newLines = newLines .. "\n            src/" .. vim.fn.expand "%:t"
    newLines = newLines .. "\n            src/" .. vim.fn.expand "%:t:r" .. ".cpp)\n"
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

local function createCmakeBuildFolder()
    if vim.fn.isdirectory "build" == 0 then
        vim.fn.mkdir "build"
        print "Created build dir"
    end
end

--Compiling and running
--W32
local function runCPPWindows()
    general.create_floating_window { width = 1.00, height = 0.75, col = 1, row = 0 }
    local filepath = workspace.getWorkspace() .. "build/" .. buildType .. "/execBinary.exe"
    vim.cmd.terminal(filepath)
end

local function compileCPPWindows()
    vim.cmd.wa()
    print(vim.cmd.wa())
    print("Compiling... with build type " .. buildType)
    local filepath = workspace.getWorkspace() .. "build/"
    local result = vim.fn.system { "cmake", "--build", filepath, "--config " .. buildType }
    return result
end
--WSL
local function runCPPWSL()
    general.create_floating_window { width = 0.25, height = 0.75, col = 1, row = 0 }
    local filepath = vim.fn.expand "%:p:h" .. "main.exe"
    vim.cmd.terminal(filepath)
end

--[[Keymaps]]
local function bindWindowsCompilerKeymaps()
    vim.keymap.set("n", "<F10>", function()
        if workspace.isWorkspaceSet() == true then
            createCmakeBuildFolder()
            createCmakeTxt()
            print "Building with standard build commands..."
            local result = vim.fn.system { "cmake", ".", "-DCMAKE_EXPORT_COMPILE_COMMANDS=1", "-B build/" }
            vim.notify("----\n" .. result .. "----")
        else
            vim.notify "Please set a home directory"
        end
    end)

    vim.keymap.set("n", "<F11>", function()
        if workspace.isWorkspaceSet() == true then
            local compilationResult = compileCPPWindows()
            vim.notify(compilationResult)
        else
            vim.notify "Please set a home directory"
        end
    end)

    vim.keymap.set("n", "<f12>", function()
        if workspace.isWorkspaceSet() == true then
            local compilationResult = "-------\n" .. compileCPPWindows() .. "-------\n"
            if string.find(compilationResult, "error") == nil and string.find(compilationResult, "warning") == nil then
                local oldCommandHeight = vim.o.cmdheight
                vim.o.cmdheight = 15
                print(compilationResult)
                vim.o.cmdheight = oldCommandHeight

                runCPPWindows()
                general.setDelWinKeymapForBuffer()
            else
                vim.notify(compilationResult)
            end
        else
            vim.notify "Please set a home directory"
        end
    end, {})

    vim.keymap.set("n", "<S-f12>", function()
        if workspace.isWorkspaceSet() == true then
            runCPPWindows()
            general.setDelWinKeymapForBuffer()
        else
            vim.notify "Please set a home directory"
        end
    end, {})

    vim.keymap.set("n", "<leader><F12>", "", { desc = "Compiler Settings" })

    vim.keymap.set("n", "<leader><F12>d", function()
        if buildType == "Release" then
            buildType = "Debug"
            print "Set To Debug"
        else
            buildType = "Release"
            print "Set To Release"
        end
    end, { desc = "Set to Release or Debug." })

    vim.keymap.set("n", "<leader><F12>a", function()
        addFileToCmakeTxt()
    end, { desc = "Adds current h and cpp to cmakelists" })
end

local function bindWSLCompileKeymaps()
    vim.keymap.set("n", "<F10>", function()
        vim.cmd.cd(vim.fn.expand "%:p:h")
    end, { desc = "Changes directory to the one of the current editing file" })

    vim.keymap.set("n", "<F11>", '<cmd>wa<CR><cmd>!g++ -g *.cpp -o "%:p:h/main.exe"<CR>', { silent = true, desc = "Build with c++" })

    --ctrl w w to switch between windows
    vim.keymap.set("n", "<f12>", function()
        runCPPWSL()
        general.setDelWinKeymapForBuffer()
    end, {})
end

function cpp_setup.setupKeybinds()
    if vim.fn.has "win32" == 0 then
        bindWSLCompileKeymaps()
    else
        bindWindowsCompilerKeymaps()
    end
end

return cpp_setup

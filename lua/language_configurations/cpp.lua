local cpp_setup = {}
local general = require "tools.general_functions"
local workspace = require "tools.workspace_tracker"
local buildType = "Release"

--[[LSP Setttings]]

local function switch_source_header(bufnr)
    local method_name = "textDocument/switchSourceHeader"
    local client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
    if not client then
        return vim.notify(("method %s is not supported by any servers active on the current buffer"):format(method_name))
    end
    local params = vim.lsp.util.make_text_document_params(bufnr)
    client.request(method_name, params, function(err, result)
        if err then
            error(tostring(err))
        end
        if not result then
            vim.notify "corresponding file cannot be determined"
            return
        end
        vim.cmd.edit(vim.uri_to_fname(result))
    end, bufnr)
end

local function symbol_info()
    local bufnr = vim.api.nvim_get_current_buf()
    local clangd_client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
    if not clangd_client or not clangd_client.supports_method "textDocument/symbolInfo" then
        return vim.notify("Clangd client not found", vim.log.levels.ERROR)
    end
    local win = vim.api.nvim_get_current_win()
    local params = vim.lsp.util.make_position_params(win, clangd_client.offset_encoding)
    clangd_client.request("textDocument/symbolInfo", params, function(err, res)
        if err or #res == 0 then
            -- Clangd always returns an error, there is not reason to parse it
            return
        end
        local container = string.format("container: %s", res[1].containerName) ---@type string
        local name = string.format("name: %s", res[1].name) ---@type string
        vim.lsp.util.open_floating_preview({ name, container }, "", {
            height = 2,
            width = math.max(string.len(name), string.len(container)),
            focusable = false,
            focus = false,
            border = "single",
            title = "Symbol Info",
        })
    end, bufnr)
end

---@class ClangdInitializeResult: lsp.InitializeResult
---@field offsetEncoding? string

cpp_setup.LSPSetup = function()
    vim.lsp.enable "clangd"
    vim.lsp.config("clangd", {
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        root_markers = {
            ".clangd",
            ".clang-tidy",
            ".clang-format",
            "compile_commands.json",
            "compile_flags.txt",
            "configure.ac", -- AutoTools
            ".git",
        },
        capabilities = {
            textDocument = {
                completion = {
                    editsNearCursor = true,
                },
            },
            offsetEncoding = { "utf-8", "utf-16" },
        },
        ---@param client vim.lsp.Client
        ---@param init_result ClangdInitializeResult
        on_init = function(client, init_result)
            if init_result.offsetEncoding then
                client.offset_encoding = init_result.offsetEncoding
            end
        end,
        on_attach = function()
            vim.api.nvim_buf_create_user_command(0, "LspClangdSwitchSourceHeader", function()
                switch_source_header(0)
            end, { desc = "Switch between source/header" })

            vim.api.nvim_buf_create_user_command(0, "LspClangdShowSymbolInfo", function()
                symbol_info()
            end, { desc = "Show symbol info" })
        end,
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
        if string.find(fileTable[i], "set") and string.find(fileTable[i], "SOURCE") then
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
        if workspace.isWorkspaceSet() then
            addFileToCmakeTxt()
        else
            print "Please set a valid home"
        end
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

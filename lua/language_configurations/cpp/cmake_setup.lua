local M = {}
local workspace = require "tools.workspace_tracker"
-- [[Cmake Setup]]
M.createCmakeTxt = function()
    if vim.fn.filereadable "CMakeLists.txt" == 0 then
        local file = io.open("CMakeLists.txt", "w")
        if file ~= nil then
            file:write(
                "cmake_minimum_required(VERSION 3.10)\n"
                    .. 'project("FillerProjectName")\n'
                    .. "\nset(PROJECT_SOURCES src/main.cpp)\n"
                    .. "\nadd_executable(execBinary ${PROJECT_SOURCES})"
            )
            file:close()
            print "Created cmake txt"
        end
    end
end

M.createCmakeBuildFolder = function()
    if vim.fn.isdirectory "build" == 0 then
        vim.fn.mkdir "build"
        print "Created build dir"
    end
end

M.cmakeBuild = function()
    if workspace.isWorkspaceSet() == false then
        vim.notify "Please set a home directory"
        return
    end

    print "Building with standard build commands..."
    local result = vim.fn.system { "cmake", ".", "-DCMAKE_EXPORT_COMPILE_COMMANDS=1", "-B build/" }
    vim.notify("----\n" .. result .. "----")
end

M.addFileToCmakeTxt = function()
    if workspace.isWorkspaceSet == false then
        vim.notify "Please set a workspace first"
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

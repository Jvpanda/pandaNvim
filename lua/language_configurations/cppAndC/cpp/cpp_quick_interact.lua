local workspace = require "tools.workspace_tracker"
local M = {}

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

local workspace_tracker = {}
local workspaceDirectory = "unset"
local markers = { cpp = { files = {}, folders = { "src", "git" } }, gdscript = { files = { "project.godot" }, folders = {} } }

workspace_tracker.isWorkspaceSet = function()
    if workspaceDirectory == "unset" then
        return false
    else
        return true
    end
end

workspace_tracker.getWorkspace = function()
    return workspaceDirectory
end

function workspace_tracker.relativeWorkspacePath()
    local currentPath = vim.fn.expand "%:p:h"
    currentPath = currentPath:gsub(workspaceDirectory:sub(1, -2), "")
    currentPath = currentPath:gsub("\\", "/")
    currentPath = currentPath .. "/"
    currentPath = currentPath:sub(2, -1)
    return currentPath
end

---@param files table Table of the names of the files to be searched for
---@return string workspaceDirectory
local function findWorkspaceByReadableFile(files)
    local currentDir = vim.fn.expand "%:p:h" .. "/"
    local safety = 0

    while currentDir ~= vim.fn.expand "~" .. "/" and safety < 30 do
        for _, searchFile in pairs(files) do
            if vim.fn.filereadable(currentDir .. searchFile) == 1 then
                return currentDir
            end
        end
        currentDir = vim.fn.fnamemodify(currentDir, ":p:h:h") .. "/"
        safety = safety + 1
    end

    return "unset"
end

---@param directory table Table of the names of the directory's to be searched for
---@return string workspaceDirectory
local function findWorkspaceByDirectory(directory)
    local currentDir = vim.fn.expand "%:p:h" .. "/"
    local safety = 0

    while currentDir ~= vim.fn.expand "~" .. "/" and safety < 30 do
        for _, searchDirectory in pairs(directory) do
            if vim.fn.isdirectory(currentDir .. searchDirectory) == 1 then
                return currentDir
            end
        end
        currentDir = vim.fn.fnamemodify(currentDir, ":p:h:h") .. "/"
        safety = safety + 1
    end

    return "unset"
end

---@param fileMarkers? table Table of the names of the directory's to be searched for
---@param folderMarkers? table Table of the names of the directory's to be searched for
workspace_tracker.setWorkspace = function(fileMarkers, folderMarkers)
    if workspace_tracker.isWorkspaceSet() == true then
        local input = vim.fn.input {
            default = "n",
            cancel_return = "abort",
            prompt = "Current Workspace: " .. workspace_tracker.getWorkspace() .. " Set New Workspace?(Y/n)",
        }
        if input == "n" or input == "N" then
            print "Home not set"
            return
        end
    end

    if fileMarkers ~= {} and fileMarkers ~= nil then
        workspaceDirectory = findWorkspaceByReadableFile(fileMarkers)
    end
    if folderMarkers ~= {} and folderMarkers ~= nil then
        workspaceDirectory = findWorkspaceByDirectory(folderMarkers)
    end

    workspaceDirectory = workspaceDirectory:gsub("\\", "/")

    if workspace_tracker.isWorkspaceSet() == true then
        print("Home set to " .. workspaceDirectory)
        vim.cmd.cd(workspaceDirectory)
    else
        print "Home could not be set"
    end
end

vim.keymap.set("n", "<F1>", function()
    local ft = vim.bo.ft
    workspace_tracker.setWorkspace(markers[ft].files, markers[ft].folders)
end)

vim.keymap.set("n", "<leader><F9>", function()
    print(workspace_tracker.relativeWorkspacePath())
end, { desc = "AFS" })

return workspace_tracker

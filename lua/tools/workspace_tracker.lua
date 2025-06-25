local workspace_tracker = {}
local workspaceDirectory = "unset"

workspace_tracker.getWorkspace = function()
    return workspaceDirectory
end

function workspace_tracker.workspaceRelativePath()
    if workspace_tracker.isWorkspaceSet() == false then
        print "Please set a workspace"
        return
    end
    local tempDir = vim.fn.expand "%:p:h" .. "/"
    local relativeDirPath = ""
    local safetyVar = 0
    while vim.fn.isdirectory(tempDir .. "src/") == 0 and tempDir ~= vim.fn.expand "~\\" and safetyVar < 30 do
        relativeDirPath = vim.fn.fnamemodify(tempDir, ":h:t") .. "/" .. relativeDirPath
        tempDir = vim.fn.fnamemodify(tempDir, ":p:h:h") .. "/"
        safetyVar = safetyVar + 1
    end
    if tempDir == vim.fn.expand "~/" or safetyVar == 30 then
        print "Home could not be set"
        return "unset"
    end
    return relativeDirPath
end

workspace_tracker.isWorkspaceSet = function()
    if workspaceDirectory == "unset" then
        return false
    else
        return true
    end
end

local function findWorkspace()
    local tempDir = vim.fn.expand "%:p:h" .. "\\"
    local safetyVar = 0
    while vim.fn.isdirectory(tempDir .. "src\\") == 0 and tempDir ~= vim.fn.expand "~\\" and safetyVar < 30 do
        tempDir = vim.fn.fnamemodify(tempDir, ":p:h:h") .. "\\"
        safetyVar = safetyVar + 1
    end
    if tempDir == vim.fn.expand "~\\" or safetyVar == 30 then
        print "Home could not be set"
        return "unset"
    end
    return tempDir
end

vim.keymap.set("n", "<F8>", function()
    if workspace_tracker.isWorkspaceSet() == false then
        workspaceDirectory = findWorkspace()
        print("Home set to " .. workspaceDirectory)
    elseif workspace_tracker.isWorkspaceSet() == true then
        local input = vim.fn.input {
            default = "n",
            cancel_return = "abort",
            prompt = "Current Workspace: " .. workspace_tracker.getWorkspace() .. " Set New Workspace?(Y/n)",
        }
        if input == "Y" or input == "y" then
            workspaceDirectory = findWorkspace()
            print("Home set to " .. workspaceDirectory)
        else
            print "Home not set"
        end
    end
    vim.cmd.cd(workspaceDirectory)
end)

return workspace_tracker

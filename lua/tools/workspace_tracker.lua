local general = require "tools.general_functions"
local menu = require "tools.ui.menuing"

local workspace_tracker = {}
local workspaceDirectory = "unset"

-- Every sub table is a list of markers. The order of the lists is order of importance
local markers = {
    c = { { ".clangd", ".clang-format", "build" }, { "CMakeLists.txt", ".git", "src" } },
    cpp = { { ".clangd", ".clang-format", "build" }, { "CMakeLists.txt", ".git", "src" } },
    cmake = { { ".clangd", ".clang-format", "build" }, { "CMakeLists.txt", ".git", "src" } },
    gdscript = { { "project.godot" } },
    lua = { { ".stylua.toml" } },
}

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

workspace_tracker.getWindowsWorkspace = function()
    return workspaceDirectory:gsub("/", "\\")
end

local findWorkspaces = function(pMarkers)
    local paths = {}
    local i = 1

    for _, markerTable in pairs(pMarkers) do
        local path = vim.fn.expand "%"
        local j = 1
        paths[i] = {}

        while path ~= nil do
            path = vim.fn.fnamemodify(path, ":h")
            path = vim.fs.root(path, markerTable)
            if path ~= nil then
                paths[i][j] = path
                j = j + 1
            end
        end
        i = i + 1
    end

    if paths == {} then
        paths = nil
    end

    return paths
end

local user_select_path = function(pathsTable)
    local endPath = nil

    for _, paths in pairs(pathsTable) do
        if #paths == 0 then
        elseif #paths == 1 then
            endPath = paths[1]
        else
            endPath = menu.customOptionsMenu(paths, { widthOffset = 59, heightOffset = #paths + 1 })
            break
        end
    end

    return endPath
end

---@param pMarkers table
local setWorkspace = function(pMarkers)
    if workspace_tracker.isWorkspaceSet() == true then
        local input = vim.fn.input {
            default = "Y",
            cancelreturn = "abort",
            prompt = "Current Workspace: " .. workspace_tracker.getWorkspace() .. " Set New Workspace?(Y/n)",
        }
        if input == "n" or input == "N" or input == "abort" then
            print "Home not set"
            return
        end
    end

    local paths = findWorkspaces(pMarkers)

    if paths == nil then
        print "No roots found"
        return
    end

    local result = user_select_path(paths)
    if result == nil then
        print "Home not set"
        return
    end

    workspaceDirectory = result

    if general.isOnWindows() then
        workspaceDirectory = workspaceDirectory:gsub("\\", "/")
    end

    print("Home set to " .. workspaceDirectory)
    vim.fn.chdir(workspaceDirectory)
end

workspace_tracker.apiSetWorkspace = function()
    local ft = vim.bo.ft
    if markers[ft] == nil then
        return false
    end
    setWorkspace(markers[ft])
    if ft == "c" or ft == "cpp" or ft == "cmake" then
        require("language_configurations.cppAndC.keybinds").setup_keybinds()
    elseif ft == "gdscript" then
        require("language_configurations.gdscript").setupKeybinds()
        require("language_configurations.gdscript").startListenServerForFileJumps()
    end
    return true
end

vim.keymap.set("n", "<F1>", function()
    local success = workspace_tracker.apiSetWorkspace()
    if not success then
        vim.notify "Filetype not supported"
    end
end)

vim.api.nvim_create_user_command("SetWorkspace", function()
    local success = workspace_tracker.apiSetWorkspace()
    if not success then
        vim.notify "Filetype not supported"
    end
end, {})

return workspace_tracker

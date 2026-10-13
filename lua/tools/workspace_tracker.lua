local general = require "tools.general_functions"
local menu = require "tools.ui.menuing"

local workspace_tracker = {}
local workspaceDirectory = "unset"

-- Every sub table is a list of markers. The order of the lists is order of importance
-- It will search only for build first thorugh the directories for exmaple. Then if it doesn't find it, on its second pass it will search for the rest
local markers = {
    c = { { "build" }, { ".clang-format", "CMakeLists.txt", ".clangd", ".git", "src" } },
    cpp = { { "build" }, { ".clang-format", "CMakeLists.txt", ".clangd", ".git", "src" } },
    cmake = { { "build" }, { ".clang-format", "CMakeLists.txt", ".clangd", ".git", "src" } },
    gdscript = { { "project.godot" } },
    lua = { { ".stylua.toml" } },
}

function workspace_tracker.getWorkspace()
    if workspaceDirectory == "unset" then
        return nil
    else
        return workspaceDirectory
    end
end

function workspace_tracker.getWindowsWorkspace()
    if workspaceDirectory == "unset" then
        return nil
    else
        return workspaceDirectory:gsub("/", "\\")
    end
end

local function findWorkspaces(pMarkers)
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

local function user_select_path(pathsTable)
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
local function setWorkspace(pMarkers)
    if workspaceDirectory ~= "unset" then
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

function workspace_tracker.apiSetWorkspace()
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

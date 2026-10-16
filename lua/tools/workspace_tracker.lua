local general = require "tools.general_functions"
local menu = require "tools.ui.menuing"

local workspace_tracker = {}
local workspaceDirectory = "unset"
local workspace_marker_number = 1

-- Every sub table is a list of markers. The order of the lists is order of importance
-- It will search only for build first thorugh the directories for exmaple. Then if it doesn't find it, on its second pass it will search for the rest
local markers = {
    c = { { "build" }, { "CMakeLists.txt" }, { ".clang-format", ".clangd", ".git", "src" } },
    cpp = { { "build" }, { "CMakeLists.txt" }, { ".clang-format", ".clangd", ".git", "src" } },
    cmake = { { "build" }, { "CMakeLists.txt" }, { ".clang-format", ".clangd", ".git", "src" } },
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

local function findWorkspaces(aMarkerTable)
    local paths = {}

    local path = vim.fn.expand "%"
    local found_paths = vim.fs.find(aMarkerTable, { follow = false, limit = math.huge, path = path, upward = true })

    local duplicates = {}

    for _, value in pairs(found_paths) do
        local name = vim.fn.fnamemodify(value, ":p:h")
        if not duplicates[name] then
            table.insert(paths, vim.fn.fnamemodify(value, ":p:h"))
            duplicates[name] = true
        end
    end

    if paths == {} then
        paths = nil
    end

    return paths
end

local function user_select_path(pathsTable)
    local endPath = nil

    if #pathsTable == 0 then
    elseif #pathsTable == 1 then
        endPath = pathsTable[1]
    else
        endPath = menu.customOptionsMenu(pathsTable, { widthOffset = 59, heightOffset = #pathsTable + 1 })
    end

    return endPath
end

---@param pMarkers table
local function setWorkspace(pMarkers, table_number)
    if workspaceDirectory ~= "unset" then
        local input = vim.fn.input {
            default = "Y",
            cancelreturn = "abort",
            prompt = "Current Workspace: " .. workspace_tracker.getWorkspace() .. " Set New Workspace?(Y/n)",
        }
        if input == "n" or input == "N" or input == "abort" then
            print "Home not set"
            return true
        end
    end

    local paths = findWorkspaces(pMarkers[table_number])

    if paths == nil then
        print "No roots found"
        return false
    end

    local result = user_select_path(paths)
    if result == nil then
        print "Home not set"
        return true
    end

    workspaceDirectory = result

    if general.isOnWindows() then
        workspaceDirectory = workspaceDirectory:gsub("\\", "/")
    end

    print("Home set to " .. workspaceDirectory)
    vim.fn.chdir(workspaceDirectory)
    return true
end

function workspace_tracker.apiSetWorkspace()
    local ft = vim.bo.ft
    if markers[ft] == nil then
        return false
    end

    if workspace_marker_number > #markers[ft] then
        workspace_marker_number = 1
    end

    local sentinel = false
    while workspace_marker_number <= #markers[ft] and sentinel == false do
        sentinel = setWorkspace(markers[ft], workspace_marker_number)
        workspace_marker_number = workspace_marker_number + 1
    end

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

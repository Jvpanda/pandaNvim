local general = require "tools.general_functions"
local workspace = require "tools.workspace_tracker"
local cpp_opts = require "language_configurations.cpp.cpp_opts"
local M = {}

M.getExecutablePath = function()
    if workspace.isWorkspaceSet() == false then
        return ""
    end

    local filepath = workspace.getWorkspace() .. "build/" .. cpp_opts.buildType .. "/execBinary"
    if general.isOnWindows() then
        filepath = filepath .. ".exe"
    end
    return filepath
end

-- not annoying Print
M.naPrint = function(input)
    local oldCommandHeight = vim.o.cmdheight
    vim.o.cmdheight = 20
    vim.print(input)
    vim.o.cmdheight = oldCommandHeight
end

return M

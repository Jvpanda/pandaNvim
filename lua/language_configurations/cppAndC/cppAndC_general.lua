local general = require "tools.general_functions"
local workspace = require "tools.workspace_tracker"
local opts = require "language_configurations.cppAndC.general_opts"
local M = {}

M.get_executable_path = function()
    local filepath = workspace.getWorkspace() .. "build/" .. opts.buildType .. "/execBinary"
    if general.isOnWindows() then
        filepath = filepath .. ".exe"
    end
    return filepath
end

M.find_elf = function()
    local filepath = workspace.getWorkspace() .. "build/" .. opts.buildType .. "/firmware.elf"
    return filepath
end

M.create_or_switch_symlinks = function()
    if general.isOnWindows() then
        if vim.fn.filereadable(workspace.getWorkspace() .. "/build/compile_commands.json") == 1 then
            Await_System({ "del", workspace.getWindowsWorkspace() .. "build\\compile_commands.json" }, {})
        end
        if vim.fn.filereadable(workspace.getWindowsWorkspace() .. "build\\" .. opts.buildType .. "\\compile_commands.json") then
            Await_System({
                "mklink",
                workspace.getWindowsWorkspace() .. "build\\compile_commands.json",
                workspace.getWindowsWorkspace() .. "build\\" .. opts.buildType .. "\\compile_commands.json",
            }, {})
        end
    else
        if vim.fn.filereadable(workspace.getWorkspace() .. "compile_commands.json") == 1 then
            Await_System({ "unlink", workspace.getWorkspace() .. "build/compile_commands.json" }, {})
        end
        if vim.fn.filereadable(workspace.getWorkspace() .. "build/" .. opts.buildType .. "/compile_commands.json") then
            local result = Await_System({
                "ln",
                workspace.getWorkspace() .. "build/" .. opts.buildType .. "/compile_commands.json",
                workspace.getWorkspace() .. "build/compile_commands.json",
            }, {})
        end
    end
end

-- not annoying Print
M.naPrint = function(input)
    local oldCommandHeight = vim.o.cmdheight
    vim.o.cmdheight = 20
    vim.print(input)
    vim.o.cmdheight = oldCommandHeight
end

return M

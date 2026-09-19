local M = {}
local opts = require "language_configurations.cppAndC.general_opts"
local workspace = require "tools.workspace_tracker"

-- [[ Editor Environment Setup]]

M.cmake_generate_build = function()
    local result = Await_System {
        "cmake",
        "--preset",
        opts.buildType,
    }

    -- Create symlink for compile commands
    local source = workspace.getWorkspace() .. "/build/" .. opts.buildType .. "/compile_commands.json"
    local destination = workspace.getWorkspace() .. "/build/compile_commands.json"
    -- Error is expected here for non existing synlinks, it is fine
    local success, err = vim.uv.fs_unlink(destination)

    success, err = vim.uv.fs_symlink(source, destination)
    if not success then
        print("ERROR IN SYMLINK CREATION: " .. err)
    end

    return "----------\n" .. result .. "----------\n"
end

-- [[Flashing and Bin]]
M.cmake_flash = function()
    local result = Await_System {
        "cmake",
        "--build",
        "--preset",
        "flash",
    }
    return "----------\n" .. result .. "----------\n"
end

M.cmake_bin = function()
    local result = Await_System {
        "cmake",
        "--build",
        "--preset",
        "bin",
    }
    return "----------\n" .. result .. "----------\n"
end

-- [[Compiling and running]]
M.cmake_compile = function()
    vim.cmd.wa()

    local result = Await_System({ "cmake", "--build", "--preset", opts.buildType }, {})

    if string.find(result, "error") ~= nil then
        local str = ("----------\nCOMPILATION ERROR\n----------\n" .. result .. "----------\nCOMPILATION ERROR\n----------\n")
        return false, str
    elseif string.find(result, "warning") ~= nil then
        local str = "----------\nCOMPILATION WARNING\n----------\n" .. result .. "----------\nCOMPILATION WARNING\n----------\n"
        return true, str
    else
        local prettyResult = "-------\n" .. result .. "-------\n"
        return true, prettyResult
    end
end

M.run = function()
    require("dap-view").open()
    require("dap").continue()
end
return M

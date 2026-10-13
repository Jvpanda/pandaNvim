local M = {}
local opts = require "language_configurations.cppAndC.general_opts"
local build_progress = require "tools.build_progress"
local workspace = require "tools.workspace_tracker"

-- [[ Editor Environment Setup]]

M.cmake_generate_build = function()
    local result = build_progress.await({ "cmake", "--preset", opts.buildType }, {}, {
        title = "CMake",
        message = "Generating build files (" .. opts.buildType .. ")",
        successMessage = "Build files generated",
        warningMessage = "Build files generated with warnings",
        errorMessage = "Build file generation failed",
    })

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
    local result = build_progress.await({ "cmake", "--build", "--preset", "flash" }, {}, {
        title = "CMake",
        message = "Flashing board",
        successMessage = "Board flashed",
        warningMessage = "Flashing finished with warnings",
        errorMessage = "Flashing failed",
    })
    return "----------\n" .. result .. "----------\n"
end

M.cmake_bin = function()
    local result = build_progress.await({ "cmake", "--build", "--preset", "bin" }, {}, {
        title = "CMake",
        message = "Creating bin file",
        successMessage = "Bin file created",
        warningMessage = "Bin creation finished with warnings",
        errorMessage = "Bin creation failed",
    })
    return "----------\n" .. result .. "----------\n"
end

-- [[Compiling and running]]
M.cmake_compile = function()
    vim.cmd.wa()

    local result = build_progress.await({ "cmake", "--build", "--preset", opts.buildType }, {}, {
        title = "CMake",
        message = "Compiling (" .. opts.buildType .. ")",
        successMessage = "Compilation succeeded",
        warningMessage = "Compilation warning",
        errorMessage = "Compilation failed",
    })

    local status = build_progress.classify(result)

    if status == "error" then
        local str = ("----------\nCOMPILATION ERROR\n----------\n" .. result .. "----------\nCOMPILATION ERROR\n----------\n")
        return false, str
    elseif status == "warning" then
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

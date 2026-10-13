local west_options = require "language_configurations.cppAndC.west_conf.west_options"
local build_progress = require "tools.build_progress"
local M = {}

-- [[ Editor Environment Setup]]
M.generate_build = function()
    local result = build_progress.await({ "west", "build", "-b", west_options.board }, {}, {
        title = "West",
        message = "Building (" .. west_options.board .. ")",
        successMessage = "West build succeeded",
        warningMessage = "West build warning",
        errorMessage = "West build failed",
    })
    return "----------\n" .. result .. "----------\n"
end

M.flash = function()
    local result = build_progress.await({ "west", "flash", "--runner", west_options.runner }, {}, {
        title = "West",
        message = "Flashing (" .. west_options.runner .. ")",
        successMessage = "Board flashed",
        warningMessage = "Flashing finished with warnings",
        errorMessage = "Flashing failed",
    })
    return "----------\n" .. result .. "----------\n"
end

return M

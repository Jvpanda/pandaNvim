local M = {}
-- [[ Editor Environment Setup]]
M.generate_build = function()
    local result = Await_System {
        "west",
        "build",
    }
    return "----------\n" .. result .. "----------\n"
end

M.flash = function()
    local result = Await_System {
        "west",
        "flash",
    }
    return "----------\n" .. result .. "----------\n"
end

return M

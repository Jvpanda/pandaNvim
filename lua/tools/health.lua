local check_version = function()
    local verstr = tostring(vim.version())
    vim.health.info ("Nvim Version: " .. verstr)

end

local check_external_reqs = function()
    -- Basic utils: `git`, `make`, `unzip`
    for _, exe in ipairs { "git", "make", "unzip", "rg" } do
        local is_executable = vim.fn.executable(exe) == 1
        if is_executable then
            vim.health.ok(string.format("Found executable: '%s'", exe))
        else
            vim.health.warn(string.format("Could not find executable: '%s'", exe))
        end
    end

    return true
end

return {
    check = function()
        vim.health.start "tools.health"

        vim.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

  Fix only warnings for plugins and languages you intend to use.]]

        local uv = vim.uv or vim.loop
        vim.health.info("System Information: " .. vim.inspect(uv.os_uname()))

        check_version()
        check_external_reqs()
    end,
}
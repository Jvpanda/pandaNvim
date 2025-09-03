local windowsDependencyList = { "git", "curl", "rg", "cmake", "tar" }
local linuxDependencyList = { "git", "curl", "rg", "make", "unzip" }

local check_version = function()
    local verstr = tostring(vim.version())
    vim.health.info("\nNvim Version: " .. verstr)
end

local checkCCompiler = function()
    local list = { "clang", "cl", "gcc", "zig" }
    local compiler = ""
    local valid = false

    for _, exe in ipairs(list) do
        local is_executable = vim.fn.executable(exe) == 1
        if is_executable then
            compiler = exe
            valid = true
            break
        end
    end

    if valid then
        vim.health.ok(string.format("Found executable: '%s'", compiler))
    else
        vim.health.error "No C Compiler found, treesitter and telescope fzf native will not work"
    end
end

local check_list_execs = function(pList)
    local list = pList or {}

    for _, exe in ipairs(list) do
        local is_executable = vim.fn.executable(exe) == 1
        if is_executable then
            vim.health.ok(string.format("Found executable: '%s'", exe))
        else
            vim.health.warn(string.format("Could not find executable: '%s'", exe))
        end
    end
end

local check_external_reqs = function()
    if vim.fn.has "win32" == 1 then
        check_list_execs(windowsDependencyList)
    else
        check_list_execs(linuxDependencyList)
    end

    return true
end

return {
    check = function()
        vim.health.start "Information"
        vim.health.info "NOTE: Not every warning is a 'must-fix'\n"
        check_version()
        local uv = vim.uv or vim.loop
        vim.health.info("System Information: " .. vim.inspect(uv.os_uname()) .. "\n")

        vim.health.start "PandaNvim Core Dependencies"
        vim.health.info "\n\nDependencies\n"
        checkCCompiler()
        check_external_reqs()
    end,
}

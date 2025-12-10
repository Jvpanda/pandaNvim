local M = {}

local function first_two_words(line)
    -- ^%s*     = ignore leading whitespace
    -- (%S+)    = first WORD
    -- %s*      = any separating whitespace
    -- (%S+)    = second WORD (optional)
    local w1, w2 = line:match "^%s*(%S+)%s*(%S+)"
    if w1 and w2 then
        return w1, w2
    elseif w1 then
        return w1
    else
        return ""
    end
end

M.create_getters_and_setters = function()
    local class = vim.fn.input { prompt = "Input a class: ", cancelreturn = "abort" }
    if class == "abort" then
        print "aborted"
        return
    end

    local lines = vim.fn.getreg("0", 0, true)
    vim.fn.setreg("a", "//Getters\n")
    vim.fn.setreg("b", "//Getters\n")

    for _, line in ipairs(lines) do
        local type, fname = first_two_words(line)
        if type == nil or fname == nil then
            break
        end

        if fname:sub(-1, -1) == ";" then
            fname = fname:sub(1, -2)
        end

        vim.fn.setreg("a", (vim.fn.getreg "a" .. "\t\t" .. type .. " "))
        vim.fn.setreg("a", (vim.fn.getreg "a" .. "get" .. fname .. "() const;\n"))
        vim.fn.setreg("b", (vim.fn.getreg "b" .. type .. " " .. class .. "::"))
        vim.fn.setreg("b", (vim.fn.getreg "b" .. "get" .. fname .. "() const\n{\n\treturn " .. fname .. ";\n}\n"))
    end

    vim.fn.setreg("a", (vim.fn.getreg "a" .. "\n//Setters\n"))
    vim.fn.setreg("b", (vim.fn.getreg "b" .. "\n//Setters\n"))

    for _, line in ipairs(lines) do
        local type, fname = first_two_words(line)
        if type == nil or fname == nil then
            break
        end

        if fname:sub(-1, -1) == ";" then
            fname = fname:sub(1, -2)
        end

        vim.fn.setreg("a", (vim.fn.getreg "a" .. "\t\tvoid set"))
        vim.fn.setreg("a", (vim.fn.getreg "a" .. fname .. "(" .. type .. " a" .. fname .. ");\n"))
        vim.fn.setreg("b", (vim.fn.getreg "b" .. "void " .. class .. "::set"))
        vim.fn.setreg("b", (vim.fn.getreg "b" .. fname .. "(" .. type .. " a" .. fname .. ")\n{\n\t" .. fname .. " = a" .. fname .. ";\n}\n"))
    end
end

return M

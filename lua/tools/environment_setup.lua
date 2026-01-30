local M = {}
---@param co any coroutine
---@param pid any
local recursePPID = function(co, pid) end

recursePPID = function(co, pid)
    vim.system({ "ps", "-o", "pid,ppid,comm", "-p", pid }, {}, function(obj)
        local sp = vim.split(obj.stdout, "\n")

        local lpid, ppid, cmd = sp[2]:match "^%s*(%S+)%s*(%S+)%s*(%S+)"
        local find = string.find(sp[2], "terminal")
        if find ~= nil then
            print "Found"
            print("PID: " .. lpid, "Command: " .. cmd, "PPID: " .. ppid)
            coroutine.resume(co, cmd)
            return
        elseif ppid == "0" then
            print "Terminal Not Found"
            return
        else
            print("PID: " .. lpid, "Command: " .. cmd, "PPID: " .. ppid)
            recursePPID(co, ppid)
        end
    end)
end

M.getTerminal = function(cppOptsModule)
    local co = coroutine.create(function()
        print "test"
        local initialPID = tostring(vim.fn.getpid())
        local result = coroutine.yield(function(co)
            recursePPID(co, initialPID)
        end)
        local terminalName = result:match "^%w+"
        cppOptsModule.terminal = terminalName
        print(cppOptsModule.terminal)
    end)

    local ok, yielded = coroutine.resume(co)
    print(ok, yielded)

    if not ok then
        error(yielded)
        return
    end

    yielded(co)
end

return M

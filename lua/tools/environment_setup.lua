-- ---@param pid any
-- ---@return integer
local recursePPID = function(pid) end

recursePPID = function(co, pid)
    local termPID = 0
    local ppid = vim.system({ "ps", "-o", "pid,ppid,comm", "-p", pid }, {}, function(obj)
        local sp = vim.split(obj.stdout, "\n")

        local lpid, ppid, cmd = sp[2]:match "^%s*(%S+)%s*(%S+)%s*(%S+)"
        local find = string.find(sp[2], "terminal")
        if find ~= nil then
            print "Found"
            print("PID: " .. lpid, "Command: " .. cmd, "PPID: " .. ppid)
            termPID = lpid
            coroutine.resume(co, lpid)
            return lpid
        else
            print("PID: " .. lpid, "Command: " .. cmd, "PPID: " .. ppid)
            termPID = recursePPID(co, ppid)
        end
    end)
    return termPID
end

local func2 = function()
    local initialPID = tostring(vim.fn.getpid())
    local result = coroutine.yield(function(co)
        recursePPID(co, initialPID)
    end)
    print("FUNC: ", result)
end

local co = coroutine.create(func2)
local ok, yielded = coroutine.resume(co)
print(ok, yielded)

if not ok then
    error(yielded)
end
if type(yielded) == "function" then
    yielded(co)
end

-- P(vim.fn.getwininfo(1000))
-- P(vim.fn.winlayout(1))

local M = {}
---@param co any coroutine
---@param pid any
local recursePPID = function(co, pid) end

local terminal_table = {
    "ghostty",
    "gnome",
    "xfce",
    "tmux",
}

recursePPID = function(co, pid)
    vim.system({ "ps", "-o", "pid,ppid,comm", "-p", pid }, {}, function(obj)
        local sp = vim.split(obj.stdout, "\n")

        local lpid, ppid, cmd = sp[2]:match "^%s*(%S+)%s*(%S+)%s*(%S+)"
        local find = nil

        for index, terminal in pairs(terminal_table) do
            find = string.find(sp[2], terminal)
            if find ~= nil then
                find = terminal
                break
            end
        end

        if find ~= nil then
            -- print "Found"
            -- print("PID: " .. lpid, "Command: " .. cmd, "PPID: " .. ppid)
            coroutine.resume(co, find)
            return
        elseif ppid == "0" then
            print "Terminal Not Found"
            return
        else
            -- print("PID: " .. lpid, "Command: " .. cmd, "PPID: " .. ppid)
            recursePPID(co, ppid)
        end
    end)
end

local getBackupTerminal = function()
    if vim.fn.executable "gnome-terminal" then
        return "gnome"
    elseif vim.fn.executable "xfce4-terminal" then
        return "xfce"
    elseif vim.fn.executable "tmux" then
        return "tmux"
    end
end

M.getTerminalForCPP = function(cppOptsModule)
    cppOptsModule = cppOptsModule or { terminal = "" }

    local co = coroutine.create(function()
        local initialPID = tostring(vim.fn.getpid())
        local result = coroutine.yield(function(co)
            recursePPID(co, initialPID)
        end)
        cppOptsModule.terminal = result
        cppOptsModule.backupTerminal = getBackupTerminal()
    end)

    local ok, yielded = coroutine.resume(co)

    if not ok then
        error(yielded)
        return
    end

    yielded(co)
end

return M

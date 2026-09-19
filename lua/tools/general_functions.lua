local funcs = {}
local window = require "tools.ui.windowing"

---@return boolean
funcs.isOnWindows = function()
    if vim.fn.has "Win32" == 0 then
        return false
    else
        return true
    end
end

-- Copies files from the specified folder to the cwd
funcs.generate_environment_file = function(fileName)
    local destination = vim.fn.getcwd() .. "/" .. vim.fn.fnamemodify(fileName, ":t")
    if vim.fn.filereadable(vim.fn.fnamemodify(fileName, ":t")) == 1 then
        return
    end

    local source = vim.fn.fnamemodify(vim.fn.expand "$MYVIMRC", ":h") .. "/lua/tools/environment_files/" .. fileName
    local success, err = vim.uv.fs_copyfile(source, destination)
    if not success then
        print("COPY ERROR: " .. err)
        return
    end
end

-- not annoying Print
funcs.naPrint = function(input)
    local oldCommandHeight = vim.o.cmdheight
    vim.o.cmdheight = 20
    vim.print(input)
    vim.o.cmdheight = oldCommandHeight
end

-- [[ Global Functions ]]

-- Assing this
DebugKey = function(keymap, func, ...)
    keymap = keymap or "<leader>l"
    local params = unpack(...) or nil
    vim.keymap.set("n", keymap, function()
        func(params)
    end)
end

-- Global Async features
--[[Explanation of how these work, 
    Basically we create the coroutine, then define this function that runs it
    Now it will run until it hits a yield, now we can pass things back and forth from the resume and yield
    It will populate the ok and result variable when resume is popped back from when a yield is called
    Now we actually sent back a function, we check everything and if it's a function
    We will run this function, it will do 2 things, it will run the system command then on exit
    it will call the function that we put in the parameter. That function that we call will have the parameter
    obj.stdout. This happens to be the step function, so it will then return and resume using this stdout 
    meaning that it will pass the stdout to the yields initial call, the thing is the because we returned the
    yield from the await system, it will actually just copy that return value to the response. And that's how it's done
    --]]
Async = function(f, ...)
    local co = coroutine.create(f)
    local function step(...)
        local args = (...)

        vim.schedule(function()
            local ok, result = coroutine.resume(co, args)
            if not ok then
                error("MY ERROR: " .. result)
            end
            if coroutine.status(co) == "dead" then
                return
            end
            if type(result) == "function" then
                result(step)
            end
        end)
    end
    step(...)
end

Await_System = function(cmd, opts)
    return coroutine.yield(function(resolve)
        vim.system(cmd, opts or {}, function(obj)
            resolve(obj.stdout)
        end)
    end)
end

return funcs

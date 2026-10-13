---@class BuildProgressMeta
---@field title? string
---@field message? string
---@field group? string
---@field successMessage? string
---@field warningMessage? string
---@field errorMessage? string
---@field notifyOnError? boolean

local M = {}

local function no_op_handle()
    return {
        report = function() end,
        finish = function() end,
        cancel = function() end,
    }
end

local function first_error_line(result)
    for line in string.gmatch(result, "[^\r\n]+") do
        if string.find(line, "error") ~= nil then
            return line
        end
    end
end

---@param buffer string
---@return integer|nil percent
local function parse_percent(buffer)
    local percent
    for done, total in string.gmatch(buffer, "%[(%d+)/(%d+)%]") do
        total = tonumber(total)
        if total > 0 then
            percent = math.floor(tonumber(done) / total * 100)
        end
    end
    for match in string.gmatch(buffer, "%[%s*(%d+)%%%]") do
        percent = tonumber(match)
    end
    return percent
end

---@param meta BuildProgressMeta|nil
function M.create(meta)
    meta = meta or {}

    local ok, handle = pcall(function()
        return require("fidget.progress.handle").create {
            title = meta.title or "Build",
            message = meta.message,
            lsp_client = { name = meta.group or "build" },
        }
    end)

    if ok and handle then
        return handle
    end

    return no_op_handle()
end

---@param result string
---@return "error"|"warning"|"success"
function M.classify(result)
    if string.find(result, "error") ~= nil then
        return "error"
    elseif string.find(result, "warning") ~= nil then
        return "warning"
    end
    return "success"
end

---@param meta BuildProgressMeta
---@param result string
function M.notifyError(meta, result)
    if meta.notifyOnError == false then
        return
    end

    local ok, fidget = pcall(require, "fidget")
    if not ok then
        return
    end

    fidget.notify(meta.errorMessage or first_error_line(result) or "Build failed", vim.log.levels.ERROR, {
        annote = meta.title or "Build",
        key = "build_progress",
    })
end

---@param cmd string[]
---@param sysOpts table|nil
---@param meta BuildProgressMeta|nil
---@return string result
function M.await(cmd, sysOpts, meta)
    meta = meta or {}

    local handle = M.create(meta)
    local chunks = {}
    local carry = ""
    local lastPercent

    local opts = vim.tbl_extend("force", sysOpts or {}, {
        stdout = function(_, data)
            if not data or data == "" then
                return
            end

            chunks[#chunks + 1] = data

            local buffer = carry .. data
            carry = buffer:sub(-24)

            local percent = parse_percent(buffer)
            if percent and percent ~= lastPercent then
                lastPercent = percent
                vim.schedule(function()
                    handle:report { message = meta.message, percentage = percent }
                end)
            end
        end,
    })

    local result = coroutine.yield(function(resolve)
        vim.system(cmd, opts, function()
            resolve(table.concat(chunks))
        end)
    end)

    local status = M.classify(result)

    if status == "error" then
        handle:report { message = meta.errorMessage or "Build failed" }
        handle:finish()
        M.notifyError(meta, result)
    elseif status == "warning" then
        handle:report { message = meta.warningMessage or "Build finished with warnings" }
        handle:finish()
    else
        handle:report { message = meta.successMessage or "Build succeeded" }
        handle:finish()
    end

    return result
end

return M

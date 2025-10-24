local M = {}
local general = require "tools.general_functions"

BufferList = {}
FavoriteBuffers = {}
RecentBuffers = {}

local getBuffersById = function()
    local listedBuffers = {}
    local buffersNumList = vim.api.nvim_list_bufs()
    for keyIndex in ipairs(buffersNumList) do
        if vim.fn.buflisted(buffersNumList[keyIndex]) == 1 then
            table.insert(listedBuffers, buffersNumList[keyIndex])
        end
    end
    return listedBuffers
end

local populateBufferList = function()
    local bufferIdList = getBuffersById()
    for _, keyIndex in pairs(bufferIdList) do
        if BufferList[keyIndex] == nil and FavoriteBuffers[keyIndex] == nil and RecentBuffers[keyIndex] == nil then
            table.insert(BufferList, keyIndex, { name = vim.fn.bufname(keyIndex):gsub("^(.*[/\\])", ""), fullPath = vim.fn.bufname(keyIndex), id = keyIndex })
        end
    end
end

local deleteDeadBuffers = function()
    for key_index in pairs(BufferList) do
        if vim.fn.bufexists(key_index) == 0 or vim.fn.buflisted(key_index) == 0 then
            BufferList[key_index] = nil
        end
    end
    for key_index in pairs(FavoriteBuffers) do
        if vim.fn.bufexists(key_index) == 0 or vim.fn.buflisted(key_index) == 0 then
            FavoriteBuffers[key_index] = nil
        end
    end
    for key_index in pairs(RecentBuffers) do
        if vim.fn.bufexists(key_index) == 0 or vim.fn.buflisted(key_index) == 0 then
            RecentBuffers[key_index] = nil
        end
    end
end

local getBufferIdUnderCursor = function()
    local firstSpace = vim.fn.getline("."):find " "
    local num = vim.fn.getline("."):sub(1, firstSpace - 1)
    local numConversion = tonumber(num) + 0
    return numConversion
end

local enqueueRecentBufferList = function(bufferId)
    if RecentBuffers[bufferId] ~= nil or FavoriteBuffers[bufferId] ~= nil then
        return
    end

    table.insert(RecentBuffers, bufferId, BufferList[bufferId])
    RecentBuffers[bufferId].recency = 0
    BufferList[bufferId] = nil

    for key_index in pairs(RecentBuffers) do
        RecentBuffers[key_index].recency = RecentBuffers[key_index].recency + 1

        if RecentBuffers[key_index].recency >= 4 then
            RecentBuffers[key_index].recency = nil
            table.insert(BufferList, key_index, RecentBuffers[key_index])
            RecentBuffers[key_index] = nil
        end
    end
end

local markAndUnmarkFavorite = function(bufferId)
    if FavoriteBuffers[bufferId] == nil then
        if BufferList[bufferId] ~= nil then
            table.insert(FavoriteBuffers, bufferId, BufferList[bufferId])
            BufferList[bufferId] = nil
        elseif RecentBuffers[bufferId] ~= nil then
            table.insert(FavoriteBuffers, bufferId, RecentBuffers[bufferId])
            RecentBuffers[bufferId] = nil
        end

        local line = vim.fn.getline "."
        vim.api.nvim_del_current_line()
        local name = vim.api.nvim_buf_get_name(0)
        vim.fn.appendbufline(name, 0, line)
    else
        table.insert(BufferList, bufferId, FavoriteBuffers[bufferId])
        FavoriteBuffers[bufferId] = nil

        local line = vim.fn.getline "."
        vim.api.nvim_del_current_line()
        local name = vim.api.nvim_buf_get_name(0)
        local endOfBuffer = vim.api.nvim_buf_line_count(0)
        vim.fn.appendbufline(name, endOfBuffer, line)
    end
end

local isDividerLine = function(line)
    local lineLen = line:len()
    local lineStart = line:sub(1, -lineLen)
    if lineStart == "-" then
        return true
    else
        return false
    end
end

local selectBuffer = function(line)
    if isDividerLine(line) then
        return
    end

    local firstSpace = line:find " "
    local num = line:sub(1, firstSpace - 1)
    local bufferId = tonumber(num) + 0

    enqueueRecentBufferList(bufferId)
    vim.api.nvim_set_current_buf(bufferId)
end

local function setUIBufferUIKeymaps(contextBuffer)
    vim.keymap.set("n", "D", function()
        local line = vim.fn.getline "."
        if isDividerLine(line) then
            return
        end

        local numConversion = getBufferIdUnderCursor()

        BufferList[numConversion] = nil
        FavoriteBuffers[numConversion] = nil
        RecentBuffers[numConversion] = nil

        if contextBuffer == numConversion then
            general.deleteCurrentWindow()
            vim.api.nvim_buf_delete(numConversion, {})
        else
            vim.api.nvim_buf_delete(numConversion, {})
            vim.api.nvim_del_current_line()
        end
    end, { buffer = true })

    vim.keymap.set("n", "F", function()
        local line = vim.fn.getline "."
        if isDividerLine(line) then
            return
        end

        local bufferId = getBufferIdUnderCursor()
        markAndUnmarkFavorite(bufferId)
    end, { buffer = true })

    vim.keymap.set("n", "P", function()
        local line = vim.fn.getline "."
        if isDividerLine(line) then
            return
        end

        local path = vim.fn.bufname(getBufferIdUnderCursor())
        local rootFolder = vim.fn.fnamemodify(path, ":h:t")
        local tail = vim.fn.fnamemodify(path, ":t")
        vim.api.nvim_set_current_line(rootFolder .. "/" .. tail)
    end, { buffer = true })
end

local function create_buffer_menu()
    local contextBuffer = vim.api.nvim_get_current_buf()
    local menuTable = {}
    local winWidth = 0
    local bufNameLen = 0
    local dividerString = "---"

    for key_index in pairs(FavoriteBuffers) do
        table.insert(menuTable, FavoriteBuffers[key_index].id .. " " .. FavoriteBuffers[key_index].name)
        if FavoriteBuffers[key_index] ~= nil then
            bufNameLen = FavoriteBuffers[key_index].name:len()
            if bufNameLen > winWidth then
                winWidth = bufNameLen + 3
            end
        end
    end

    local i = 0
    while i < winWidth do
        dividerString = dividerString .. "-"
        i = i + 1
    end

    table.insert(menuTable, dividerString)

    for key_index in pairs(RecentBuffers) do
        table.insert(menuTable, RecentBuffers[key_index].id .. " " .. RecentBuffers[key_index].name)
        if RecentBuffers[key_index] ~= nil then
            bufNameLen = RecentBuffers[key_index].name:len()
            if bufNameLen > winWidth then
                winWidth = bufNameLen + 3
            end
        end
    end

    while i < winWidth do
        dividerString = dividerString .. "-"
        i = i + 1
    end

    table.insert(menuTable, dividerString)

    for key_index in pairs(BufferList) do
        table.insert(menuTable, BufferList[key_index].id .. " " .. BufferList[key_index].name)
        if BufferList[key_index] ~= nil then
            bufNameLen = BufferList[key_index].name:len()
            if bufNameLen > winWidth then
                winWidth = bufNameLen + 3
            end
        end
    end
    local windowOpts = { columnCharCount = winWidth + 7, rowCount = #menuTable + 3 }

    general.customOptionsMenu(menuTable, windowOpts, selectBuffer)

    vim.fn.cursor(1, 1)

    setUIBufferUIKeymaps(contextBuffer)
end

M.setupBufferSelector = function()
    vim.keymap.set("n", "<leader>j", function()
        populateBufferList()
        deleteDeadBuffers()
        create_buffer_menu()
    end, { noremap = true, desc = "Buffer Menu" })
end

return M

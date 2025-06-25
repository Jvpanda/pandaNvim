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

    print("REMOVING: " .. bufferId)
    table.insert(RecentBuffers, bufferId, BufferList[bufferId])
    RecentBuffers[bufferId].recency = 0
    BufferList[bufferId] = nil

    for key_index in pairs(RecentBuffers) do
        print(key_index)
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
        print "THIS"
        table.insert(BufferList, bufferId, FavoriteBuffers[bufferId])
        FavoriteBuffers[bufferId] = nil

        local line = vim.fn.getline "."
        vim.api.nvim_del_current_line()
        local name = vim.api.nvim_buf_get_name(0)
        local endOfBuffer = vim.api.nvim_buf_line_count(0)
        vim.fn.appendbufline(name, endOfBuffer, line)
    end
end

local function setUIBufferUIKeymaps(contextBuffer)
    vim.keymap.set("n", "<Esc>", function()
        general.deleteCurrentWindow()
    end, { buffer = true })

    vim.keymap.set("n", "D", function()
        local line = vim.fn.getline "."
        if line == "---------------------" then
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
        if line == "---------------------" then
            return
        end

        local bufferId = getBufferIdUnderCursor()
        markAndUnmarkFavorite(bufferId)
    end, {})

    vim.keymap.set("n", "<CR>", function()
        local line = vim.fn.getline "."
        if line == "---------------------" then
            return
        end

        local bufferId = getBufferIdUnderCursor()

        enqueueRecentBufferList(bufferId)

        general.deleteCurrentWindow()
        vim.api.nvim_set_current_buf(bufferId)
    end, { buffer = true })
end

local function create_buffer_menu()
    local contextBuffer = vim.api.nvim_get_current_buf()
    local menuTable = {}

    for key_index in pairs(FavoriteBuffers) do
        table.insert(menuTable, FavoriteBuffers[key_index].id .. " " .. FavoriteBuffers[key_index].name)
    end

    table.insert(menuTable, "---------------------")

    for key_index in pairs(RecentBuffers) do
        table.insert(menuTable, RecentBuffers[key_index].id .. " " .. RecentBuffers[key_index].name)
    end

    table.insert(menuTable, "---------------------")

    for key_index in pairs(BufferList) do
        table.insert(menuTable, BufferList[key_index].id .. " " .. BufferList[key_index].name)
    end

    general.customOptionMenu(menuTable, { width = 0.15, lineHeight = #menuTable + 3 })

    if #RecentBuffers == 0 then
        vim.fn.cursor(2, 1)
    else
        vim.fn.cursor(1, 1)
    end
    setUIBufferUIKeymaps(contextBuffer)
end

vim.keymap.set("n", "<leader>j", function()
    populateBufferList()
    deleteDeadBuffers()
    create_buffer_menu()
end, { noremap = true, desc = "Buffer Menu" })

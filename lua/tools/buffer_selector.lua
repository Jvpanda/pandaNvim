local general = require 'tools.general_functions'

--BUffer Selector
local bufferHistory = {}

local function getBuffers()
    local fullBufferList = {}
    local buffersNumList = vim.api.nvim_list_bufs()

    local uiIndex = 1
    for keyIndex in ipairs(buffersNumList) do
        if vim.fn.buflisted(buffersNumList[keyIndex]) == 1 then
            fullBufferList[uiIndex] = buffersNumList[keyIndex] .. ' '
            fullBufferList[uiIndex] = fullBufferList[uiIndex] .. vim.fn.bufname(buffersNumList[keyIndex]):gsub('^(.*[/\\])', '')
            uiIndex = uiIndex + 1
        end
    end

    local removalCount = 0
    for a = 1, #bufferHistory do
        local exists = false
        for j = 1, #fullBufferList do
            if fullBufferList[j] == bufferHistory[a - removalCount] then
                exists = true
            end
        end
        if exists == false then
            table.remove(bufferHistory, a - removalCount)
            removalCount = removalCount + 1
        end
    end

    removalCount = 0
    for a = 1, #fullBufferList do
        for j = 1, #bufferHistory do
            if fullBufferList[a - removalCount] == bufferHistory[j] then
                table.remove(fullBufferList, a - removalCount)
                removalCount = removalCount + 1
            end
        end
    end

    return fullBufferList
end

local function setUIBufferUIKeymaps(contextBuffer)
    vim.keymap.set('n', '<Esc>', function()
        general.deleteCurrentWindow()
    end, { buffer = true })
    vim.keymap.set('n', '<CR>', function()
        local line = vim.fn.getline '.'
        local hasElement = false
        if line == '--------------' then
            return
        end

        for i = 1, 3 do
            if bufferHistory[i] == line then
                hasElement = true
            end
            i = i + 1
        end
        if not hasElement then
            table.insert(bufferHistory, 1, line)
        end

        if #bufferHistory > 3 then
            table.remove(bufferHistory, 4)
        end

        local num = line:match '^(%S* )'
        local numConversion = tonumber(num) + 0
        general.deleteCurrentWindow()
        vim.api.nvim_set_current_buf(numConversion)
    end, { buffer = true })
    vim.keymap.set('n', 'D', function()
        local firstSpace = vim.fn.getline('.'):find ' '
        local num = vim.fn.getline('.'):sub(1, firstSpace - 1)
        local numConversion = tonumber(num) + 0
        for v in ipairs(bufferHistory) do
            if bufferHistory[v] == vim.fn.getline '.' then
                table.remove(bufferHistory, v)
            end
        end
        if contextBuffer == numConversion then
            general.deleteCurrentWindow()
            vim.api.nvim_buf_delete(numConversion, {})
        else
            vim.api.nvim_buf_delete(numConversion, {})
            vim.api.nvim_del_current_line()
        end
    end, { buffer = true })
end

local function create_buffer_menu()
    local contextBuffer = vim.api.nvim_get_current_buf()
    local bufferList = getBuffers()
    general.create_floating_window { width = 0.15, customHeight = 3 + #bufferList + #bufferHistory }
    vim.api.nvim_buf_set_lines(0, 0, #bufferHistory, false, bufferHistory)
    vim.api.nvim_buf_set_lines(0, #bufferHistory, #bufferHistory, false, { '----------------------' })
    vim.api.nvim_buf_set_lines(0, #bufferHistory + 1, -1, false, bufferList)
    if #bufferHistory == 0 then
        vim.fn.cursor(2, 1)
    else
        vim.fn.cursor(1, 1)
    end
    setUIBufferUIKeymaps(contextBuffer)
end

vim.keymap.set('n', '<leader>j', function()
    create_buffer_menu()
end, { noremap = true, desc = 'Buffer Menu' })

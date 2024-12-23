M = {}
-- [[ Basic Autocommands ]]
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- [[ My Commands ]]
-- Starts the godot server listener
vim.api.nvim_create_user_command('Godot', function(opts)
    if opts.args == 'start' then
        vim.fn.serverstart '127.0.0.1:6004'
        print 'Listen Server Started'
    elseif opts.args == 'stop' then
        vim.fn.serverstop '127.0.0.1:6004'
        print 'Listen Server Stopped'
    else
        print 'Please enter valid command'
    end
end, { nargs = 1 })

vim.api.nvim_create_user_command('GodotPassCMD', function(opts)
    local opt2Num = tonumber(opts.fargs[2]) + 1
    local opt3Num = tonumber(opts.fargs[3])
    if vim.fn.has 'win32' == 0 then
        local wslpath = vim.fn.system('wslpath ' .. opts.fargs[1])
        vim.cmd.n(wslpath)
        vim.api.nvim_win_set_cursor(0, { opt2Num, opt3Num })
    else
        vim.cmd.n(opts.fargs[1])
        vim.api.nvim_win_set_cursor(0, { opt2Num, opt3Num })
    end
end, { nargs = '*' })

P = function(v)
    print(vim.inspect(v))
    return v
end

--{{My custom functions}}
--create_floating_window
local function create_floating_window(opts)
    opts = opts or {}
    if opts.customHeight then
        opts.height = 0
    end
    local width = math.floor(vim.o.columns * (opts.width or 0.5))
    local height = math.floor(vim.o.lines * (opts.height or 0.5) + (opts.customHeight or 0))
    local col = (vim.o.columns - width) / 2
    local row = (vim.o.lines - height) / 2
    if opts.col then
        col = math.floor(vim.o.columns * opts.col)
    end
    if opts.row then
        row = math.floor(vim.o.lines * opts.row)
    end

    local win_config = {
        relative = 'editor',
        width = width,
        height = height,
        col = col,
        row = row,
        style = 'minimal',
        border = 'rounded',
    }

    local buf = vim.api.nvim_create_buf(true, true) -- No file, scratch buffer

    -- Create the floating window
    vim.api.nvim_open_win(buf, true, win_config)
end

local bufferHistory = {}

--BUffer Selector
local function deleteCurrentWindow()
    local buf = vim.fn.bufnr()
    vim.cmd.q()
    vim.api.nvim_buf_delete(buf, {})
end

local function getBuffers()
    local buffers = {}
    local bufsList = vim.api.nvim_list_bufs()
    local i = 1
    for key in ipairs(bufsList) do
        if vim.fn.buflisted(bufsList[key]) == 1 then
            buffers[i] = bufsList[key] .. ' '
            buffers[i] = buffers[i] .. vim.fn.bufname(bufsList[key]):gsub('^(.*[/\\])', '')
            for j = 1, #bufferHistory do
                if buffers[i] == bufferHistory[j] then
                    table.remove(buffers, i)
                    i = i - 1
                end
            end
            i = i + 1
        end
    end
    return buffers
end

local function setUIBufferUIKeymaps(contextBuffer)
    vim.keymap.set('n', '<Esc>', function()
        deleteCurrentWindow()
    end, { buffer = true })
    vim.keymap.set('n', '<CR>', function()
        local line = vim.fn.getline '.'
        local hasElement = false

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

        local num = line:match '^(.* )'
        local numConversion = tonumber(num) + 0
        deleteCurrentWindow()
        vim.api.nvim_set_current_buf(numConversion)
    end, { buffer = true })
    vim.keymap.set('n', 'D', function()
        local num = vim.fn.getline('.'):match '^(.* )'
        local numConversion = tonumber(num) + 0
        if contextBuffer == numConversion then
            deleteCurrentWindow()
            vim.api.nvim_buf_delete(numConversion, {})
        else
            vim.api.nvim_buf_delete(numConversion, {})
            vim.api.nvim_del_current_line()
        end
    end, { buffer = true })
end

local function setTerminalBufferKeymaps()
    vim.keymap.set('n', '<esc>', function()
        deleteCurrentWindow()
    end, { buffer = true })
end

local function create_buffer_menu()
    local contextBuffer = vim.api.nvim_get_current_buf()
    local bufferList = getBuffers()
    create_floating_window { width = 0.2, customHeight = 4 + #bufferList }
    vim.api.nvim_buf_set_lines(0, 0, #bufferHistory, false, bufferHistory)
    vim.api.nvim_buf_set_lines(0, #bufferHistory, #bufferHistory, false, { '--------------' })
    vim.api.nvim_buf_set_lines(0, #bufferHistory + 1, -1, false, bufferList)
    vim.fn.cursor(1, 1)
    setUIBufferUIKeymaps(contextBuffer)
end

--custom terminal window
local function run_cpp_Program()
    --vim.cmd.cd(vim.fn.expand '%:p:h')
    --vim.cmd.wa()
    --vim.cmd '!g++ -g *.cpp -o "%:p:h/main.exe"'
    create_floating_window { width = 0.25, height = 0.75, col = 1, row = 0 }
    vim.cmd.terminal '%:p:h/main.exe'
end

--keymaps
vim.keymap.set('n', '<leader>j', function()
    create_buffer_menu()
end)

--ctrl w w to switch between windows
vim.keymap.set('n', '<f12>', function()
    run_cpp_Program()
    setTerminalBufferKeymaps()
end, {})

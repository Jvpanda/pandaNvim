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

-- [[ DEVELOPMENT KEYMAPS]]
P = function(v)
    print(v)
    print(vim.inspect(v))
    return v
end

vim.keymap.set('n', '<leader>pm', ':messages<CR>')
--vim.cmd.messages 'clear'

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

local function deleteCurrentWindow(isTerminal)
    isTerminal = isTerminal or false

    local buf = vim.fn.bufnr()
    vim.cmd.q()

    if isTerminal then
        vim.api.nvim_buf_delete(buf, { force = true })
    else
        vim.api.nvim_buf_delete(buf, {})
    end
end

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
        deleteCurrentWindow()
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
        deleteCurrentWindow()
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
            deleteCurrentWindow()
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
    create_floating_window { width = 0.3, customHeight = 3 + #bufferList + #bufferHistory }
    vim.api.nvim_buf_set_lines(0, 0, #bufferHistory, false, bufferHistory)
    vim.api.nvim_buf_set_lines(0, #bufferHistory, #bufferHistory, false, { '--------------' })
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

-- [[Compiler Settings]]

local homeDirectory = 'unset'
local setHomeAttempts = 0
local buildType = 'Release'

--custom terminal window for running cpps
local function runCPPWindows()
    create_floating_window { width = 1.00, height = 0.75, col = 1, row = 0 }
    local filepath = homeDirectory:match '^.*[/\\]' .. 'build\\' .. buildType .. '\\execBinary.exe'
    vim.cmd.terminal(filepath)
end

local function compileCPPWindows()
    vim.cmd.wa()
    print(vim.cmd.wa())
    print('Compiling... with build type ' .. buildType)
    local filepath = homeDirectory:match '^.*[/\\]' .. 'build/'
    local result = vim.fn.system { 'cmake', '--build', filepath, '--config ' .. buildType }
    return result
end

--custom terminal window for running cpps
local function runCPPWSL()
    create_floating_window { width = 0.25, height = 0.75, col = 1, row = 0 }
    local filepath = vim.fn.expand '%:p:h' .. 'main.exe'
    vim.cmd.terminal(filepath)
end

local function setTerminalBufferKeymaps()
    vim.keymap.set({ 'n' }, '<esc>', function()
        deleteCurrentWindow(true)
    end, { buffer = true })
end

--cmake stuff
local function createCmakeTxt()
    if vim.fn.filereadable '../CMakeLists.txt' == 0 then
        local file = io.open('../CMakeLists.txt', 'w')
        if file ~= nil then
            file:write 'cmake_minimum_required(VERSION 3.10)\nproject("FillerProjectName")\n\nadd_executable(execBinary src/main.cpp)'
            file:close()
            print 'Created cmake txt'
        end
    end
end

local function createCmakeBuildFolder()
    if vim.fn.isdirectory '../build' == 0 then
        vim.fn.mkdir '../build'
        print 'Created build dir'
    end
end

--compiler keymaps

local function bindWindowsCompilerKeymaps()
    vim.keymap.set('n', '<F9>', function()
        if vim.fn.expand '%:p:t' == 'main.cpp' then
            vim.cmd.cd(vim.fn.expand '%:p:h')
            homeDirectory = vim.fn.expand '%:p:h'
            createCmakeBuildFolder()
            createCmakeTxt()
            setHomeAttempts = 0
            print('Home set to ' .. homeDirectory)
        else
            if setHomeAttempts ~= 1 then
                vim.notify 'This is not a main.cpp, press once more to set this as your home'
            end
            setHomeAttempts = setHomeAttempts + 1
        end

        if setHomeAttempts == 2 then
            local input = vim.fn.input { default = 'y', cancel_return = 'abort', prompt = 'Are you sure you would like to create here?(Y/n)' }
            if input == 'Y' or input == 'y' then
                vim.cmd.cd(vim.fn.expand '%:p:h')
                homeDirectory = vim.fn.expand '%:p:h'
                createCmakeBuildFolder()
                createCmakeTxt()
                setHomeAttempts = 0
                print('Home set to ' .. homeDirectory)
            else
                setHomeAttempts = 0
            end
        end
    end)

    vim.keymap.set('n', '<F10>', function()
        if homeDirectory ~= 'unset' then
            print 'Building with standard build commands...'
            local result = vim.fn.system { 'cmake', '..', '-B ../build/' }
            vim.notify('----\n' .. result .. '----')
        else
            vim.notify 'Please set a home directory'
        end
    end)

    vim.keymap.set('n', '<F11>', function()
        if homeDirectory ~= 'unset' then
            compileCPPWindows()
        else
            vim.notify 'Please set a home directory'
        end
    end)

    vim.keymap.set('n', '<f12>', function()
        if homeDirectory ~= 'unset' then
            local compilationResult = compileCPPWindows()
            if string.find(compilationResult, 'error') == nil then
                vim.print('-------\n' .. compilationResult .. '-------\n')
                runCPPWindows()
                setTerminalBufferKeymaps()
            else
                vim.notify(compilationResult .. '-------\n')
            end
        else
            vim.notify 'Please set a home directory'
        end
    end, {})

    vim.keymap.set('n', '<S-f12>', function()
        if homeDirectory ~= 'unset' then
            runCPPWindows()
            setTerminalBufferKeymaps()
        else
            vim.notify 'Please set a home directory'
        end
    end, {})

    vim.keymap.set('n', '<leader>pd', function()
        local input = vim.fn.input { default = 'Release', cancel_return = 'abort', prompt = 'Choose compile build(Release or Debug): ' }
        if input ~= 'abort' then
            if input == 'Debug' then
                buildType = 'Debug'
            else
                buildType = 'Release'
            end
        end
    end, { desc = 'Set to Release or Debug.' })
end

local function bindWSLCompileKeymaps()
    vim.keymap.set('n', '<F10>', function()
        vim.cmd.cd(vim.fn.expand '%:p:h')
    end, { desc = 'Changes directory to the one of the current editing file' })

    vim.keymap.set('n', '<F11>', '<cmd>wa<CR><cmd>!g++ -g *.cpp -o "%:p:h/main.exe"<CR>', { silent = true, desc = 'Build with c++' })

    --ctrl w w to switch between windows
    vim.keymap.set('n', '<f12>', function()
        runCPPWSL()
        setTerminalBufferKeymaps()
    end, {})
end

if vim.fn.has 'win32' == 0 then
    bindWSLCompileKeymaps()
else
    bindWindowsCompilerKeymaps()
end

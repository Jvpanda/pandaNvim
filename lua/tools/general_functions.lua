local functions = {}

function functions.create_floating_window(opts)
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
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
    }

    local buf = vim.api.nvim_create_buf(true, true) -- No file, scratch buffer

    -- Create the floating window
    vim.api.nvim_open_win(buf, true, win_config)
end

function functions.deleteCurrentWindow(isTerminal)
    isTerminal = isTerminal or false

    local buf = vim.fn.bufnr()
    vim.cmd.q()

    if isTerminal then
        vim.api.nvim_buf_delete(buf, { force = true })
    else
        vim.api.nvim_buf_delete(buf, {})
    end
end

function functions.setDelWinKeymapForBuffer()
    vim.keymap.set({ "n" }, "<esc>", function()
        functions.deleteCurrentWindow(true)
    end, { buffer = true })
end

--Global Function to inspect tables
P = function(v)
    print "PRINTED:\n"
    print(v)
    print "INSPECTED:\n"
    print(vim.inspect(v))
end

return functions

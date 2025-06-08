local funcs = {}

function funcs.create_floating_window(opts)
    opts = opts or {}

    --The columns/width are character counts and the rows/height are line counts fundamentally.

    -- witdh and height of the window
    -- default is a window that takes up half the screen
    -- calculates the ratio first then adds the line and char counts to the end result
    -- This acts as having an offset by adding onto it or it can even subtract
    local width = math.floor((vim.o.columns * (opts.width or 0.5)) + (opts.charCountWidth or 0))
    local height = math.floor((vim.o.lines * (opts.height or 0.5)) + (opts.lineCountHeight or 0))

    -- If there is no height or width then it assumes line count and char counts only
    if opts.lineCountHeight and not opts.height then
        height = opts.lineCountHeight
    end
    if opts.charCountWidth and not opts.width then
        width = opts.charCountWidth
    end

    -- Col and row determine the positioning.
    -- This places it in the middle by default.
    -- 0 is left/top and 1 is right/bottom
    -- this adjusts by the ratio and adds an offset if both are present
    local col = math.floor((vim.o.columns * (opts.col or 0.5)) + (opts.colOffset or 0)) - width / 2
    local row = math.floor((vim.o.lines * (opts.row or 0.5)) + (opts.rowOffset or 0)) - height / 2

    -- if there is no row or col it assumes the offsets only
    if opts.colOffset and not opts.col then
        col = opts.colOffset
    end
    if opts.rowOffset and not opts.row then
        row = opts.rowOffset
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

function funcs.deleteCurrentWindow(isTerminal)
    isTerminal = isTerminal or false

    local buf = vim.fn.bufnr()
    vim.cmd.q()

    if isTerminal then
        vim.api.nvim_buf_delete(buf, { force = true })
    else
        vim.api.nvim_buf_delete(buf, {})
    end
end

function funcs.setDelWinKeymapForBuffer()
    vim.keymap.set({ "n" }, "<esc>", function()
        funcs.deleteCurrentWindow(true)
    end, { buffer = true })
end

--Custom Option Selector
funcs.customOptionMenu = function(printedOptions, windowOpts)
    printedOptions = printedOptions or {}
    windowOpts = windowOpts or {}

    funcs.create_floating_window(windowOpts)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, printedOptions)

    local bottomLine = vim.fn.line "$"

    funcs.setDelWinKeymapForBuffer()
    vim.keymap.set("n", "j", function()
        local coords = vim.api.nvim_win_get_cursor(0)
        if coords[1] >= bottomLine then
            vim.api.nvim_win_set_cursor(0, { 1, coords[2] })
        else
            vim.api.nvim_win_set_cursor(0, { coords[1] + 1, coords[2] })
        end
    end, { buffer = true })
    vim.keymap.set("n", "k", function()
        local coords = vim.api.nvim_win_get_cursor(0)
        if coords[1] == 1 then
            vim.api.nvim_win_set_cursor(0, { bottomLine, coords[2] })
        else
            vim.api.nvim_win_set_cursor(0, { coords[1] - 1, coords[2] })
        end
    end, { buffer = true })
end

--Global Function to inspect tables
P = function(v)
    print "PRINTED:\n"
    print(v)
    print "INSPECTED:\n"
    print(vim.inspect(v))
end

return funcs

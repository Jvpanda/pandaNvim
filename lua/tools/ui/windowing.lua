local W = {}

---@class FloatingWindowOpts
---@field widthRatio? number Width as a ratio of the editor width. Defaults to 0.5.
---@field heightRatio? number Height as a ratio of the editor height. Defaults to 0.5.
---@field widthOffset? integer Width adjustment in columns.
---@field heightOffset? integer Height adjustment in rows.
---@field col? number Horizontal position ratio. 0 = left, 0.5 = center, 1 = right.
---@field row? number Vertical position ratio. 0 = top, 0.5 = center, 1 = bottom.
---@field colOffset? integer Horizontal position adjustment in columns.
---@field rowOffset? integer Vertical position adjustment in rows.

---@param opts? FloatingWindowOpts
---@return integer buf Buffer handle
---@return integer win Window handle
W.create_floating_window = function(opts)
    opts = opts or {}

    -- The width and height are fundamentally measured in columns and rows.
    -- By default, the window occupies half of the editor.
    --
    -- When a ratio is provided, the offset is added to the resulting size:
    --     width  = editor_width  * widthRatio  + widthOffset
    --     height = editor_height * heightRatio + heightOffset
    -- This allows the offset to either increase or decrease the size.
    -- Will be 0 by default

    local width = math.floor((vim.o.columns * (opts.widthRatio or 0)) + (opts.widthOffset or 0))

    local height = math.floor((vim.o.lines * (opts.heightRatio or 0)) + (opts.heightOffset or 0))

    -- Col and row determine the position of the window.
    --
    -- The position is specified as a ratio of the editor:
    --     col = 0   -> left
    --     col = 0.5 -> center
    --     col = 1   -> right
    --
    --     row = 0   -> top
    --     row = 0.5 -> center
    --     row = 1   -> bottom
    --
    -- When an offset is also provided, it is added to the position.
    --
    -- The window is then shifted by half of its own dimensions so
    -- that the ratio represents the center of the window that will appear.
    -- Will appear in middle of screen by default

    local col = math.floor((vim.o.columns * (opts.col or 0.5)) + (opts.colOffset or 0)) - width / 2

    local row = math.floor((vim.o.lines * (opts.row or 0.5)) + (opts.rowOffset or 0)) - height / 2

    local win_config = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
    }

    -- Create a scratch buffer.
    local buf = vim.api.nvim_create_buf(true, true)

    -- Create the floating window.
    return buf, vim.api.nvim_open_win(buf, true, win_config)
end

W.deleteCurrentWindow = function(isTerminal, buf, win)
    isTerminal = isTerminal or false
    win = win or nil
    buf = buf or nil

    if win == nil and buf == nil then
        buf = vim.fn.bufnr()
        vim.cmd.q()
    else
        vim.api.nvim_win_close(win, false)
    end

    if isTerminal then
        vim.api.nvim_buf_delete(buf, { force = true })
    else
        vim.api.nvim_buf_delete(buf, {})
    end
end

return W

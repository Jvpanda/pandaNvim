local state = require "tools.ui.buffer_selector_v2.state"
local render = require "tools.ui.buffer_selector_v2.render"
local keybinds = require "tools.ui.buffer_selector_v2.keybinds"

local M = {}

---@param aManager WindowManager
function M.setAll(aManager)
    local win = state.current_window(aManager)

    state.create_window(aManager)
    render.render_window(aManager, win)

    keybinds.attach_window(M, aManager, win)
    keybinds.attach_delete_all(M, aManager, win)
end

---@param aManager WindowManager
---@param aWindow BufferSelectorWindow
---@param deltaRow integer
---@param deltaCol integer
function M.move_to(aManager, aWindow, deltaRow, deltaCol)
    state.set_current_window(aManager, aWindow)

    local target = state.neighbor_window(aManager, aWindow, deltaRow, deltaCol)
    if target == nil then
        return
    end

    state.set_current_window(aManager, target)

    render.clear(aWindow.BufNumber)

    if target.Visible then
        vim.api.nvim_set_current_win(target.WinNumber)
    else
        M.setAll(aManager)
    end

    if target.Name ~= "" then
        vim.api.nvim_win_set_cursor(target.WinNumber, { 3, 0 })
    end

    render.render_line_at_cursor_pos(target.WinNumber, target.BufNumber)
end

---@param aWindow BufferSelectorWindow
---@param count integer
---@return string[]
local function buffers_under_cursor(aWindow, count)
    local cursorLine = vim.api.nvim_win_get_cursor(aWindow.WinNumber)[1]
    local lines = vim.api.nvim_buf_get_lines(aWindow.BufNumber, cursorLine - 1, -1, false)

    local names = {}
    for _, line in ipairs(lines) do
        if aWindow.BufferList[line] ~= nil then
            names[#names + 1] = line
            if #names >= count then
                break
            end
        end
    end

    return names
end

---@param aManager WindowManager
---@param aWindow BufferSelectorWindow
---@param deltaRow integer
---@param deltaCol integer
---@param count integer
function M.move_buffers(aManager, aWindow, deltaRow, deltaCol, count)
    state.set_current_window(aManager, aWindow)

    local target = state.neighbor_window(aManager, aWindow, deltaRow, deltaCol)
    if target == nil then
        return
    end

    local names = buffers_under_cursor(aWindow, count)
    if #names == 0 then
        return
    end

    for _, name in ipairs(names) do
        state.swap_buffer_to_window(aManager, target.Position.y, target.Position.x, name)
    end

    aManager.currentRow = target.Position.y
    aManager.currentCol = target.Position.x

    if target.Visible then
        render.render_window(aManager, target)
    else
        M.setAll(aManager)
    end

    state.set_current_window(aManager, aWindow)
    render.render_window(aManager, aWindow)
    vim.api.nvim_set_current_win(aWindow.WinNumber)
    render.render_line_at_cursor_pos(aWindow.WinNumber, aWindow.BufNumber)
end

---@param aManager WindowManager
---@param aWindow BufferSelectorWindow
---@param line string
function M.enter(aManager, aWindow, line)
    print(line)
    state.set_current_window(aManager, aWindow)
    state.delete_all_windows(aManager)
    vim.api.nvim_set_current_buf(state.current_window(aManager).BufferList[line])
end

---@param aManager WindowManager
function M.delete_all(aManager)
    state.delete_all_windows(aManager)
end

---@param aManager WindowManager
---@param aWindow BufferSelectorWindow
function M.delete_buffer(aManager, aWindow, line)
    vim.api.nvim_buf_delete(state.current_window(aManager).BufferList[line], {})
    state.current_window(aManager).BufferList[line] = nil
    vim.api.nvim_del_current_line()
end

---@param aManager WindowManager
function M.refresh(aManager)
    state.collect_buffers(aManager)

    for i = 1, state.GRID_ROWS do
        for j = 1, state.GRID_COLS do
            state.refresh_names(aManager, aManager.windows[i][j])
        end
    end

    local fallback = nil
    for i = 1, state.GRID_ROWS do
        for j = 1, state.GRID_COLS do
            if aManager.windows[i][j].Visible then
                aManager.currentRow, aManager.currentCol = i, j
                M.setAll(aManager)
                fallback = aManager.windows[i][j]
            end
        end
    end

    local last = aManager.windows[aManager.lastRow][aManager.lastCol]
    if not last.Visible then
        last = fallback
    end

    if last == nil then
        return
    end

    state.assign_remaining_buffers(aManager, last)
    render.render_window(aManager, last)

    state.set_current_window(aManager, last)
    vim.api.nvim_set_current_win(last.WinNumber)
    if last.Name ~= "" then
        vim.api.nvim_win_set_cursor(last.WinNumber, { 3, 0 })
    end
    render.render_line_at_cursor_pos(last.WinNumber, last.BufNumber)
end

---@return WindowManager
function M.setup()
    local manager = state.new_manager()

    keybinds.attach_open(M, manager)

    manager.windows[2][2].Visible = true
    state.set_base_state(manager)

    vim.cmd.redraw()

    return manager
end

M.setup()

return M

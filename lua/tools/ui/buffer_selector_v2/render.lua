local M = {}

local ns = vim.api.nvim_create_namespace "buffer_menu"
vim.api.nvim_set_hl(0, "BufferSelect", {
    link = "PmenuSel",
})

---@param buf integer
---@param selected integer
local function render_line(buf, selected)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    vim.api.nvim_buf_set_extmark(buf, ns, selected - 1, 0, {
        line_hl_group = "BufferSelect",
        priority = 1000,
    })
end

---@param win integer
---@param buf integer
function M.render_line_at_cursor_pos(win, buf)
    local coords = vim.api.nvim_win_get_cursor(win)
    render_line(buf, coords[1])
end

---@param buf integer
function M.clear(buf)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
end

---@param buf integer
---@param win integer
function M.move_down_wrap_around(buf, win, returnHeight)
    local coords = vim.api.nvim_win_get_cursor(win)
    local bottomLine = vim.fn.line "$"
    if coords[1] >= bottomLine then
        vim.api.nvim_win_set_cursor(win, { returnHeight, coords[2] })
        M.render_line_at_cursor_pos(win, buf)
    else
        vim.api.nvim_win_set_cursor(win, { coords[1] + 1, coords[2] })
        M.render_line_at_cursor_pos(win, buf)
    end
end

---@param buf integer
---@param win integer
function M.move_up_wrap_around(buf, win, minHeight)
    local coords = vim.api.nvim_win_get_cursor(win)
    local bottomLine = vim.fn.line "$"
    if coords[1] == minHeight then
        vim.api.nvim_win_set_cursor(win, { bottomLine, coords[2] })
        M.render_line_at_cursor_pos(win, buf)
    else
        vim.api.nvim_win_set_cursor(win, { coords[1] - 1, coords[2] })
        M.render_line_at_cursor_pos(win, buf)
    end
end

---@param aManager WindowManager
---@param aWindow BufferSelectorWindow
function M.render_window(aManager, aWindow)
    local namelist = {}
    local order = {}

    for _, name in ipairs(aWindow.Order) do
        local value = aWindow.BufferList[name]
        if value ~= nil then
            if aManager.allBuffs[value] == nil then
                aWindow.BufferList[name] = nil
            else
                table.insert(order, name)
                if aManager.allBuffs[value].listed then
                    table.insert(namelist, name)
                end
            end
        end
    end

    if aWindow.Name ~= "" then
        table.insert(namelist, 1, aWindow.Name)
        table.insert(namelist, 2, "----------------------------")
        if next(aWindow.BufferList) == nil then
            table.insert(namelist, 3, "")
        end
    end

    aWindow.Order = order
    vim.api.nvim_buf_set_lines(aWindow.BufNumber, 0, -1, false, namelist)
end

return M

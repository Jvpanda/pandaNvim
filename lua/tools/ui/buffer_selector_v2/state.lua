local window = require "tools.ui.windowing"

local M = {}

M.GRID_ROWS = 3
M.GRID_COLS = 3

---@alias BufferId integer

---@class BufferState
---@field id BufferId
---@field name string
---@field buftype string
---@field filetype string
---@field modified boolean
---@field listed boolean
---@field loaded boolean
---@field hidden string
---@field readonly boolean
---@field modifiable boolean

---@class BufferSelectorWindow
---@field BufNumber integer|nil
---@field WinNumber integer|nil
---@field Position {x:integer,y:integer}
---@field Visible boolean
---@field WindowOpts FloatingWindowOpts
---@field BufferList table<string,BufferId>
---@field Order string[]

---@class WindowManager
---@field windows BufferSelectorWindow[][]
---@field allBuffs table<BufferId,BufferState>
---@field currentRow integer
---@field currentCol integer
---@field lastRow integer
---@field lastCol integer

---@param buf BufferId
---@return BufferState
function M.get_buffer_state(buf)
    return {
        id = buf,
        name = vim.api.nvim_buf_get_name(buf),
        buftype = vim.bo[buf].buftype,
        filetype = vim.bo[buf].filetype,
        modified = vim.bo[buf].modified,
        listed = vim.bo[buf].buflisted,
        loaded = vim.api.nvim_buf_is_loaded(buf),
        hidden = vim.bo[buf].bufhidden,
        readonly = vim.bo[buf].readonly,
        modifiable = vim.bo[buf].modifiable,
    }
end

---@return WindowManager
function M.new_manager()
    ---@type WindowManager
    local manager = {
        windows = {},
        allBuffs = {},
        currentRow = 0,
        currentCol = 0,
    }

    for i = 1, M.GRID_ROWS do
        manager.windows[i] = {}
        for j = 1, M.GRID_COLS do
            manager.windows[i][j] = {
                WindowOpts = { widthRatio = 0.3, heightRatio = 0.27, col = 0.0, row = 0.0, rowOffset = 8 + (i - 1) * 18, colOffset = 36 + 70 * (j - 1) },
                BufferList = {},
                Order = {},
                Position = { x = j, y = i },
                Visible = false,
            }
        end
    end

    manager.currentRow = math.ceil(M.GRID_ROWS / 2)
    manager.currentCol = math.ceil(M.GRID_COLS / 2)
    manager.lastRow = manager.currentRow
    manager.lastCol = manager.currentCol

    return manager
end

---@param aManager WindowManager
---@return BufferSelectorWindow
function M.current_window(aManager)
    return aManager.windows[aManager.currentRow][aManager.currentCol]
end

---@param aManager WindowManager
---@param aWindow BufferSelectorWindow
function M.set_current_window(aManager, aWindow)
    aManager.currentRow = aWindow.Position.y
    aManager.currentCol = aWindow.Position.x
    aManager.lastRow = aWindow.Position.y
    aManager.lastCol = aWindow.Position.x
end

---@param aManager WindowManager
---@param aWindow BufferSelectorWindow
---@param deltaRow integer
---@param deltaCol integer
---@return BufferSelectorWindow|nil
function M.neighbor_window(aManager, aWindow, deltaRow, deltaCol)
    local row = aWindow.Position.y + deltaRow
    local col = aWindow.Position.x + deltaCol

    if row < 1 or row > M.GRID_ROWS or col < 1 or col > M.GRID_COLS then
        return nil
    end

    return aManager.windows[row][col]
end

---@param aWindow BufferSelectorWindow
---@param name string
---@param value BufferId
function M.insert_buffer(aWindow, name, value)
    if aWindow.BufferList[name] == nil then
        aWindow.BufferList[name] = value
        table.insert(aWindow.Order, name)
    end
end

---@param aWindow BufferSelectorWindow
---@param name string
function M.remove_buffer(aWindow, name)
    aWindow.BufferList[name] = nil
    for i, ordered_name in ipairs(aWindow.Order) do
        if ordered_name == name then
            table.remove(aWindow.Order, i)
            break
        end
    end
end

---@param aManager WindowManager
---@param aWindow BufferSelectorWindow
---@param value BufferId
function M.add_buffer_to_window(aManager, aWindow, value)
    local buffer = aManager.allBuffs[value]
    local name = buffer.name
    local adjusted_name = vim.fn.fnamemodify(name, ":t")

    for parent in vim.fs.parents(name) do
        if aWindow.BufferList[adjusted_name] ~= nil then
            adjusted_name = vim.fn.fnamemodify(parent, ":h:t") .. "/" .. vim.fn.fnamemodify(parent, ":t") .. "/" .. adjusted_name
        end
    end

    if buffer.listed and buffer.buftype ~= "nofile" then
        M.insert_buffer(aWindow, adjusted_name, value)
    end
end

---@param aManager WindowManager
---@param destRow integer
---@param destCol integer
---@param name string
function M.swap_buffer_to_window(aManager, destRow, destCol, name)
    local source = M.current_window(aManager)
    local dest = aManager.windows[destRow][destCol]
    local value = source.BufferList[name]

    M.add_buffer_to_window(aManager, dest, value)
    print(value)
    M.remove_buffer(source, name)
end

---@param aManager WindowManager
function M.collect_buffers(aManager)
    aManager.allBuffs = {}
    for _, value in ipairs(vim.api.nvim_list_bufs()) do
        aManager.allBuffs[value] = M.get_buffer_state(value)
    end
end

---@param aManager WindowManager
---@param aWindow BufferSelectorWindow
function M.assign_remaining_buffers(aManager, aWindow)
    local assigned = {}
    for i = 1, M.GRID_ROWS do
        for j = 1, M.GRID_COLS do
            for _, value in pairs(aManager.windows[i][j].BufferList) do
                assigned[value] = true
            end
        end
    end

    for _, value in ipairs(vim.api.nvim_list_bufs()) do
        if not assigned[value] and aManager.allBuffs[value] ~= nil then
            M.add_buffer_to_window(aManager, aWindow, value)
        end
    end
end

---@param aManager WindowManager
function M.set_base_state(aManager)
    M.collect_buffers(aManager)
    M.assign_remaining_buffers(aManager, M.current_window(aManager))
end

---@param aManager WindowManager
function M.create_window(aManager)
    local win = M.current_window(aManager)
    local buf, winNumber = window.create_floating_window(win.WindowOpts)

    win.BufNumber = buf
    win.WinNumber = winNumber
    win.Visible = true
end

---@param aManager WindowManager
function M.delete_all_windows(aManager)
    for i = 1, M.GRID_ROWS do
        for j = 1, M.GRID_COLS do
            local win = aManager.windows[i][j]
            if win.Visible then
                window.deleteCurrentWindow(false, win.BufNumber, win.WinNumber)

                if not next(win.BufferList) then
                    win.Visible = false
                end
            end
        end
    end
end

return M

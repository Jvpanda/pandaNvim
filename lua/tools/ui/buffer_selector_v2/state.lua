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

---@class WindowManager
---@field windows BufferSelectorWindow[][]
---@field allBuffs table<BufferId,BufferState>
---@field currentRow integer
---@field currentCol integer

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
                Position = { x = j, y = i },
                Visible = false,
            }
        end
    end

    manager.currentRow = math.ceil(M.GRID_ROWS / 2)
    manager.currentCol = math.ceil(M.GRID_COLS / 2)

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

---@param aManager WindowManager
---@param aWindow BufferSelectorWindow
---@param value BufferId
function M.add_buffer_to_window(aManager, aWindow, value)
    local name = aManager.allBuffs[value].name
    local adjusted_name = vim.fn.fnamemodify(name, ":t")

    for parent in vim.fs.parents(name) do
        if aWindow.BufferList[adjusted_name] ~= nil then
            adjusted_name = vim.fn.fnamemodify(parent, ":h:t") .. "/" .. vim.fn.fnamemodify(parent, ":t") .. "/" .. adjusted_name
        end
    end

    if aManager.allBuffs[value].listed then
        aWindow.BufferList[adjusted_name] = value
        print("put: " .. adjusted_name .. " in " .. aWindow.Position.y, aWindow.Position.x)
    end
end

---@param aManager WindowManager
---@param destRow integer
---@param destCol integer
---@param name string
function M.swap_buffer_to_window(aManager, destRow, destCol, name)
    local source = M.current_window(aManager)
    local dest = aManager.windows[destRow][destCol]

    M.add_buffer_to_window(aManager, dest, source.BufferList[name])
    print(source.BufferList[name])
    source.BufferList[name] = nil
end

---@param aManager WindowManager
function M.collect_buffers(aManager)
    aManager.allBuffs = {}
    for _, value in ipairs(vim.api.nvim_list_bufs()) do
        aManager.allBuffs[value] = M.get_buffer_state(value)
    end
end

---@param aManager WindowManager
function M.set_base_state(aManager)
    M.collect_buffers(aManager)
    for _, value in ipairs(vim.api.nvim_list_bufs()) do
        M.add_buffer_to_window(aManager, M.current_window(aManager), value)
    end
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

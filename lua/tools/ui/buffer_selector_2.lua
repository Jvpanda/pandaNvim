local window = require "tools.ui.windowing"
local menu = require "tools.ui.menuing"

---@alias BufferId integer

---@class BufferState
---@field id BufferId
---@field name string
---@field buftype string
---@field filetype string
---@field modified boolean
---@field listed boolean
---@field loaded boolean
---@field readonly boolean
---@field modifiable boolean

---@param buf BufferId
---@return BufferState
local function get_buffer_state(buf)
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

---@class BufferSelectorWindow
---@field BufNumber integer
---@field WinNumber integer
---@field Cursor {x:integer,y:integer}
---@field Visible boolean
---@field WindowOpts FloatingWindowOpts
---@field BufferList integer[]

---@class WindowManager
---@field windows BufferSelectorWindow[][]
local manager = {
    windows = {},
}

for i = 1, 3 do
    manager.windows[i] = {}
    for j = 1, 3 do
        local win = {
            WindowOpts = { widthRatio = 0.3, heightRatio = 0.27, col = 0.0, row = 0.0, rowOffset = 8 + (i - 1) * 18, colOffset = 36 + 70 * (j - 1) },
            BufferList = {},
        }
        manager.windows[i][j] = win
        manager.windows[i][j].Visible = false
    end
end

manager.windows[2][2].Visible = true
local buffersNumList = vim.api.nvim_list_bufs()

---@type table<integer,BufferState>
local allBuffsList = {}

for i, value in ipairs(buffersNumList) do
    allBuffsList[value] = get_buffer_state(value)
    manager.windows[2][2].BufferList[i] = value
end

local function handle_enter(args)
    print(args)
end

local function create_window(current_row, current_col)
    local buf, win = window.create_floating_window(manager.windows[current_row][current_col].WindowOpts)
    local namelist = {}
    local i = 1
    for key, value in pairs(manager.windows[current_row][current_col].BufferList) do
        if allBuffsList[value] == nil then
            manager.windows[current_row][current_col].BufferList[key] = nil
        elseif allBuffsList[value].listed then
            namelist[i] = vim.api.nvim_buf_get_name(value)
            i = i + 1
        end
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, namelist)
    manager.windows[current_row][current_col].BufNumber = buf
    manager.windows[current_row][current_col].WinNumber = win
    manager.windows[current_row][current_col].Visible = true

    return buf, win
end

local setDel = function() end
local setH = function(current_row, current_col) end
local setJ = function(current_row, current_col) end
local setK = function(current_row, current_col) end
local setL = function(current_row, current_col) end

local setAll = function(current_row, current_col)
    local buf, win = create_window(current_row, current_col)

    menu.set_non_blocking_keybinds(buf, win, handle_enter)

    setJ(current_row, current_col)
    setK(current_row, current_col)
    setL(current_row, current_col)
    setH(current_row, current_col)
    setDel()
end

setDel = function()
    vim.keymap.set({ "n" }, "<esc>", function()
        for i = 1, 3 do
            for j = 1, 3 do
                if manager.windows[i][j].Visible then
                    window.deleteCurrentWindow(false, manager.windows[i][j].BufNumber, manager.windows[i][j].WinNumber)
                    if #manager.windows[i][j].BufferList == 0 then
                        manager.windows[i][j].Visible = false
                    end
                end
            end
        end
    end, { buffer = true })
end

setH = function(current_row, current_col)
    vim.keymap.set({ "n" }, "<C-h>", function()
        if current_col - 1 < 1 then
            return
        end

        if manager.windows[current_row][current_col - 1].Visible then
            vim.api.nvim_set_current_win(manager.windows[current_row][current_col - 1].WinNumber)
        else
            setAll(current_row, current_col - 1)
        end
    end, { buffer = true })
end

setJ = function(current_row, current_col)
    vim.keymap.set({ "n" }, "<C-j>", function()
        if current_row + 1 > 3 then
            return
        end

        if manager.windows[current_row + 1][current_col].Visible then
            vim.api.nvim_set_current_win(manager.windows[current_row + 1][current_col].WinNumber)
        else
            setAll(current_row + 1, current_col)
        end
    end, { buffer = true })
end

setK = function(current_row, current_col)
    vim.keymap.set({ "n" }, "<C-k>", function()
        if current_row - 1 < 1 then
            return
        end

        if manager.windows[current_row - 1][current_col].Visible then
            vim.api.nvim_set_current_win(manager.windows[current_row - 1][current_col].WinNumber)
        else
            setAll(current_row - 1, current_col)
        end
    end, { buffer = true })
end

setL = function(current_row, current_col)
    vim.keymap.set({ "n" }, "<C-l>", function()
        if current_col + 1 > 3 then
            return
        end

        if manager.windows[current_row][current_col + 1].Visible then
            vim.api.nvim_set_current_win(manager.windows[current_row][current_col + 1].WinNumber)
        else
            setAll(current_row, current_col + 1)
        end
    end, { buffer = true })
end

vim.keymap.set({ "n" }, "<C-q>", function()
    buffersNumList = vim.api.nvim_list_bufs()
    allBuffsList = {}
    for i, value in ipairs(buffersNumList) do
        allBuffsList[value] = get_buffer_state(value)
    end
    for i = 1, 3 do
        for j = 1, 3 do
            if manager.windows[i][j].Visible then
                setAll(i, j)
            end
        end
    end
end, { buffer = true })

vim.cmd.redraw()

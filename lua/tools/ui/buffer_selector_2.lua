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
---@field WindowOpts FloatingWindowOpts
---@field BufferList integer[]

---@type BufferSelectorWindow
local win = { WindowOpts = { widthOffset = 20, heightOffset = 10 }, BufferList = { 1, 2, 3 } }
---@type BufferSelectorWindow
local win2 = { WindowOpts = { row = 0.1, col = 0.2, widthOffset = 20, heightOffset = 10 }, BufferList = { "1", "1", "2" } }

---@class BufferWindowList
---@field [integer] BufferSelectorWindow
local Window_List = {}

Window_List[1] = win
Window_List[2] = win2

local buffersNumList = vim.api.nvim_list_bufs()

for key, value in pairs(buffersNumList) do
    win.BufferList[key] = tostring(value)
end

for key, value in ipairs(Window_List) do
    local buf, win = window.create_floating_window(value.WindowOpts)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, value.BufferList)
end

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
---@field Position {x:integer,y:integer}
---@field Visible boolean
---@field WindowOpts FloatingWindowOpts
---@field BufferList table<string,integer>

---@class WindowManager
---@field windows BufferSelectorWindow[][]

---@param aManager WindowManager
local function populate_window_manager(aManager)
    for i = 1, 3 do
        aManager.windows[i] = {}
        for j = 1, 3 do
            local win = {
                WindowOpts = { widthRatio = 0.3, heightRatio = 0.27, col = 0.0, row = 0.0, rowOffset = 8 + (i - 1) * 18, colOffset = 36 + 70 * (j - 1) },
                BufferList = {},
            }
            aManager.windows[i][j] = win
            aManager.windows[i][j].Visible = false
        end
    end
end

local function add_buffer_to_list(row, col, value, aManager, allBuffs)
    local name = allBuffs[value].name
    local adjusted_name = vim.fn.fnamemodify(name, ":t")

    for parent in vim.fs.parents(name) do
        if aManager.windows[row][col].BufferList[adjusted_name] ~= nil then
            adjusted_name = vim.fn.fnamemodify(parent, ":h:t") .. "/" .. vim.fn.fnamemodify(parent, ":t") .. "/" .. adjusted_name
        end
    end

    if allBuffs[value].listed then
        aManager.windows[row][col].BufferList[adjusted_name] = value
        print("put: " .. adjusted_name .. " in " .. row, col)
    end
end

local function set_base_state(aManager, buffersNums, allBuffs)
    for _, value in ipairs(buffersNums) do
        allBuffs[value] = get_buffer_state(value)
        add_buffer_to_list(2, 2, value, aManager, allBuffs)
    end
end

local function swap_buffer_to_window(aManager, allBuffs, source_row, source_col, dest_row, dest_col, name)
    add_buffer_to_list(dest_row, dest_col, aManager.windows[source_row][source_col].BufferList[name], aManager, allBuffs)
    print(aManager.windows[source_row][source_col].BufferList[name])
    aManager.windows[source_row][source_col].BufferList[name] = nil
end

local function create_window(current_row, current_col, aManager)
    local buf, win = window.create_floating_window(aManager.windows[current_row][current_col].WindowOpts)

    aManager.windows[current_row][current_col].BufNumber = buf
    aManager.windows[current_row][current_col].WinNumber = win
    aManager.windows[current_row][current_col].Visible = true

    return buf, win
end

---@param current_row integer
---@param current_col integer
---@param aManager WindowManager
---@param allBuffs any
local function render_window(current_row, current_col, aManager, allBuffs)
    local namelist = {}
    local i = 1
    for key, value in pairs(aManager.windows[current_row][current_col].BufferList) do
        if allBuffs[value] == nil then
            aManager.windows[current_row][current_col].BufferList[key] = nil
        elseif allBuffs[value].listed then
            namelist[i] = key
            i = i + 1
        end
    end
    vim.api.nvim_buf_set_lines(aManager.windows[current_row][current_col].BufNumber, 0, -1, false, namelist)
end

local function delete_all_windows(aManager)
    for i = 1, 3 do
        for j = 1, 3 do
            if aManager.windows[i][j].Visible then
                window.deleteCurrentWindow(false, aManager.windows[i][j].BufNumber, aManager.windows[i][j].WinNumber)

                if not next(aManager.windows[i][j].BufferList) then
                    aManager.windows[i][j].Visible = false
                end
            end
        end
    end
end

local function handle_enter(args, row, col, aManager)
    print(args)
    delete_all_windows(aManager)
    vim.api.nvim_set_current_buf(aManager.windows[row][col].BufferList[args])
end

local function set_movement_binds(buf, win, callbackFunction, current_row, current_col, aManager)
    menu.render(buf, 1)

    vim.keymap.set({ "n" }, "<esc>", function()
        window.deleteCurrentWindow(true)
    end, { buffer = true })

    vim.keymap.set("n", "j", function()
        menu.move_down_wrap_around(buf, win)
    end, { buffer = true })

    vim.keymap.set("n", "k", function()
        menu.move_up_wrap_around(buf, win)
    end, { buffer = true })

    if callbackFunction ~= nil then
        vim.keymap.set("n", "<CR>", function()
            local line = vim.fn.getline "."
            if callbackFunction then
                callbackFunction(line, current_row, current_col, aManager)
            end
        end, { buffer = true })
    end
end

local function setDel(aManager) end
local function setH(current_row, current_col, aManager, allBuffs) end
local function setJ(current_row, current_col, aManager, allBuffs) end
local function setK(current_row, current_col, aManager, allBuffs) end
local function setL(current_row, current_col, aManager, allBuffs) end

local function setAll(current_row, current_col, aManager, allBuffs)
    local buf, win = create_window(current_row, current_col, aManager)
    render_window(current_row, current_col, aManager, allBuffs)

    set_movement_binds(buf, win, handle_enter, current_row, current_col, aManager)

    setJ(current_row, current_col, aManager, allBuffs)
    setK(current_row, current_col, aManager, allBuffs)
    setL(current_row, current_col, aManager, allBuffs)
    setH(current_row, current_col, aManager, allBuffs)
    setDel(aManager)
end

setDel = function(aManager)
    vim.keymap.set({ "n" }, "<esc>", function()
        delete_all_windows(aManager)
    end, { buffer = true })
end

setH = function(current_row, current_col, aManager, allBuffs)
    vim.keymap.set({ "n" }, "<C-h>", function()
        if current_col - 1 < 1 then
            return
        end

        if aManager.windows[current_row][current_col - 1].Visible then
            vim.api.nvim_set_current_win(aManager.windows[current_row][current_col - 1].WinNumber)
        else
            setAll(current_row, current_col - 1, aManager, allBuffs)
        end
    end, { buffer = true })
end

setJ = function(current_row, current_col, aManager, allBuffs)
    vim.keymap.set({ "n" }, "<C-j>", function()
        if current_row + 1 > 3 then
            return
        end

        if aManager.windows[current_row + 1][current_col].Visible then
            vim.api.nvim_set_current_win(aManager.windows[current_row + 1][current_col].WinNumber)
        else
            setAll(current_row + 1, current_col, aManager, allBuffs)
        end
    end, { buffer = true })
end

setK = function(current_row, current_col, aManager, allBuffs)
    vim.keymap.set({ "n" }, "<C-k>", function()
        if current_row - 1 < 1 then
            return
        end

        if aManager.windows[current_row - 1][current_col].Visible then
            vim.api.nvim_set_current_win(aManager.windows[current_row - 1][current_col].WinNumber)
        else
            setAll(current_row - 1, current_col, aManager, allBuffs)
        end
    end, { buffer = true })
end

setL = function(current_row, current_col, aManager, allBuffs)
    vim.keymap.set({ "n" }, "<C-l>", function()
        if current_col + 1 > 3 then
            return
        end

        if aManager.windows[current_row][current_col + 1].Visible then
            vim.api.nvim_set_current_win(aManager.windows[current_row][current_col + 1].WinNumber)
        else
            setAll(current_row, current_col + 1, aManager, allBuffs)
        end
    end, { buffer = true })
end

---@type WindowManager
local manager = {
    windows = {},
}

---@type table<integer,BufferState>
local allBuffsList = {}

vim.keymap.set({ "n" }, "<leader>k", function()
    local buffersNumList = vim.api.nvim_list_bufs()
    allBuffsList = {}
    for i, value in ipairs(buffersNumList) do
        allBuffsList[value] = get_buffer_state(value)
    end
    for i = 1, 3 do
        for j = 1, 3 do
            if manager.windows[i][j].Visible then
                setAll(i, j, manager, allBuffsList)
            end
        end
    end
end, {})

populate_window_manager(manager)

manager.windows[2][2].Visible = true
local buffersNumList = vim.api.nvim_list_bufs()
set_base_state(manager, buffersNumList, allBuffsList)

swap_buffer_to_window(manager, allBuffsList, 2, 2, 1, 1, "main.cpp")
manager.windows[1][1].Visible = true
vim.print(manager.windows[1][1].BufferList)

vim.cmd.redraw()

local M = {}
local window = require "tools.ui.windowing"

local ns = vim.api.nvim_create_namespace "my_menu"
vim.api.nvim_set_hl(0, "MyMenuSelected", {
    link = "PmenuSel",
})

function M.render(buf, selected)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    vim.api.nvim_buf_set_extmark(buf, ns, selected - 1, 0, {
        line_hl_group = "MyMenuSelected",
        priority = 1000,
    })
end

---@param buf any
---@param win any
function M.move_down_wrap_around(buf, win)
    local coords = vim.api.nvim_win_get_cursor(win)
    local bottomLine = vim.fn.line "$"
    if coords[1] >= bottomLine then
        vim.api.nvim_win_set_cursor(win, { 1, coords[2] })
        M.render(buf, 1)
    else
        vim.api.nvim_win_set_cursor(win, { coords[1] + 1, coords[2] })
        M.render(buf, coords[1] + 1)
    end
end

---@param buf any
---@param win any
function M.move_up_wrap_around(buf, win)
    local coords = vim.api.nvim_win_get_cursor(win)
    local bottomLine = vim.fn.line "$"
    if coords[1] == 1 then
        vim.api.nvim_win_set_cursor(win, { bottomLine, coords[2] })
        M.render(buf, bottomLine)
    else
        vim.api.nvim_win_set_cursor(win, { coords[1] - 1, coords[2] })
        M.render(buf, coords[1] - 1)
    end
end

function M.set_non_blocking_keybinds(buf, win, callbackFunction, passedArgs)
    M.render(buf, 1)

    vim.keymap.set({ "n" }, "<esc>", function()
        window.deleteCurrentWindow(true)
    end, { buffer = true })

    vim.keymap.set("n", "j", function()
        M.move_down_wrap_around(buf, win)
    end, { buffer = true })

    vim.keymap.set("n", "k", function()
        M.move_up_wrap_around(buf, win)
    end, { buffer = true })

    if callbackFunction ~= nil then
        vim.keymap.set("n", "<CR>", function()
            local line = vim.fn.getline "."
            window.deleteCurrentWindow(false)
            if callbackFunction then
                callbackFunction(line, passedArgs)
            end
        end, { buffer = true })
    end
end

function M.open_blocking_menu(buf, win)
    local result = nil
    M.render(buf, 1)
    vim.cmd "redraw"
    while vim.api.nvim_win_is_valid(win) do
        local key = vim.fn.getchar()
        if key == 106 then
            M.move_down_wrap_around(buf, win)
        elseif key == 107 then
            M.move_up_wrap_around(buf, win)
        elseif key == 13 then
            result = vim.fn.getline "."
            break
        elseif key == 27 then
            result = nil
            break
        end
        vim.cmd "redraw"
    end
    if vim.api.nvim_win_is_valid(win) then
        window.deleteCurrentWindow()
    end

    return result
end

--Custom Option Selector
---@param printedOptions any
---@param windowOpts FloatingWindowOpts
---@param callbackFunction any
---@param ... unknown
---@return unknown|nil
function M.customOptionsMenu(printedOptions, windowOpts, callbackFunction, ...)
    callbackFunction = callbackFunction or nil
    printedOptions = printedOptions or {}
    windowOpts = windowOpts or {}
    local passedArgs = ...

    local buf, win = window.create_floating_window(windowOpts)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, printedOptions)

    if callbackFunction == nil then
        local result = M.open_blocking_menu(buf, win)
        return result
    else
        M.set_non_blocking_keybinds(buf, win, callbackFunction, passedArgs)
    end
end

return M

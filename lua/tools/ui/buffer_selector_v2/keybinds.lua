local render = require "tools.ui.buffer_selector_v2.render"

local M = {}

---@param api table
---@param aManager WindowManager
---@param aWindow BufferSelectorWindow
function M.attach_window(api, aManager, aWindow)
    vim.keymap.set("n", "j", function()
        local return_height = 1
        if aWindow.Name ~= "" then
            return_height = 3
        end
        render.move_down_wrap_around(aWindow.BufNumber, aWindow.WinNumber, return_height)
    end, { buffer = aWindow.BufNumber })

    vim.keymap.set("n", "k", function()
        local min_height = 1
        if aWindow.Name ~= "" then
            min_height = 3
        end
        render.move_up_wrap_around(aWindow.BufNumber, aWindow.WinNumber, min_height)
    end, { buffer = aWindow.BufNumber })

    vim.keymap.set("n", "<CR>", function()
        local line = vim.fn.getline "."
        api.enter(aManager, aWindow, line)
    end, { buffer = aWindow.BufNumber })

    vim.keymap.set({ "n" }, "<C-h>", function()
        api.move_to(aManager, aWindow, 0, -vim.v.count1)
    end, { buffer = aWindow.BufNumber })

    vim.keymap.set({ "n" }, "<C-j>", function()
        api.move_to(aManager, aWindow, vim.v.count1, 0)
    end, { buffer = aWindow.BufNumber })

    vim.keymap.set({ "n" }, "<C-k>", function()
        api.move_to(aManager, aWindow, -vim.v.count1, 0)
    end, { buffer = aWindow.BufNumber })

    vim.keymap.set({ "n" }, "<C-l>", function()
        api.move_to(aManager, aWindow, 0, vim.v.count1)
    end, { buffer = aWindow.BufNumber })

    vim.keymap.set({ "n" }, "H", function()
        api.move_buffers(aManager, aWindow, 0, -1, vim.v.count1)
    end, { buffer = aWindow.BufNumber })

    vim.keymap.set({ "n" }, "J", function()
        api.move_buffers(aManager, aWindow, 1, 0, vim.v.count1)
    end, { buffer = aWindow.BufNumber })

    vim.keymap.set({ "n" }, "K", function()
        api.move_buffers(aManager, aWindow, -1, 0, vim.v.count1)
    end, { buffer = aWindow.BufNumber })

    vim.keymap.set({ "n" }, "L", function()
        api.move_buffers(aManager, aWindow, 0, 1, vim.v.count1)
    end, { buffer = aWindow.BufNumber })

    vim.keymap.set({ "n" }, "<leader>j", function()
        aWindow.Name = vim.fn.input { cancelreturn = "", prompt = "Type Name: " }
        api.delete_all(aManager)
        api.refresh(aManager)
    end, { buffer = aWindow.BufNumber })
end

---@param api table
---@param aManager WindowManager
---@param aWindow BufferSelectorWindow
function M.attach_delete_all(api, aManager, aWindow)
    vim.keymap.set({ "n" }, "<esc>", function()
        api.delete_all(aManager)
    end, { buffer = aWindow.BufNumber })

    vim.keymap.set({ "n" }, "D", function()
        local line = vim.fn.getline "."
        api.delete_buffer(aManager, aWindow, line)
    end, { buffer = aWindow.BufNumber })
end

---@param api table
---@param aManager WindowManager
function M.attach_open(api, aManager)
    vim.keymap.set({ "n" }, "<leader>j", function()
        api.refresh(aManager)
    end, {})
end

return M

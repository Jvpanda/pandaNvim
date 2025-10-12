local Api = {}
local general = require "tools.general_functions"
local breakpoint_list = {}
local raddbgJobId = nil
local panda_ns_id = 0

-- [[ General Functions ]]
local function get_buf_data()
    local currentBufNumber = vim.api.nvim_get_current_buf()
    local currentBufName = vim.api.nvim_buf_get_name(0):gsub("\\", "/")
    local currentLN = vim.api.nvim_win_get_cursor(0)
    return { name = currentBufName, number = currentBufNumber, row = currentLN[1], col = currentLN[2] }
end

local function set_visual_breakpoint_attributes()
    vim.api.nvim_set_hl(0, "PandaBreakpointLineHighlight", { bg = "#461B2F" })
    vim.fn.sign_define("PandaBreakpointSign", { text = "🔴", linehl = "PandaBreakpointLineHighlight" })
    vim.fn.sign_define("PandaDisabledBreakpointSign", { text = "⭕" })
    vim.api.nvim_set_hl(0, "PandaWatchHighlight", { underdouble = true, bold = true, italic = true, blend = 0 })
    panda_ns_id = vim.api.nvim_create_namespace "panda_watch_expr_highlight"
end

local function read_line_from_file(file, lineNumber)
    local f = io.open(file, "r")
    if not f then
        vim.notify("Cannot open file: " .. file, vim.log.levels.ERROR)
        return
    end

    local i = 1
    for line in f:lines() do
        if i == lineNumber then
            return line
        end
        i = i + 1
    end

    f:close()

    return "Line in file could not be found"
end

-- [[ MENU OPTIONS ]]
local function handle_main_menu(option, bufData)
    if option == "Kill Instance" then
        vim.system { "raddbg", "--ipc", "kill" }
        print "Killing"
    elseif option == "Run To Line" then
        vim.system { "raddbg", "--ipc", "run_to_line ", bufData.name .. ":" .. bufData.row }
        print "Running to Line"
    elseif option == "Halt" then
        vim.system { "raddbg", "--ipc", "halt" }
    end
end

-- [[ EXPOSED KEYMAP FUNCTIONS ]]
Api.get_breakpoints_from_raddbg = function()
    local r = vim.fn.system "raddbg --ipc list_breakpoints"
    local search = 0
    local list_number = 1
    while search ~= nil do
        search = string.find(r, "source_location", search + 1)
        if search == nil then
            break
        end
        local colon = string.find(r, ":", search + 20)
        local colon2 = string.find(r, ":", colon + 1)
        local newline = string.find(r, "\n", search + 1)

        breakpoint_list[list_number] = {}
        breakpoint_list[list_number].file_path = r:sub(search + 18, colon - 1):gsub("\\\\", "/")
        breakpoint_list[list_number].row = tonumber(r:sub(colon + 1, colon2 - 1))
        breakpoint_list[list_number].column = tonumber(r:sub(colon2 + 1, newline - 2))

        if r:sub(newline + 3, newline + 12) == "enabled: 1" then
            breakpoint_list[list_number].enabled = 1
        elseif r:sub(newline + 3, newline + 12) == "enabled: 0" then
            breakpoint_list[list_number].enabled = 0
        else
            breakpoint_list[list_number].enabled = 1
        end

        list_number = list_number + 1
    end
end

Api.set_breakpoint_signs_from_raddbg = function()
    breakpoint_list = {}
    get_breakpoints_from_raddbg()
    vim.fn.sign_unplace "PandaBreakpointGroup"
    for i in ipairs(breakpoint_list) do
        if vim.fn.bufexists(breakpoint_list[i].file_path) == 1 then
            if breakpoint_list[i].enabled == 0 then
                vim.fn.sign_place(0, "PandaBreakpointGroup", "PandaDisabledBreakpointSign", breakpoint_list[i].file_path, { lnum = breakpoint_list[i].row })
            else
                vim.fn.sign_place(0, "PandaBreakpointGroup", "PandaBreakpointSign", breakpoint_list[i].file_path, { lnum = breakpoint_list[i].row })
            end
        end
    end
end

Api.add_or_remove_breakpoint = function()
    local bufData = get_buf_data()
    local signData = vim.fn.sign_getplaced(bufData.number, { lnum = bufData.row, group = "PandaBreakpointGroup" })
    if signData[1].signs[1] == nil then
        vim.fn.sign_place(0, "PandaBreakpointGroup", "PandaBreakpointSign", bufData.number, { lnum = bufData.row })
        vim.fn.system { "raddbg", "--ipc", "add_breakpoint", bufData.name .. ":" .. bufData.row .. ":" .. bufData.col }
    else
        vim.fn.sign_unplace("PandaBreakpointGroup", { id = signData[1].signs[1].id })
        vim.fn.system { "raddbg", "--ipc", "remove_breakpoint", bufData.name .. ":" .. bufData.row }
    end
end

Api.toggle_breakpoint = function()
    local bufData = get_buf_data()
    local signData = vim.fn.sign_getplaced(bufData.number, { lnum = bufData.row, group = "PandaBreakpointGroup" })
    if signData[1].signs[1] == nil then
        return
    end
    if signData[1].signs[1].name == "PandaBreakpointSign" then
        vim.fn.sign_unplace("PandaBreakpointGroup", { id = signData[1].signs[1].id })
        vim.fn.sign_place(0, "PandaBreakpointGroup", "PandaDisabledBreakpointSign", bufData.number, { lnum = bufData.row })
        vim.fn.system { "raddbg", "--ipc", "disable_breakpoint", bufData.name .. ":" .. bufData.row }
    elseif signData[1].signs[1].name == "PandaDisabledBreakpointSign" then
        vim.fn.sign_unplace("PandaBreakpointGroup", { id = signData[1].signs[1].id })
        vim.fn.sign_place(0, "PandaBreakpointGroup", "PandaBreakpointSign", bufData.number, { lnum = bufData.row })
        vim.fn.system { "raddbg", "--ipc", "enable_breakpoint", bufData.name .. ":" .. bufData.row }
    end
end

Api.toggle_watch_expr = function()
    local bufData = get_buf_data()
    local word = vim.fn.expand "<cword>"
    local line = vim.api.nvim_get_current_line()
    local start_col, end_col = line:find(word, 1, true)
    local details = vim.api.nvim_buf_get_extmarks(0, panda_ns_id, { bufData.row - 1, start_col - 1 }, { bufData.row - 1, end_col - 1 }, { details = true })

    if details[1] == nil and start_col and end_col then
        vim.api.nvim_buf_set_extmark(0, panda_ns_id, bufData.row - 1, start_col - 1, {
            end_col = end_col,
            hl_group = "PandaWatchHighlight",
            priority = 1000,
        })
    elseif details[1][4].ns_id == panda_ns_id then
        vim.api.nvim_buf_del_extmark(0, panda_ns_id, details[1][1])
    end

    vim.fn.system { "raddbg", "--ipc", "toggle_watch_expr", word }
end

Api.debug_menu = function()
    local bufData = get_buf_data()
    general.customOptionsMenu({ "Kill Instance", "Halt", "Run To Line" }, { rowCount = 5, widthRatio = 0.2 }, handle_main_menu, bufData)
end

Api.runRadDbg = function(file_path, opts)
    set_visual_breakpoint_attributes()
    if raddbgJobId == nil then
        print(file_path)
        raddbgJobId = vim.fn.jobstart("raddbg " .. file_path, {
            on_stdout = function(_, data)
                print(vim.inspect(data))
            end,
            on_exit = function(job_id, code, event)
                print("RadDbg Exited:", job_id, "with code", code, "Event:", event)
                raddbgJobId = nil
            end,
        })
    elseif opts.run == "Step Into" then
        vim.system { "raddbg", "--ipc", "launch_and_step_into" }
    else
        vim.system { "raddbg", "--ipc", "run" }
    end
end

return Api

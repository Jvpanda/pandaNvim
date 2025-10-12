local cpp_keybinds = {}
local menu = require "language_configurations.cpp.cpp_menus"
local build = require "language_configurations.cpp.cpp_build_and_run"
local debug = require "language_configurations.cpp.raddbg"

-- [[ KEYBINDS ]]
function cpp_keybinds.setup_keybinds()
    -- [[Debug Keybinds ]]
    vim.keymap.set("n", "<F8>", debug.debug_menu, {})
    vim.keymap.set("n", "<F7>", function()
        vim.fn.system { "raddbg", "--ipc", "step_out" }
    end, {})
    vim.keymap.set("n", "<F6>", function()
        vim.fn.system { "raddbg", "--ipc", "step_into" }
    end, {})
    vim.keymap.set("n", "<F5>", function()
        vim.fn.system { "raddbg", "--ipc", "step_over" }
    end, {})

    vim.keymap.set("n", "<leader>ba", debug.add_or_remove_breakpoint, { desc = "[BA]dd or Remove Breakpoint" })

    vim.keymap.set("n", "<leader>bt", debug.toggle_breakpoint, { desc = "[B]oggle [T]reakpoint" })

    vim.keymap.set("n", "<leader>br", debug.set_breakpoint_signs_from_raddbg, { desc = "[BR]eset Breakpoints" })

    vim.keymap.set("n", "<leader>bw", debug.toggle_watch_expr, { desc = "[B]oggle a [W]atch expression" })

    --[[ Regular Keybinds ]]
    vim.keymap.set("n", "<F9>", menu.call_menu)

    vim.keymap.set("n", "<F10>", build.cmake_generate_ninja_files)

    vim.keymap.set("n", "<F11>", function()
        vim.notify(build.cmake_compile())
    end)

    vim.keymap.set("n", "<f12>", build.compile_and_run)

    vim.keymap.set("n", "<S-f12>", build.run_cpp)
end

return cpp_keybinds

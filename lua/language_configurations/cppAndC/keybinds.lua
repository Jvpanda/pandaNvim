local cpp_keybinds = {}
local opts = require "language_configurations.cppAndC.general_opts"

local conf = {}
conf["Generic"] = require "language_configurations.cppAndC.cpp.cpp_generic_api"
conf["Bare Metal Embedded"] = require "language_configurations.cppAndC.embedded_conf.c_embedded_build_and_run"

-- [[ALL KEYBINDS ]]
function cpp_keybinds.setup_keybinds()
    --[[ Regular Keybinds ]]
    vim.keymap.set("n", "<F9>", function()
        conf[opts.configuration].call_menu()
    end)

    vim.keymap.set("n", "<F10>", function()
        Async(conf[opts.configuration].build)
    end)

    vim.keymap.set("n", "<F11>", function()
        Async(conf[opts.configuration].compile)
    end)

    vim.keymap.set("n", "<f12>", function()
        Async(conf[opts.configuration].compile_and_run)
    end)

    vim.keymap.set("n", "<S-f12>", function()
        Async(conf[opts.configuration].run)
    end)

    -- Any other possible setup needed
    conf[opts.configuration].setup()
end

return cpp_keybinds

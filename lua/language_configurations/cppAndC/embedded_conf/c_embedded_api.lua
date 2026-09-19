local API = {}
local general = require "tools.general_functions"
local opts = require "language_configurations.cppAndC.general_opts"
local emb_build = require "language_configurations.cppAndC.embedded_conf.c_embedded_build_and_run"
local menu = require "language_configurations.cppAndC.embedded_conf.c_embedded_menus"

--[[ API FOR KEYBINDS]]

API.build = function()
    print("Generating Build Files for " .. opts.buildType)
    general.naPrint(emb_build.cmake_generate_build())
end

API.compile = function()
    if vim.fn.isdirectory("build/" .. opts.buildType) == 0 then
        API.build()
    end

    local isCompiled, result = emb_build.cmake_compile()
    general.naPrint(result)
end

API.flash = function()
    print "Flashing Board..."
    general.naPrint(emb_build.cmake_flash())
end

API.bin = function()
    print "Creating Bin File..."
    general.naPrint(emb_build.cmake_bin())
end

API.run = function()
    emb_build.run()
end

-- This will also flash
API.compile_and_run = function()
    local isCompiled, compilationResult = emb_build.cmake_compile()

    if isCompiled then
        general.naPrint(compilationResult)
        emb_build.cmake_flash()
        emb_build.run()
    else
        vim.notify(compilationResult)
    end
end

function API.call_menu()
    menu.call_menu()
end

return API

local M = {}
M.baseInstallDir = vim.fn.expand "~" .. "/AppData/Local/nvim-data/PandaInstallations/"
if vim.fn.has "Win32" == 0 then
    M.baseInstallDir = "$XDG_DATA_HOME/nvim/PandaInstallations/"
end

-- First folder in binary name doubles as a executable name

M.Pkgs = {
    ripgrep = {
        repo = "BurntSushi/ripgrep",
        binaryDir = "rg/",
        windowsTags = "x86_64%-pc%-windows%-msvc.zip",
        linuxTags = "x86_64%-unknown%-linux%-musl.tar.gz",
    },
    lua_ls = {
        repo = "LuaLS/lua-language-server",
        binaryDir = "lua-language-server/bin/",
        windowsTags = "win32%-x64.zip",
        linuxTags = "linux%-x64.tar.gz",
    },
    stylua = {
        repo = "JohnnyMorganz/StyLua",
        binaryDir = "stylua/",
        windowsTags = "windows%-x86_64.zip",
        linuxTags = "linux%-x86_64.zip",
    },
    arduino_lsp = {
        repo = "arduino/arduino-language-server",
        binaryDir = "arduino-language-server/",
        windowsTags = "windows_64bit.zip",
        linuxTags = "linux_64bit.tar.gz",
    },
    arduino_cli = {
        repo = "arduino/arduino-cli",
        binaryDir = "arduino-cli/",
        windowsTags = "windows_64bit.zip",
        linuxTags = "linux_64bit.tar.gz",
    },
    clangd = {
        repo = "clangd/clangd",
        binaryDir = "clangd/bin/",
        windowsTags = "clangd%-windows",
        linuxTags = "clangd%-linux",
    },
    raddbg = {
        repo = "EpicGamesExt/raddebugger",
        binaryDir = "raddbg/",
        windowsTags = "raddbg.zip",
        linuxTags = "NOLINUXVERSION",
    },
    ninja = {
        repo = "ninja-build/ninja",
        binaryDir = "ninja/",
        windowsTags = "ninja%-win.zip",
        linuxTags = "ninja%-linux.zip",
    },
    cmake = {
        repo = "Kitware/CMake",
        binaryDir = "cmake/bin/",
        windowsTags = "windows%-x86_64.zip",
        linuxTags = "linux%-x86_64.tar.gz",
    },
}

M.fullPkgs = {
    cpp = { M.Pkgs.clangd, M.Pkgs.raddbg, M.Pkgs.ninja, M.Pkgs.cmake },
    lua = { M.Pkgs.lua_ls, M.Pkgs.stylua },
    arduino = { M.Pkgs.arduino_cli, M.Pkgs.arduino_lsp },
    tools = { M.Pkgs.ripgrep },
}
return M

--TODO create links for linux
local baseInstallDir = vim.fn.expand "~" .. "/AppData/Local/nvim-data/PandaInstallations/"
local Pkgs = {
    ripgrep = {
        url = "https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-pc-windows-msvc.zip",
        installDir = baseInstallDir,
        binaryDir = baseInstallDir .. "ripgrep-14.1.1-x86_64-pc-windows-msvc/",
        executable = "rg",
    },
    lua_ls = {
        url = "https://github.com/LuaLS/lua-language-server/releases/download/3.15.0/lua-language-server-3.15.0-win32-x64.zip",
        installDir = baseInstallDir .. "lua-language-server-3.15.0-win32-x64/",
        binaryDir = baseInstallDir .. "lua-language-server-3.15.0-win32-x64/bin/",
        executable = "lua-language-server",
    },
    stylua = {
        url = "https://github.com/JohnnyMorganz/StyLua/releases/download/v2.1.0/stylua-windows-x86_64.zip",
        installDir = baseInstallDir .. "stylua-windows-x86_64/",
        binaryDir = baseInstallDir .. "stylua-windows-x86_64/",
        executable = "stylua",
    },
    arduino_lsp = {
        url = "https://github.com/arduino/arduino-language-server/releases/download/0.7.7/arduino-language-server_0.7.7_Windows_64bit.zip",
        installDir = baseInstallDir .. "arduino-language-server_0.7.7_Windows_64bit/",
        binaryDir = baseInstallDir .. "arduino-language-server_0.7.7_Windows_64bit/",
        executable = "arduino-language-server",
    },
    arduino_cli = {
        url = "https://github.com/arduino/arduino-cli/releases/download/v1.3.1/arduino-cli_1.3.1_Windows_64bit.zip",
        installDir = baseInstallDir .. "arduino-cli_1.3.1_Windows_64bit",
        binaryDir = baseInstallDir .. "arduino-cli_1.3.1_Windows_64bit",
        executable = "arduino-cli",
    },
    clangd = {
        url = "https://github.com/clangd/clangd/releases/download/21.1.0/clangd-windows-21.1.0.zip",
        installDir = baseInstallDir,
        binaryDir = baseInstallDir .. "clangd_21.1.0/bin/",
        executable = "clangd",
    },
    raddbg = {
        url = "https://github.com/EpicGamesExt/raddebugger/releases/download/v0.9.21-alpha/raddbg.zip",
        installDir = baseInstallDir .. "raddbg/",
        binaryDir = baseInstallDir .. "raddbg/",
        executable = "raddbg",
    },
    ninja = {
        url = "https://github.com/ninja-build/ninja/releases/download/v1.13.1/ninja-win.zip",
        installDir = baseInstallDir .. "ninja/",
        binaryDir = baseInstallDir .. "ninja/",
        executable = "ninja",
    },
    cmake = {
        url = "https://github.com/Kitware/CMake/releases/download/v4.1.2/cmake-4.1.2-windows-x86_64.zip",
        installDir = baseInstallDir,
        binaryDir = baseInstallDir .. "cmake-4.1.2-windows-x86_64/bin/",
        executable = "cmake",
    },
}

local fullPkgs = {
    cpp = { Pkgs.clangd, Pkgs.raddbg, Pkgs.ninja, Pkgs.cmake },
    lua = { Pkgs.lua_ls, Pkgs.stylua },
    arduino = { Pkgs.arduino_cli, Pkgs.arduino_lsp },
    tools = { Pkgs.ripgrep },
}

if vim.fn.has "Win32" == 0 then
    Pkgs = {}
    baseInstallDir = "$XDG_DATA_HOME/nvim/PandaInstallations/"
end

local createInstallDir = function()
    if vim.fn.isdirectory(baseInstallDir) == 0 then
        vim.fn.mkdir(baseInstallDir)
    end
end

local setEnvironmentVar = function(binaryDirectory)
    if vim.fn.isdirectory(binaryDirectory) == 1 then
        vim.env.PATH = vim.env.PATH .. ";" .. binaryDirectory
    end
end

local checkEnvironment = function()
    for _, pkg in pairs(Pkgs) do
        if vim.fn.isdirectory(pkg.binaryDir) == 1 then
            setEnvironmentVar(pkg.binaryDir)
        end
    end
end

local function download_and_unzip(url, destination_dir)
    if vim.fn.isdirectory(destination_dir) == 0 then
        vim.fn.mkdir(destination_dir)
    end

    local filename = vim.fn.fnamemodify(url, ":t") -- Get file name from URL
    local zip_path = destination_dir .. filename -- Full path to zip
    local unzip_dir = destination_dir -- Where to unzip

    -- Step 1: Download the file
    vim.system({ "curl", "-L", url, "-o", zip_path }, {}, function(obj)
        if obj.code ~= 0 then
            print("❌ Download" .. url .. " failed.")
            return
        end
        --print("✅ Download complete: " .. zip_path)

        -- Step 2: Unzip it
        vim.system({
            "tar",
            "-xf",
            zip_path,
            "-C",
            unzip_dir,
        }, {}, function(obj2)
            if obj2.code ~= 0 then
                print "❌ Unzip failed."
                return
            end
            --print("✅ Unzipped to: " .. unzip_dir)
            os.remove(zip_path)
            --print("🗑️ Deleted zip file: " .. zip_path)
            print("✅ " .. filename .. " installation completed")
        end)
    end)
end

local installPkg = function(pkg)
    if vim.fn.isdirectory(pkg.binaryDir) == 1 then
        print(pkg.executable .. " is already installed!")
        return
    end
    if vim.fn.executable(pkg.executable) == 1 then
        print(pkg.executable .. " is already on the device!")
        return
    end
    download_and_unzip(pkg.url, pkg.installDir)
    setEnvironmentVar(pkg.binaryDir)
end

vim.api.nvim_create_user_command("PandaInstall", function(opts)
    local arg = opts.args:lower()
    if arg == "all" then
        for _, fullPacks in pairs(fullPkgs) do
            for _, pack in pairs(fullPacks) do
                installPkg(pack)
            end
        end
    elseif fullPkgs[arg] ~= nil then
        for _, pack in pairs(fullPkgs[arg]) do
            installPkg(pack)
        end
    else
        print "Invalid Command"
        return
    end
end, {
    nargs = 1,
    desc = "My custom installs command",

    complete = function(ArgLead)
        local installs = { "all", "arduino", "lua", "tools", "cpp" }
        local matches = {}

        for _, individualInstalls in ipairs(installs) do
            if individualInstalls:lower():find("^" .. vim.pesc(ArgLead:lower())) then
                table.insert(matches, individualInstalls)
            end
        end

        return matches
    end,
})

local setupMyInstallations = function()
    createInstallDir()
    checkEnvironment()
end

setupMyInstallations()

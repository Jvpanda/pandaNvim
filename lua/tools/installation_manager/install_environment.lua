local general = require "tools.general_functions"
local packs = require "tools.installation_manager.packages"
local dl = require "tools.installation_manager.download_latest"

local createInstallDir = function()
    if vim.fn.isdirectory(packs.baseInstallDir) == 0 then
        vim.fn.mkdir(packs.baseInstallDir)
    end
end

local setEnvironmentVar = function(binaryDirectory)
    if vim.fn.isdirectory(packs.baseInstallDir .. binaryDirectory) == 1 then
        if general.isOnWindows() then
            vim.env.PATH = vim.env.PATH .. ";" .. packs.baseInstallDir .. binaryDirectory
        else
            vim.env.PATH = vim.env.PATH .. ":" .. packs.baseInstallDir .. binaryDirectory
        end
    end
end

local checkEnvironment = function()
    for _, pkg in pairs(packs.Pkgs) do
        if vim.fn.isdirectory(packs.baseInstallDir .. pkg.binaryDir) == 1 then
            setEnvironmentVar(pkg.binaryDir)
        end
    end
end

local function download_and_unzip(pkg)
    local downloadedFile, version = dl.download_latest(pkg)
    local filetype = vim.fn.fnamemodify(downloadedFile, ":e:e")
    print(filetype)

    local executableName = pkg.binaryDir:match "[^/]*"

    local unzipDir = packs.baseInstallDir .. pkg.binaryDir:match "[^/]*" .. "/"

    if vim.fn.isdirectory(unzipDir) == 0 then
        vim.fn.mkdir(unzipDir)
    end

    print(unzipDir)
    local unzipCommand = {}
    if filetype == "tar.gz" then
        print "Using this command"
        unzipCommand = {
            "tar",
            "-xzf",
            packs.baseInstallDir .. downloadedFile,
            "-C",
            unzipDir,
        }
    elseif filetype == "gz" then
        print("mv " .. packs.baseInstallDir .. downloadedFile .. " " .. unzipDir .. downloadedFile)
        os.execute("mv " .. packs.baseInstallDir .. downloadedFile .. " " .. unzipDir .. downloadedFile)
        unzipCommand = {
            "gzip",
            "-d",
            unzipDir .. downloadedFile,
        }
    elseif general.isOnWindows() == false then
        unzipCommand = {
            "unzip",
            packs.baseInstallDir .. downloadedFile,
            "-d",
            unzipDir,
        }
    else
        unzipCommand = {
            "tar",
            "-xf",
            packs.baseInstallDir .. downloadedFile,
            "-C",
            unzipDir,
        }
    end
    Await_System(unzipCommand)
    -- os.remove(packs.baseInstallDir .. downloadedFile)

    if general.isOnWindows() then
        if vim.fn.executable(packs.baseInstallDir .. pkg.binaryDir .. executableName) == 0 then
            local extraInstallFile = unpack(vim.split(vim.fn.glob(unzipDir .. "*"), "\n", { trimempty = true }))
            Await_System { "robocopy", extraInstallFile, unzipDir, "/E", "/MOVE" }
        end
    else
        if vim.fn.executable(packs.baseInstallDir .. pkg.binaryDir .. executableName) == 0 then
            if filetype == "gz" then
                os.execute("chmod 770 " .. unzipDir .. downloadedFile:sub(1, -4))
                os.execute("mv " .. unzipDir .. downloadedFile:sub(1, -4) .. " " .. unzipDir .. pkg.binaryDir:sub(1, -2))
            else
                local extraInstallFile = unpack(vim.split(vim.fn.glob(unzipDir .. "*"), "\n", { trimempty = true }))
                os.execute("mv " .. extraInstallFile .. "/* " .. unzipDir)
                Await_System { "rm", "-rf", extraInstallFile }
            end
        end
    end
    local versionFile = io.open(unzipDir .. "PandaVersion.txt", "w")
    if versionFile ~= nil then
        versionFile:write(version)
        versionFile:close()
    end

    print(executableName .. " installation completed ✅")
end

local installPkg = function(pkg)
    local executableName = pkg.binaryDir:match "[^/]*"
    if general.isOnWindows() == false and pkg.linuxTags == nil then
        print(executableName, "Not available on this system")
        return
    end

    if vim.fn.isdirectory(packs.baseInstallDir .. pkg.binaryDir) == 1 then
        print(executableName .. " is already installed!")
        return
    end
    if vim.fn.executable(executableName) == 1 then
        --Rust is the only one that still allows executable while it not being available
        local hasRust = true
        if executableName == "rust-analyzer" then
            local test = vim.fn.system "rust-analyzer --version"
            if test:find "error" ~= nil then
                hasRust = false
            end
        end

        if hasRust then
            print(executableName .. " is already on the device!")
            return
        end
    end

    download_and_unzip(pkg)
    setEnvironmentVar(pkg.binaryDir)
end

local checkUpdate = function(pkg)
    local installDir = packs.baseInstallDir .. pkg.binaryDir:match "[^/]*" .. "/"
    local executableName = pkg.binaryDir:match "[^/]*"

    if vim.fn.isdirectory(packs.baseInstallDir .. pkg.binaryDir) == 0 then
        return
    end

    local latestTag = dl.get_latest_tag(pkg)
    local versionFile = io.open(installDir .. "PandaVersion.txt", "r")
    local version = ""
    if versionFile ~= nil then
        for line in versionFile:lines() do
            version = line
        end
        versionFile:close()
    end
    if version ~= latestTag then
        print("UPADTE:", executableName, ":", version, "VS", latestTag)
    else
        print(executableName .. " is up to Date!")
    end
end

local setupMyInstallations = function()
    vim.api.nvim_create_user_command("PandaInstall", function(opts)
        local arg = opts.args:lower()
        if arg == "all" then
            for _, fullPacks in pairs(packs.fullPkgs) do
                for _, pack in pairs(fullPacks) do
                    Async(installPkg, pack)
                end
            end
        elseif arg == "update" then
            for _, fullPacks in pairs(packs.fullPkgs) do
                for _, pack in pairs(fullPacks) do
                    Async(checkUpdate, pack)
                end
            end
        elseif packs.fullPkgs[arg] ~= nil then
            for _, pack in pairs(packs.fullPkgs[arg]) do
                Async(installPkg, pack)
            end
        else
            print "Invalid Command"
            return
        end
    end, {
        nargs = 1,
        desc = "My custom installs command",

        complete = function(ArgLead)
            local installs = { "all", "arduino", "lua", "tools", "cpp", "update", "rust" }
            local matches = {}

            for _, individualInstalls in ipairs(installs) do
                if individualInstalls:lower():find("^" .. vim.pesc(ArgLead:lower())) then
                    table.insert(matches, individualInstalls)
                end
            end

            return matches
        end,
    })
    createInstallDir()
    checkEnvironment()
end

setupMyInstallations()

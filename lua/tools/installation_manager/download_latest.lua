local M = {}
local general = require "tools.general_functions"
local packs = require "tools.installation_manager.packages"

local function get_asset_url(tag, pkg)
    local url = "https://api.github.com/repos/" .. pkg.repo .. "/releases/" .. tag
    local curl_cmd = { "curl", "-sS", url }
    local response = Await_System(curl_cmd, {})
    local data = vim.fn.json_decode(response)

    if not data or not data.assets then
        error("Failed to fetch release info for " .. pkg.windowsTags)
        return nil
    end

    for _, asset in ipairs(data.assets) do
        local name = asset.name:lower()
        if general.isOnWindows() then
            if name:match(pkg.windowsTags) then
                return asset.browser_download_url
            end
        else
            if name:match(pkg.linuxTags) then
                return asset.browser_download_url
            end
        end
    end

    error("No matching asset found for " .. pkg.windowsTags)
    return nil
end

M.get_latest_tag = function(pkg)
    local release_url = "https://api.github.com/repos/" .. pkg.repo .. "/releases/latest"
    local curl_cmd = { "curl", "-s", release_url }
    local response = Await_System(curl_cmd, {})
    local data = vim.fn.json_decode(response)

    if not data or not data.tag_name then
        error "Failed to get latest release info."
        return
    end

    return data.tag_name
end

---@param pkg any A pacakge is expected
function M.download_latest(pkg)
    local latestTag = M.get_latest_tag(pkg)
    local tag = "tags/" .. latestTag
    local download_url = get_asset_url(tag, pkg)
    local filename = ""

    if download_url then
        filename = download_url:match ".+/([^/]+)$"
        print("Downloading: " .. filename)
        Await_System({ "curl", "-L", download_url, "-o", packs.baseInstallDir .. filename }, {})
    end
    return filename, latestTag
end

return M

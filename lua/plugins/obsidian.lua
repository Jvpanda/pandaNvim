return {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- use latest release, remove to use latest commit
    ft = "markdown",
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
        legacy_commands = false, -- this will be removed in the next major release
        attachments = {
            folder = "./attachments",
        },
        workspaces = {
            {
                name = "school",
                path = "/home/jacominto/Documents/Obsidian/School",
            },
        },
    },
}

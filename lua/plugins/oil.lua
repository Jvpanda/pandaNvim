return {
    {
        "stevearc/oil.nvim",
        dependencies = {},
        config = function()
            CustomOilBar = function()
                local path = vim.fn.expand "%"
                path = path:gsub("oil://", "")

                return "  " .. vim.fn.fnamemodify(path, ":.")
            end

            require("oil").setup {
                delete_to_trash = true,

                columns = { "icon" },
                keymaps = {
                    ["<C-h>"] = false,
                    ["<C-l>"] = false,
                    ["<C-k>"] = false,
                    ["<C-j>"] = false,
                    ["<M-h>"] = "actions.select_split",
                },
                win_options = {
                    winbar = "%{v:lua.CustomOilBar()}",
                },
                view_options = {
                    show_hidden = true,
                    is_always_hidden = function(name, _)
                        local folder_skip = {}
                        return vim.tbl_contains(folder_skip, name)
                    end,
                },
                float = {
                    padding = 2,
                    max_width = 100,
                    max_height = 35,
                    border = "rounded",
                    win_options = {
                        winblend = 0,
                        winbar = "%{v:lua.CustomOilBar()}",
                    },
                },
                -- Configuration for the file preview window
                preview_win = {
                    -- Whether the preview window is automatically updated when the cursor is moved
                    update_on_cursor_moved = true,
                    -- How to open the preview window "load"|"scratch"|"fast_scratch"
                    preview_method = "fast_scratch",
                    -- A function that returns true to disable preview on a file e.g. to avoid lag
                    disable_preview = function(filename)
                        return false
                    end,
                    -- Window-local options to use for preview window buffers
                    win_options = {},
                },
            }
        end,
    },
}

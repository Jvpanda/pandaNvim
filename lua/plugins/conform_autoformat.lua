return {
    { -- Autoformat
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format { async = true, lsp_format = "fallback" }
                end,
                mode = "",
                desc = "[F]ormat buffer",
            },
        },
        opts = {
            notify_on_error = false,
            format_on_save = function(bufnr)
                local enabled_filetypes = { lua = true }
                if enabled_filetypes[vim.bo[bufnr].filetype] then
                    return {
                        timeout_ms = 500,
                        lsp_format = "fallback",
                    }
                else
                    return nil
                end
            end,
            formatters_by_ft = {
                lua = { "stylua" },
                -- cpp = { "clang-format" },
                -- Conform can also run multiple formatters sequentially
                -- You can use 'stop_after_first' to run the first available formatter from the list
            },
            formatters = {
                -- clang_format = {
                --     prepend_args = { "--style=file" },
                -- },
            },
        },
    },
}

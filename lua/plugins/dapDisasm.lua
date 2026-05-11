return {
    {
        url = "https://codeberg.org/Jorenar/nvim-dap-disasm.git",
        dependencies = { "igorlfs/nvim-dap-view" },

        opts = {

            -- Add disassembly view to nvim-dap-view
            dapview_register = true,

            -- The sign to use for instruction the exectution is stopped at
            sign = "DapStopped",

            -- Number of instructions to show before the memory reference
            ins_before_memref = 16,

            -- Number of instructions to show after the memory reference
            ins_after_memref = 16,

            -- Columns to display in the disassembly view
            columns = {
                "address",
                "instructionBytes",
                "instruction",
            },
        },
    },
}

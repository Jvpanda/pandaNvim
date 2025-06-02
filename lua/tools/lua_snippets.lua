local ls = require "luasnip"
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node

vim.keymap.set({ "i", "s" }, "<C-l>", function()
    ls.jump(1)
end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-j>", function()
    ls.jump(-1)
end, { silent = true })

ls.add_snippets("all", {})

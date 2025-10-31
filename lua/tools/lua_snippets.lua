local ls = require "luasnip"
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local c = ls.choice_node
local d = ls.dynamic_node
local i = ls.insert_node
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node

local show_if_empty_line = function(lineUntilCursor)
    if lineUntilCursor:match "^%s*$" == nil then
        return false
    else
        return true
    end
end
local types = require "luasnip.util.types"
ls.config.set_config {
    history = true,
    updateevents = "TextChanged,TextChangedI",
    enable_autosnippets = true,
    ext_opts = {
        [types.choiceNode] = { active = { virt_text = { { "●", "@customColor.tea_rose_red" } } } },
        [types.insertNode] = { active = { virt_text = { { "●", "@customColor.cyan" } } } },
    },
    delete_check_events = "TextChanged",
}

vim.keymap.set({ "i", "s" }, "<C-k>", function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-j>", function()
    if ls.choice_active() then
        ls.change_choice(-1)
    end
end, { silent = true })

local get_case
get_case = function(position)
    return d(position, function()
        return sn(
            nil,
            fmt(
                "\tcase {}:\n\t\t{}\n\tbreak;\n{}",
                { i(1), i(2), c(3, { t { "", "};" }, get_case(3), sn(3, fmt("\tdefault:\n\t\t{}\n\tbreak;\n}};", { i(1) })) }) }
            )
        )
    end, {}, {})
end

local curly_snippet = function(position)
    return d(position, function()
        local line = vim.api.nvim_get_current_line()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local char_before = nil
        if col > 0 then
            char_before = line:sub(col - 1, col - 1)
        end

        if char_before == ")" then
            return sn(nil, fmt("{{\n\t{}\n}}\n{}", { i(1), i(0) }))
        else
            return sn(nil, fmt("{{{}", { i(0) }))
        end
    end, {}, {})
end

local generic_snippets = {
    s(
        { hidden = true, trig = "{", snippetType = "autosnippet" },
        fmt("{}", {
            curly_snippet(1),
        })
    ),
}

local cpp_snippets = {
    s("#ifndef", fmt("#ifndef {}\n#define {}\n{}\n{}\n#endif", { i(1), rep(1), i(2), i(0) }), { show_condition = show_if_empty_line }),

    s("for", fmt("for(int {} = 0;{} < {}; {}++){{\n\t{}\n}}\n{}", { i(1), rep(1), i(2), rep(1), i(3), i(0) }), { show_condition = show_if_empty_line }),
    s("class", fmt("class {}{{\n\tpublic:\n\t\t{}\n\tprivate:\n\t\t{}\n}};\n{}", { i(1), i(2), i(3), i(0) }), { show_condition = show_if_empty_line }),
    s("hello world", fmt('#include <iostream>\n\nint main(){{\n\tstd::cout << "HELLO GEAMY";\n\treturn 0;\n}} ', {}), { show_condition = show_if_empty_line }),

    s("switch", fmt("switch({}){{\n{}\n{}", { i(1), get_case(2), i(0) }), { show_condition = show_if_empty_line }),
}

local lua_snippets = {
    s("if", fmt("if {} then\n\t{}\nend\n{}", { i(1), i(2), i(0) }), { show_condition = show_if_empty_line }),
}

-- ls.cleanup()
ls.add_snippets("all", generic_snippets)
ls.add_snippets("cpp", cpp_snippets)
ls.add_snippets("lua", lua_snippets)
-- ls.add_snippets("all", cpp_snippets)
-- ls.add_snippets("all", lua_snippets)

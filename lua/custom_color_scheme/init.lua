local M = {}

M.setup = function()
    vim.cmd "highlight clear"
    --[[
    if vim.fn.exists "syntax_on" then
        vim.cmd "syntax reset"
    end
    ]]

    vim.o.termguicolors = true
    vim.g.colors_name = "cutesy"

    local c = {
        fg_placeholder = "#E7D8EA",
        bg_placeholder = "#2B1B2F",
        bg = "#2b1b2f",
        fg = "#E7D8EA",
        off_dark_bg = "#391E3F",
        pink_lavender = "#f5bde6",
        lavender_pink = "#F7A6D1",
        mauve = "#c6a0f6",
        green = "#abe9b3",
        yellow = "#f9e2af",
        periwinkle = "#d0bfff",
        cool_gray = "#9994B5",
        red = "#f28fad",
        cyan = "#b5f4f0",
        plum_web = "#E6ABE3",
        pale_dogwood = "#FFD5C6",
        tea_rose_red = "#FFCDCD",
    }

    local function hi(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
    end

    -- Standard Common Groups
    hi("Comment", { fg = c.cool_gray, italic = true })
    hi("Constant", { fg = c.yellow })
    hi("String", { fg = c.pink_lavender })
    hi("Identifier", { fg = c.periwinkle })
    hi("Function", { fg = c.periwinkle })
    hi("Statement", { fg = c.green, bold = true })
    hi("Keyword", { fg = c.green, bold = true })
    hi("Type", { fg = c.periwinkle })
    hi("Special", { fg = c.cyan })
    hi("Number", { fg = c.yellow })
    hi("Boolean", { fg = c.yellow })
    hi("Error", { fg = c.red, bold = true })
    hi("Todo", { fg = c.pink_lavender, bold = true })
    hi("Delimiter", { fg = c.cyan })

    -- UI Elements
    hi("LineNr", { fg = c.cool_gray })
    hi("CursorLineNr", { fg = c.cyan, bold = true })
    hi("CursorLine", { fg = "NONE", bg = c.off_dark_bg })
    hi("StatusLine", { fg = c.fg, bg = c.bg })
    hi("Pmenu", { fg = c.fg, bg = "#3b2b3f" })
    hi("PmenuSel", { fg = c.bg, bg = c.pink_lavender, bold = true })
    hi("Visual", { bg = "#403050" })
    hi("Search", { bg = c.yellow, fg = c.bg })

    hi("Folded", { fg = c.cool_gray, bg = c.off_dark_bg })

    hi("Normal", { fg = c.fg, bg = "none" })
    hi("NormalFloat", { fg = c.fg, bg = "none" })
    hi("FloatBorder", { fg = c.mauve })

    hi("WinSeparator", { fg = c.cool_gray })

    -- Ts Groups
    hi("@variable", { fg = c.fg })
    hi("@type.builtin", { fg = c.plum_web })

    -- LSP Groups
    hi("@lsp.type.macro", { fg = c.pale_dogwood })
    hi("@lsp.type.class", { fg = c.tea_rose_red })
    hi("@lsp.type.property", { fg = c.cyan })

    -- IBL
    hi("IblScope", { fg = c.cool_gray, bg = "none" })

    -- SE Highlighting
    hi("seGrammar", { fg = c.green })
    hi("seVocab", { fg = c.cyan })
    hi("seTenses", { fg = c.lavender_pink })
    hi("seNote", { fg = c.mauve })
    hi("seBrackets", { fg = c.yellow })
    -- TEXT Highlighting

    hi("textContext", { fg = c.green, bg = c.bg_placeholder })
    hi("textMainIdea", { fg = c.cyan, bg = c.bg_placeholder })
    hi("textSummary", { fg = c.red, bg = c.bg_placeholder })
    hi("textDefinition", { fg = c.yellow, bg = c.bg_placeholder })
    hi("textSupport", { fg = c.plum_web, bg = c.bg_placeholder })
    hi("textImportant", { fg = c.red, bg = c.bg_placeholder })
    hi("newLevel", { fg = c.periwinkle, bg = c.bg_placeholder })

    --[[
    hi("ColorColumn", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("Conceal", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("CurSearch", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("Cursor", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("lCursor", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("CursorIM", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("CursorColumn", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("CursorLine", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("Directory", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("DiffAdd", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("DiffChange", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("DiffDelete", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("DiffText", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("DiffTextAdd", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("EndOfBuffer", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("TermCursor", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("ErrorMsg", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("StderrMsg", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("StdoutMsg", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("WinSeparator", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("Folded", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("FoldColumn", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("SignColumn", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("IncSearch", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("Substitute", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("LineNr", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("LineNrAbove", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("LineNrBelow", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("CursorLineNr", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("CursorLineFold", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("CursorLineSign", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("MatchParen", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("ModeMsg", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("MsgArea", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("MsgSeparator", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("MoreMsg", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("NonText", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("Normal", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("NormalFloat", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("FloatBorder", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("FloatTitle", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("FloatFooter", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("NormalNC", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("Pmenu", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("PmenuSel", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("PmenuKind", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("PmenuKindSel", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("PmenuExtra", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("PmenuExtraSel", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("PmenuSbar", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("PmenuThumb", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("PmenuMatch", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("PmenuMatchSel", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("ComplMatchIns", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("Question", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("QuickFixLine", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("Search", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("SnippetTabstop", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("SpecialKey", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("SpellBad", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("SpellCap", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("SpellLocal", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("SpellRare", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("StatusLine", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("StatusLineNC", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("StatusLineTerm", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("StatusLineTermNC", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("TabLine", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("TabLineFill", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("TabLineSel", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("Title", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("Visual", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("VisualNOS", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("WarningMsg", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("Whitespace", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("WildMenu", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("WinBar", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    hi("WinBarNC", { fg = c.fg_placeholder, bg = c.bg_placeholder })
    ]]
end

M.setup()

return M

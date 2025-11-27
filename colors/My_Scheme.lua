local c = {
    fg = "#E7D8EA",
    bg = "#2b1b2f",
    off_dark_bg = "#391E3F",
    lighter_bg = "#59496A",
    cool_gray = "#9994B5",
    green = "#abe9b3",
    cyan = "#b5f4f0",
    uranian_blue = "#BFDCFF",
    periwinkle = "#d0bfff",
    mauve = "#c6a0f6",
    light_mauve = "#F0A6FF",
    pink_lavender = "#f5bde6",
    tea_rose_red = "#FFCDCD",
    peach = "#FFC59F",
    red = "#f28fad",
    yellow = "#f9e2af",
}

local function hi(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

local function setupTreeSitterLuaColors()
    hi("@customColor.fg", { fg = c.fg, bg = "NONE" })
    hi("@customColor.bg", { fg = c.fg, bg = c.bg })
    hi("@customColor.off_dark_bg", { fg = c.fg, bg = c.off_dark_bg })
    hi("@customColor.lighter_bg", { fg = c.fg, bg = c.lighter_bg })
    hi("@customColor.cool_gray", { fg = c.cool_gray, bg = "NONE" })
    hi("@customColor.green", { fg = c.green, bg = "NONE" })
    hi("@customColor.cyan", { fg = c.cyan, bg = "NONE" })
    hi("@customColor.uranian_blue", { fg = c.uranian_blue, bg = "NONE" })
    hi("@customColor.periwinkle", { fg = c.periwinkle, bg = "NONE" })
    hi("@customColor.mauve", { fg = c.mauve, bg = "NONE" })
    hi("@customColor.light_mauve", { fg = c.light_mauve, bg = "NONE" })
    hi("@customColor.pink_lavender", { fg = c.pink_lavender, bg = "NONE" })
    hi("@customColor.tea_rose_red", { fg = c.tea_rose_red, bg = "NONE" })
    hi("@customColor.peach", { fg = c.peach, bg = "NONE" })
    hi("@customColor.red", { fg = c.red, bg = "NONE" })
    hi("@customColor.yellow", { fg = c.yellow, bg = "NONE" })
end

local setup = function()
    vim.cmd "highlight clear"

    vim.o.termguicolors = true
    vim.g.colors_name = "cutesy"

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
    hi("Delimiter", { fg = c.cyan })

    -- UI Elements
    hi("LineNr", { fg = c.cool_gray })
    hi("EndOfBuffer", { fg = c.bg, bg = "NONE" }) --the little ~ at the end

    hi("CursorLineNr", { fg = c.cyan, bold = true })
    hi("CursorLine", { fg = "NONE", bg = c.off_dark_bg })

    hi("StatusLine", { fg = c.fg, bg = c.bg })
    hi("StatusLineNC", { fg = c.cool_gray, bg = "NONE" })

    hi("Pmenu", { fg = c.uranian_blue, bg = "NONE" }) --Menu for completion list
    hi("PmenuSel", { fg = c.bg, bg = c.pink_lavender, bold = true }) --Selection
    hi("PmenuSbar", { fg = "NONE", bg = c.off_dark_bg }) -- Scroll bar
    hi("PmenuThumb", { fg = "NONE", bg = c.mauve })

    hi("Visual", { fg = "NONE", bg = c.lighter_bg }) --Visual mode and lsp hover
    hi("CurSearch", { bg = c.lighter_bg, fg = c.yellow }) --Current search
    hi("Search", { bg = c.lighter_bg, fg = c.yellow }) --Past searches

    hi("Folded", { fg = c.cool_gray, bg = c.off_dark_bg })

    hi("Normal", { fg = c.fg, bg = "#1C1C1C" })
    hi("NormalNC", { fg = c.fg, bg = "none" }) --Other window text
    hi("NormalFloat", { fg = c.fg, bg = "none" }) --Flating window text
    hi("FloatBorder", { fg = c.mauve })

    hi("WinSeparator", { fg = c.cool_gray })

    -- Ts Groups
    hi("@variable", { fg = c.fg })
    hi("@constant.builtin", { fg = c.light_mauve })
    hi("@type.builtin", { fg = c.light_mauve })
    hi("@keyword.modifier", { fg = c.tea_rose_red })

    -- LSP Groups
    hi("@lsp.type.macro", { fg = c.peach })
    hi("@lsp.type.class", { fg = c.peach })
    hi("@lsp.type.property", { fg = c.uranian_blue })
    hi("@lsp.type.namespace", { fg = c.mauve })
    hi("@lsp.mod.defaultLibrary", { fg = c.red })
    hi("@lsp.typemod.function.defaultLibrary", { fg = c.periwinkle })

    -- IBL
    hi("IblScope", { fg = c.cool_gray, bg = "none" })
end

setup()
setupTreeSitterLuaColors()

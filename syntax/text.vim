syntax keyword textContext Context Background Review
syntax keyword textMainIdea Main Idea
syntax keyword textSummary Summary Conclusion
syntax keyword textDefinition Definition Methodology Analysis
syntax keyword textSupport Support Evidence Example
syntax keyword textGrammars Grammar Tense Tenses

syntax region textImportant     start="IMPORTANT" end="\n"
syntax region textNewLevel          start=" - "         end="\n"
syntax region textQuotes     start="\"" end="\""

highlight link textContext @customColor.green
highlight link textMainIdea @customColor.cyan
highlight link textSummary @customColor.red
highlight link textDefinition @customColor.yellow
highlight link textSupport @customColor.light_mauve
highlight link textGrammars @customColor.peach
highlight link textImportant @customColor.red
highlight link textNewLevel @customColor.periwinkle
highlight link textQuotes @customColor.pink_lavender



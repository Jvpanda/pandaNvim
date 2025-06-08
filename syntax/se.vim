" Define keywords (still helpful visually)
syntax keyword seGrammar grammar
syntax keyword seVocab vocab
syntax keyword seTenses tenses
syntax keyword seDefinition Definition

syntax region seNote     start="NOTE" end="\n"  contains=seBrackets keepend 
syntax region seBrackets start="\["   end="\]"  contained


package main

import "core:fmt"
import "tokenizer"

main :: proc() {
	using tokenizer
	tok: Tokenizer
	tokenizer_init(&tok, "=")
	token := tokenizer_next(&tok)
	names := token_names
	fmt.printfln("id: %s, lexum: %s", names[token.type], token.literal)
}

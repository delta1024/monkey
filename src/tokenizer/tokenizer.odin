package tokenizer

Tokenizer :: struct {
	input:                   string,
	position, read_position: int,
	ch:                      u8,
}

tokenizer_init :: proc(tokenizer: ^Tokenizer, source: string) {
	tokenizer.input = source
	tokenizer.read_position = 0
	tokenizer.position = 0
	tokenizer.ch = 0
	read_char(tokenizer)
}

@(private = "file")
read_char :: proc(tokenizer: ^Tokenizer) {
	if tokenizer.read_position >= len(tokenizer.input) {
		tokenizer.ch = 0
	} else {
		tokenizer.ch = tokenizer.input[tokenizer.read_position]
	}
	tokenizer.position = tokenizer.read_position
	tokenizer.read_position += 1
}

tokenizer_next :: proc(tokenizer: ^Tokenizer) -> (tok: Token) {
	switch tokenizer.ch {
	case '=':
		tok = new_token(.Assign, tokenizer)

	case ';':
		tok = new_token(.Semicolon, tokenizer)
	case '(':
		tok = new_token(.LParen, tokenizer)
	case ')':
		tok = new_token(.RParen, tokenizer)
	case ',':
		tok = new_token(.Comma, tokenizer)
	case '+':
		tok = new_token(.Plus, tokenizer)
	case '{':
		tok = new_token(.LBrace, tokenizer)
	case '}':
		tok = new_token(.RBrace, tokenizer)
	case 0:
		tok.literal = ""
		tok.type = .Eof
	case:
		tok = new_token(.Illegal, "Unknown token")
	}
	read_char(tokenizer)
	return
}


@(private = "file")
new_tokenizer_token :: proc(id: TokenType, tokenizer: ^Tokenizer, start_pos: int = 0) -> Token {
	start_pos: int = start_pos
	if start_pos == 0 {
		start_pos = tokenizer.position
	}
	return Token{id, tokenizer.input[start_pos:tokenizer.read_position]}

}
@(private = "file")
new_string_token :: proc(id: TokenType, lexum: string) -> Token {
	return Token{id, lexum}
}

@(private = "file")
new_token :: proc {
	new_tokenizer_token,
	new_string_token,
}

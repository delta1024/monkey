#+feature dynamic-literals
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

tokenizer_next :: proc(tokenizer: ^Tokenizer) -> (tok: Token) {
	skip_whitespace(tokenizer)
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
	case '!':
		tok = new_token(.Bang, tokenizer)
	case '-':
		tok = new_token(.Minus, tokenizer)
	case '/':
		tok = new_token(.Slash, tokenizer)
	case '*':
		tok = new_token(.Asterisk, tokenizer)
	case '<':
		tok = new_token(.Lt, tokenizer)
	case '>':
		tok = new_token(.Gt, tokenizer)
	case 0:
		tok.literal = ""
		tok.type = .Eof
	case:
		if is_letter(tokenizer.ch) {
			tok.literal = read_identifier(tokenizer)
			tok.type = lookup_ident(tok.literal)
			return
		} else if is_digit(tokenizer.ch) {
			tok.type = .Int
			tok.literal = read_number(tokenizer)
			return
		} else {
			tok = new_token(.Illegal, "Unknown token")
		}
	}
	read_char(tokenizer)
	return
}

@(private = "file")
skip_whitespace :: proc(tokenizer: ^Tokenizer) {
	for tokenizer.ch == ' ' ||
	    tokenizer.ch == '\t' ||
	    tokenizer.ch == '\n' ||
	    tokenizer.ch == '\r' {
		read_char(tokenizer)
	}
}

@(private = "file")
lookup_ident :: proc(ident: string) -> TokenType {
	keywords := map[string]TokenType {
		"fn"  = .Function,
		"let" = .Let,
	}
	defer delete(keywords)
	ident, ok := keywords[ident]
	if !ok {
		ident = TokenType.Ident
	}
	return ident
}

@(private = "file")
is_letter :: proc(ch: u8) -> bool {
	return 'a' <= ch && ch <= 'z' || 'A' <= ch && ch <= 'Z' || ch == '_'
}

@(private = "file")
read_identifier :: proc(tokenizer: ^Tokenizer) -> string {
	position := tokenizer.position
	for is_letter(tokenizer.ch) {
		read_char(tokenizer)
	}
	return tokenizer.input[position:tokenizer.position]
}

@(private = "file")
is_digit :: proc(ch: u8) -> bool {
	return '0' <= ch && ch <= '9'
}

@(private = "file")
read_number :: proc(tokenizer: ^Tokenizer) -> string {
	position := tokenizer.position

	for is_digit(tokenizer.ch) {
		read_char(tokenizer)
	}
	return tokenizer.input[position:tokenizer.position]
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

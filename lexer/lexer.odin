package lexer
import "../token"

Lexer :: struct {
	input:         string,
	position:      int,
	read_position: int,
	ch:            byte,
}

init_lexer :: proc(input: string) -> Lexer {
	l: Lexer
	l.input = input
	read_char(&l)
	return l
}
next_token :: proc(l: ^Lexer) -> (tok: token.Token) {
	switch l.ch {
	case '=':
		tok = new_token(.Assign)
	case ';':
		tok = new_token(.Semi_Colon)
	case '(':
		tok = new_token(.L_Paren)
	case ')':
		tok = new_token(.R_Paren)
	case ',':
		tok = new_token(.Comma)
	case '+':
		tok = new_token(.Plus)
	case '{':
		tok = new_token(.L_Brace)
	case '}':
		tok = new_token(.R_Brace)
	case 0:
		tok.literal = ""
		tok.type = .Eof
	case:
		tok.type = .Illegal
		tok.literal = l.input[l.position:l.read_position]
	}
	read_char(l)
	return tok
}

@(private)
read_char :: proc(l: ^Lexer) {
	if l.read_position >= len(l.input) {
		l.ch = 0
	} else {
		l.ch = l.input[l.read_position]
	}
	l.position = l.read_position
	l.read_position += 1
}

@(private)
new_token_single :: proc(type: token.Token_Type) -> token.Token {
	return {type, token.token_strings[type]}
}
@(private)
new_token :: proc {
	new_token_single,
}

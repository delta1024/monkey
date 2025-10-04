#+feature dynamic-literals
package lexer
import "../token"
import "core:text/scanner"

Lexer :: struct {
	input:         string,
	position:      int,
	read_position: int,
	ch:            byte,
}

@(private)
Whitespace :: bit_set[byte('\t') ..= byte(' ')]
@(private)
MONKEY_WHITESPACE: Whitespace : {' ', '\t', '\n', '\r'}
init_lexer :: proc(input: string) -> Lexer {
	l: Lexer
	l.input = input
	read_char(&l)
	return l
}
next_token :: proc(l: ^Lexer) -> (tok: token.Token) {


	for {
		if l.ch not_in MONKEY_WHITESPACE {
			break
		}
		read_char(l)
	}
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
	case '-':
		tok = new_token(.Minus)
	case '!':
		tok = new_token(.Bang)
	case '/':
		tok = new_token(.Slash)
	case '*':
		tok = new_token(.Asterisk)
	case '<':
		tok = new_token(.Lt)
	case '>':
		tok = new_token(.Gt)
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
		if is_letter(l.ch) {
			tok.literal = read_identifier(l)
			tok.type = look_up_ident(tok.literal)
			return tok
		} else if is_digit(l.ch) {
			tok.type = .Int
			tok.literal = read_number(l)
			return tok
		} else {

			tok.type = .Illegal
			tok.literal = l.input[l.position:l.read_position]
		}
	}
	read_char(l)
	return tok
}
@(private)
look_up_ident :: proc(ident: string) -> token.Token_Type {
	keywords := map[string]token.Token_Type {
		"fn"     = .Function,
		"let"    = .Let,
		"true"   = .True,
		"false"  = .False,
		"if"     = .If,
		"else"   = .Else,
		"return" = .Return,
	}
	defer delete(keywords)
	if tok, ok := keywords[ident]; ok {
		return tok
	}
	return .Ident
}
@(private)
read_identifier :: proc(l: ^Lexer) -> string {

	position := l.position
	for is_letter(l.ch) {
		read_char(l)
	}
	return l.input[position:l.position]
}
@(private)
is_letter :: proc(ch: byte) -> bool {
	return 'a' <= ch && ch <= 'z' || 'A' <= ch && ch <= 'Z' || ch == '_'
}
@(private)
read_number :: proc(l: ^Lexer) -> string {
	position := l.position

	for is_digit(l.ch) {
		read_char(l)
	}
	return l.input[position:l.position]
}
@(private)
is_digit :: proc(ch: byte) -> bool {
	return '0' <= ch && ch <= '9'
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

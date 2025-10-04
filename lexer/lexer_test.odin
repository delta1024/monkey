#+private
package lexer

import "../token"
import "core:testing"
ASSIGN: token.Token : {.Assign, "="}
PLUS: token.Token : {.Plus, "+"}
L_PAREN: token.Token : {.L_Paren, "("}
R_PAREN: token.Token : {.R_Paren, ")"}
L_BRACE: token.Token : {.L_Brace, "{"}
R_BRACE: token.Token : {.R_Brace, "}"}
COMMA: token.Token : {.Comma, ","}
SEMI_COLON: token.Token : {.Semi_Colon, ";"}
EOF: token.Token : {.Eof, ""}
LET: token.Token : {.Let, "let"}
FUNCTION: token.Token : {.Function, "fn"}
BANG: token.Token : {.Bang, "!"}
MINUS: token.Token : {.Minus, "-"}
SLASH: token.Token : {.Slash, "/"}
ASTERISK: token.Token : {.Asterisk, "*"}
LT: token.Token : {.Lt, "<"}
GT: token.Token : {.Gt, ">"}

ident :: #force_inline proc($lexum: string) -> token.Token {
	return {.Ident, lexum}
}

integer :: #force_inline proc($num: string) -> token.Token {
	return {.Int, num}
}

@(test)
test_next_token :: proc(t: ^testing.T) {
	input :: `let five = 5;
let ten = 10;

let add = fn(x, y) {
  x + y;
};

let result = add(five, ten);
!-/*5;
5 < 10 > 5;
`


	tests := []token.Token {
		LET,
		ident("five"),
		ASSIGN,
		integer("5"),
		SEMI_COLON,
		LET,
		ident("ten"),
		ASSIGN,
		integer("10"),
		SEMI_COLON,
		LET,
		ident("add"),
		ASSIGN,
		FUNCTION,
		L_PAREN,
		ident("x"),
		COMMA,
		ident("y"),
		R_PAREN,
		L_BRACE,
		ident("x"),
		PLUS,
		ident("y"),
		SEMI_COLON,
		R_BRACE,
		SEMI_COLON,
		LET,
		ident("result"),
		ASSIGN,
		ident("add"),
		L_PAREN,
		ident("five"),
		COMMA,
		ident("ten"),
		R_PAREN,
		SEMI_COLON,
		BANG,
		MINUS,
		SLASH,
		ASTERISK,
		integer("5"),
		SEMI_COLON,
		integer("5"),
		LT,
		integer("10"),
		GT,
		integer("5"),
		SEMI_COLON,
		EOF,
	}

	l := init_lexer(input)

	for tt in tests {
		tok := next_token(&l)
		testing.expect_value(t, tok, tt)
	}
}

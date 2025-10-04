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
IF: token.Token : {.If, "if"}
RETURN: token.Token : {.Return, "return"}
TRUE: token.Token : {.True, "true"}
ELSE: token.Token : {.Else, "else"}
FALSE: token.Token : {.False, "false"}
EQ: token.Token : {.Eq, "=="}
NOT_EQ: token.Token : {.Not_Eq, "!="}

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

if (5 < 10) {
    return true;
} else {
    return false;
}

10 == 10;
10 != 9;
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
		IF,
		L_PAREN,
		integer("5"),
		LT,
		integer("10"),
		R_PAREN,
		L_BRACE,
		RETURN,
		TRUE,
		SEMI_COLON,
		R_BRACE,
		ELSE,
		L_BRACE,
		RETURN,
		FALSE,
		SEMI_COLON,
		R_BRACE,
		integer("10"),
		EQ,
		integer("10"),
		SEMI_COLON,
		integer("10"),
		NOT_EQ,
		integer("9"),
		SEMI_COLON,
		EOF,
	}

	l := init_lexer(input)

	for tt in tests {
		tok := next_token(&l)
		testing.expect_value(t, tok, tt)
	}
}

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

@(test)
test_next_token :: proc(t: ^testing.T) {
	input :: `=+(){},;`

	tests := []token.Token {
		ASSIGN,
		PLUS,
		L_PAREN,
		R_PAREN,
		L_BRACE,
		R_BRACE,
		COMMA,
		SEMI_COLON,
		EOF,
	}

	l := init_lexer(input)

	for tt in tests {
		tok := next_token(&l)
		testing.expect_value(t, tok, tt)
	}
}

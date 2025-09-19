package tokenizer_tests
import "../../src/tokenizer"
import "core:testing"


@(private)
assert_token_eq :: proc(t: ^testing.T, expected, token: tokenizer.Token, loc := #caller_location) {
	testing.expectf(
		t,
		expected.type == token.type,
		"Expected %v, got %v",
		expected.type,
		token.type,
		loc = loc,
	)
	testing.expectf(
		t,
		expected.literal == token.literal,
		"Expected %s, got %s",
		expected.literal,
		token.literal,
		loc = loc,
	)
}
@(test)
test_single_character_tokens :: proc(t: ^testing.T) {
	input := `=;(){},+`

	lexer: tokenizer.Tokenizer
	tokenizer.tokenizer_init(&lexer, input)

	tests := []tokenizer.Token {
		{.Assign, "="},
		{.Semicolon, ";"},
		{.LParen, "("},
		{.RParen, ")"},
		{.LBrace, "{"},
		{.RBrace, "}"},
		{.Comma, ","},
		{.Plus, "+"},
	}

	for expected in tests {
		token := tokenizer.tokenizer_next(&lexer)
		assert_token_eq(t, expected, token)
	}
}

@(test)
test_ints_idnts_let_fn :: proc(t: ^testing.T) {
	LET :: Token{.Let, "let"}
	SCOLON :: Token{.Semicolon, ";"}
	ASSIGN :: Token{.Assign, "="}
	FIVE :: Token{.Ident, "five"}
	TEN :: Token{.Ident, "ten"}
	X :: Token{.Ident, "x"}
	Y :: Token{.Ident, "y"}
	ADD :: Token{.Ident, "add"}
	COMMA :: Token{.Comma, ","}
	LPAREN :: Token{.LParen, "("}
	RPAREN :: Token{.RParen, ")"}
	input :: `let five = 5;
let ten = 10;

let add = fn(x, y) {
  x + y;
};

let result = add(five, ten);`


	Token :: tokenizer.Token


	tests := []Token {
		LET,
		FIVE,
		ASSIGN,
		{.Int, "5"},
		SCOLON,
		LET,
		TEN,
		ASSIGN,
		{.Int, "10"},
		SCOLON,
		LET,
		ADD,
		ASSIGN,
		{.Function, "fn"},
		LPAREN,
		X,
		COMMA,
		Y,
		RPAREN,
		{.LBrace, "{"},
		X,
		{.Plus, "+"},
		Y,
		SCOLON,
		{.RBrace, "}"},
		SCOLON,
		LET,
		{.Ident, "result"},
		ASSIGN,
		ADD,
		LPAREN,
		FIVE,
		COMMA,
		TEN,
		RPAREN,
		SCOLON,
		{.Eof, ""},
	}
	lexer: tokenizer.Tokenizer
	tokenizer.tokenizer_init(&lexer, input)
	for expected in tests {
		token := tokenizer.tokenizer_next(&lexer)
		assert_token_eq(t, expected, token)
	}
}

@(test)
test_single_char_tokens_extended :: proc(t: ^testing.T) {
	input :: `!-/*5;
5 < 10 > 5;`


	using tokenizer
	FIVE :: tokenizer.Token{.Int, "5"}
	SCOLON :: tokenizer.Token{.Semicolon, ";"}
	TEN :: tokenizer.Token{.Int, "10"}

	tests := []Token {
		{.Bang, "!"},
		{.Minus, "-"},
		{.Slash, "/"},
		{.Asterisk, "*"},
		FIVE,
		SCOLON,
		FIVE,
		{.Lt, "<"},
		TEN,
		{.Gt, ">"},
		FIVE,
		SCOLON,
		{.Eof, ""},
	}

	lexer: Tokenizer
	tokenizer_init(&lexer, input)
	for expected in tests {
		token := tokenizer_next(&lexer)
		assert_token_eq(t, expected, token)
	}
}
@(test)
test_remaining_keywords :: proc(t: ^testing.T) {
	input :: `if (5 < 10) {
    return true;
} else {
    return false;
}`


	RETURN :: tokenizer.Token{.Return, "return"}
	SCOLON :: tokenizer.Token{.Semicolon, ";"}

	using tokenizer
	tests := []Token {
		{.If, "if"},
		{.LParen, "("},
		{.Int, "5"},
		{.Lt, "<"},
		{.Int, "10"},
		{.RParen, ")"},
		{.LBrace, "{"},
		RETURN,
		{.True, "true"},
		SCOLON,
		{.RBrace, "}"},
		{.Else, "else"},
		{.LBrace, "{"},
		RETURN,
		{.False, "false"},
		SCOLON,
		{.RBrace, "}"},
		{.Eof, ""},
	}

	lexer: Tokenizer
	tokenizer_init(&lexer, input)

	for expected in tests {
		token := tokenizer_next(&lexer)
		assert_token_eq(t, expected, token)
	}
}

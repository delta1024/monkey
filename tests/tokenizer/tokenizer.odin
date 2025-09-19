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
	input := "=;(){},+"

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

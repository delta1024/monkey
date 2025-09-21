package parser_tests

import "../../src/ast"
import "../../src/ast/parser"
import "../../src/tokenizer"
import "core:testing"
@(test)
test_identifier_expression :: proc(t: ^testing.T) {
	using parser
	input :: "foobar;"

	lexer: tokenizer.Tokenizer
	tokenizer.tokenizer_init(&lexer, input)

	parser := parser_create(lexer)
	defer parser_destroy(parser)

	program := parse_program(&parser)
	defer ast.node_delete(program)
	check_parser_error(t, &parser)

	testing.expectf(
		t,
		len(program.statements) == 1,
		"program has not enough statements. got=%d",
		len(program.statements),
	)

	stmt := program.statements[0].(^ast.ExpressionStatement)

	ident := stmt.expression.(^ast.Identifier)

	testing.expectf(
		t,
		ident.value == "foobar",
		"ident.value not %s. got=%s",
		"foobar",
		ident.value,
	)

	testing.expectf(
		t,
		ast.token_literal(ident) == "foobar",
		"token_literal(ident) not %s. got=%s",
		"foobar",
		ast.token_literal(ident),
	)

}

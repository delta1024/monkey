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

@(test)
test_integer_literal_expression :: proc(t: ^testing.T) {
	using parser
	input :: "5;"

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

	literal := stmt.expression.(^ast.IntegerLiteral)

	testing.expectf(t, literal.value == 5, "literal.value not %d. got=%d", 5, literal.value)

	testing.expectf(
		t,
		ast.token_literal(literal) == "5",
		"token_literal(literal) not %s. got=%s",
		"5",
		ast.token_literal(literal),
	)

}
@(test)
test_parsing_prefix_expressions :: proc(t: ^testing.T) {
	prefix_tests := []struct {
		input, operator: string,
		integer_value:   i64,
	}{{"!5;", "!", 5}, {"-15;", "-", 15}}

	for tt in prefix_tests {
		using parser
		lexer: tokenizer.Tokenizer
		tokenizer.tokenizer_init(&lexer, tt.input)

		parser := parser_create(lexer)
		defer parser_destroy(parser)

		program := parse_program(&parser)
		defer ast.node_delete(program)
		check_parser_error(t, &parser)

		testing.expectf(
			t,
			len(program.statements) == 1,
			"program.statements does not contian %d statements. got=%d\n",
			1,
			len(program.statements),
		)

		stmt := program.statements[0].(^ast.ExpressionStatement)

		exp := stmt.expression.(^ast.PrefixExpression)

		testing.expectf(
			t,
			exp.operator == tt.operator,
			"exp.operator is not %s. got=%s",
			tt.operator,
			exp.operator,
		)

		test_integer_literal(t, exp.right, tt.integer_value)

	}
}

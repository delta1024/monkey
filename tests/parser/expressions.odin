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

	stmt, ok := program.statements[0].(^ast.ExpressionStatement)

	if !ok {
		fail_expected_statement(
			t,
			"program.statements[0]",
			"ast.ExpressionStatement",
			program.statements[0],
		)
	}

	ident, expr_ok := stmt.expression.(^ast.Identifier)
	if !expr_ok {
		fail_expected_expression(t, "stmt.expression", "ast.Identifier", stmt.expression)
	}
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

	stmt, ok := program.statements[0].(^ast.ExpressionStatement)

	if !ok {
		fail_expected_statement(
			t,
			"program.statements[0]",
			"ast.ExpressionStatement",
			program.statements[0],
		)
	}

	test_integer_literal(t, "stmt.expression", stmt.expression, 5)


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

		stmt, ok := program.statements[0].(^ast.ExpressionStatement)

		if !ok {
			fail_expected_statement(
				t,
				"program.statements[0]",
				"ast.ExpressionStatement",
				program.statements[0],
			)
		}
		exp, expr_ok := stmt.expression.(^ast.PrefixExpression)
		if !expr_ok {
			fail_expected_expression(t, "stmt.expression", "ast.PrefixExpression", stmt.expression)
		}

		testing.expectf(
			t,
			exp.operator == tt.operator,
			"exp.operator is not %s. got=%s",
			tt.operator,
			exp.operator,
		)

		test_integer_literal(t, "exp.right", exp.right, tt.integer_value)

	}
}
@(test)
test_parseing_infix_expressions :: proc(t: ^testing.T) {
	infix_tests := []struct {
		input:       string,
		left_value:  i64,
		operator:    string,
		right_value: i64,
	} {
		{"5 + 5;", 5, "+", 5},
		{"5 - 5;", 5, "-", 5},
		{"5 * 5;", 5, "*", 5},
		{"5 / 5;", 5, "/", 5},
		{"5 > 5;", 5, ">", 5},
		{"5 < 5;", 5, "<", 5},
		{"5 == 5;", 5, "==", 5},
		{"5 != 5;", 5, "!=", 5},
	}

	for tt in infix_tests {
		lexer: tokenizer.Tokenizer
		tokenizer.tokenizer_init(&lexer, tt.input)

		using parser
		parser := parser_create(lexer)
		defer parser_destroy(parser)

		program := parse_program(&parser)
		defer ast.node_delete(program)

		check_parser_error(t, &parser)

		testing.expectf(
			t,
			len(program.statements) == 1,
			"program.statements does not contain %d statements. got=%d\n",
			1,
			len(program.statements),
		)

		stmt, ok := program.statements[0].(^ast.ExpressionStatement)

		if !ok {
			fail_expected_statement(
				t,
				"program.statements[0]",
				"ast.ExpressionStatement",
				program.statements[0],
			)
		}

		exp, expr_ok := stmt.expression.(^ast.InfixExpression)

		if !expr_ok {
			fail_expected_expression(t, "stmt.expression", "ast.InfixExpression", stmt.expression)
		}
		test_integer_literal(t, "exp.right", exp.left, tt.left_value)

		testing.expectf(
			t,
			exp.operator == tt.operator,
			"exp.operator is not '%s'. got=%s",
			tt.operator,
			exp.operator,
		)
		test_integer_literal(t, "exp.right", exp.right, tt.right_value)
	}
}
@(test)
test_operator_precedence_parsing :: proc(t: ^testing.T) {
	tests := []struct {
		input, expected: string,
	} {
		{"-a * b", "((-a) * b)"},
		{"!-a", "(!(-a))"},
		{"a + b + c", "((a + b) + c)"},
		{"a + b - c", "((a + b) - c)"},
		{"a * b * c", "((a * b) * c)"},
		{"a * b / c", "((a * b) / c)"},
		{"a + b / c", "(a + (b / c))"},
		{"a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"},
		{"3 + 4; -5 * 5", "(3 + 4)((-5) * 5)"},
		{"5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"},
		{"5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))"},
		{"3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"},
	}

	for tt in tests {
		lexer: tokenizer.Tokenizer
		tokenizer.tokenizer_init(&lexer, tt.input)
		using parser
		parser := parser_create(lexer)
		defer parser_destroy(parser)

		program := parse_program(&parser)
		defer ast.node_delete(program)

		check_parser_error(t, &parser)

		actual := ast.node_string(program)
		defer delete(actual)

		testing.expectf(t, actual == tt.expected, "expected=%s, got=%s", tt.expected, actual)
	}
}

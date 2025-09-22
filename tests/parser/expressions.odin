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
test_boolean_expression :: proc(t: ^testing.T) {
	using parser
	input :: "true;"

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
	test_literal_expression(t, "stmt.expression", stmt.expression, true)
}
@(test)
test_parsing_prefix_expressions :: proc(t: ^testing.T) {
	prefix_tests := []struct {
		input, operator: string,
		value:           LiteralVaule,
	}{{"!5;", "!", 5}, {"-15;", "-", 15}, {"!true;", "!", true}, {"!false;", "!", false}}

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

		test_literal_expression(t, "exp.right", exp.right, tt.value)

	}
}
@(test)
test_parseing_infix_expressions :: proc(t: ^testing.T) {
	infix_tests := []struct {
		input:       string,
		left_value:  LiteralVaule,
		operator:    string,
		right_value: LiteralVaule,
	} {
		{"5 + 5;", 5, "+", 5},
		{"5 - 5;", 5, "-", 5},
		{"5 * 5;", 5, "*", 5},
		{"5 / 5;", 5, "/", 5},
		{"5 > 5;", 5, ">", 5},
		{"5 < 5;", 5, "<", 5},
		{"5 == 5;", 5, "==", 5},
		{"5 != 5;", 5, "!=", 5},
		{"true == true", true, "==", true},
		{"true != false", true, "!=", false},
		{"false == false", false, "==", false},
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

		test_infix_expression(
			t,
			"stmt.expression",
			stmt.expression,
			tt.left_value,
			tt.operator,
			tt.right_value,
		)
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
		{"true", "true"},
		{"false", "false"},
		{"3 > 5 == false", "((3 > 5) == false)"},
		{"3 < 5 == true", "((3 < 5) == true)"},
		{"1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"},
		{"(5 + 5) * 2", "((5 + 5) * 2)"},
		{"2 / (5 + 5)", "(2 / (5 + 5))"},
		{"-(5 + 5)", "(-(5 + 5))"},
		{"!(true == true)", "(!(true == true))"},
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
@(test)
test_if_expression :: proc(t: ^testing.T) {
	input :: "if (x < y) { x }"

	lexer: tokenizer.Tokenizer
	tokenizer.tokenizer_init(&lexer, input)

	using parser
	parser := parser_create(lexer)
	defer parser_destroy(parser)

	program := parse_program(&parser)
	defer ast.node_delete(program)
	check_parser_error(t, &parser)

	testing.expectf(
		t,
		len(program.statements) == 1,
		"program.statements does not contain %d statements. got=%d",
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

	exp, exp_ok := stmt.expression.(^ast.IfExpression)
	if !exp_ok {
		fail_expected_expression(t, "stmt.expression", "ast.IfExpression", stmt.expression)
	}

	test_infix_expression(t, "exp.condition", exp.condition, "x", "<", "y")

	testing.expectf(
		t,
		len(exp.consequence.statements) == 1,
		"consequence is not 1 statements. got=%d\n",
		len(exp.consequence.statements),
	)

	consequence, conseq_ok := exp.consequence.statements[0].(^ast.ExpressionStatement)
	if !conseq_ok {
		fail_expected_statement(
			t,
			"exp.consequence.statements[0]",
			"ast.ExpressionStatement",
			exp.consequence.statements[0],
		)
	}

	test_identifier(t, "consequence.expression", consequence.expression, "x")

	testing.expect_value(t, exp.alternative, nil)
}
@(test)
test_if_else_expression :: proc(t: ^testing.T) {
	input :: "if (x < y) { x } else { y }"

	lexer: tokenizer.Tokenizer
	tokenizer.tokenizer_init(&lexer, input)

	using parser
	parser := parser_create(lexer)
	defer parser_destroy(parser)

	program := parse_program(&parser)
	defer ast.node_delete(program)
	check_parser_error(t, &parser)

	testing.expectf(
		t,
		len(program.statements) == 1,
		"program.statements does not contain %d statements. got=%d",
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

	exp, exp_ok := stmt.expression.(^ast.IfExpression)
	if !exp_ok {
		fail_expected_expression(t, "stmt.expression", "ast.IfExpression", stmt.expression)
	}

	test_infix_expression(t, "exp.condition", exp.condition, "x", "<", "y")

	testing.expectf(
		t,
		len(exp.consequence.statements) == 1,
		"consequence is not 1 statements. got=%d\n",
		len(exp.consequence.statements),
	)

	consequence, conseq_ok := exp.consequence.statements[0].(^ast.ExpressionStatement)
	if !conseq_ok {
		fail_expected_statement(
			t,
			"exp.consequence.statements[0]",
			"ast.ExpressionStatement",
			exp.consequence.statements[0],
		)
	}

	test_identifier(t, "consequence.expression", consequence.expression, "x")


	alternative, alt_ok := exp.alternative.statements[0].(^ast.ExpressionStatement)
	if !alt_ok {
		fail_expected_statement(
			t,
			"exp.alternative.statements[0]",
			"ast.ExpressionStatement",
			exp.alternative.statements[0],
		)
	}

	test_identifier(t, "alternative.expression", alternative.expression, "y")

}
@(test)
test_function_literal_parsing :: proc(t: ^testing.T) {
	input :: `fn(x, y) { x + y; }`

	lexer: tokenizer.Tokenizer
	tokenizer.tokenizer_init(&lexer, input)

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

	stmt, stmt_ok := program.statements[0].(^ast.ExpressionStatement)

	if !stmt_ok {
		fail_expected_statement(
			t,
			"program.statements[0]",
			"ast.ExpressionStatement",
			program.statements[0],
		)
	}

	function, fn_ok := stmt.expression.(^ast.FunctionLiteral)
	if !fn_ok {
		fail_expected_expression(t, "stmt.expression", "ast.FunctionLiteral", stmt.expression)
	}

	testing.expectf(
		t,
		len(function.parameters) == 2,
		"function literal parameters wrong. want 2, got=%d\n",
		len(function.parameters),
	)

	test_literal_expression(t, "function.parameters[0]", function.parameters[0], "x")
	test_literal_expression(t, "function.parameters[1]", function.parameters[1], "y")

	testing.expectf(
		t,
		len(function.body.statements) == 1,
		"function.Body.Statements has not 1 statements. got=%d\n",
		len(function.body.statements),
	)

	body_stmt, body_ok := function.body.statements[0].(^ast.ExpressionStatement)

	if !body_ok {
		fail_expected_statement(
			t,
			"function body stmt",
			"ast.ExpressionStatement",
			function.body.statements[0],
		)
	}

	test_infix_expression(t, "body_stmt.expression", body_stmt.expression, "x", "+", "y")
}
@(test)
test_function_paramater_parsing :: proc(t: ^testing.T) {
	tests := []struct {
		input:           string,
		expected_params: []string,
	}{{"fn() {};", {}}, {"fn(x) {};", {"x"}}, {"fn(x, y, z) {};", {"x", "y", "z"}}}

	for tt in tests {
		lexer: tokenizer.Tokenizer
		tokenizer.tokenizer_init(&lexer, tt.input)

		using parser
		parser := parser_create(lexer)
		defer parser_destroy(parser)

		program := parse_program(&parser)
		defer ast.node_delete(program)
		check_parser_error(t, &parser)

		stmt, _ := program.statements[0].(^ast.ExpressionStatement)
		function, _ := stmt.expression.(^ast.FunctionLiteral)

		testing.expectf(
			t,
			len(function.parameters) == len(tt.expected_params),
			"length parameters wrong. want %d, got=%d\n",
			len(tt.expected_params),
			len(function.parameters),
		)

		for ident, i in tt.expected_params {
			test_literal_expression(t, "function.paramaters[i]", function.parameters[i], ident)
		}
	}
}

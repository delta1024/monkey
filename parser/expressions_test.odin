#+private
package parser

import "../ast"
import "../lexer"
import "core:fmt"
import "core:testing"

@(test)
test_identifier_statement :: proc(t: ^testing.T) {
	input :: "foobar;"

	l := lexer.init_lexer(input)
	p := new_parser(l)
	defer parser_free_errors(&p)

	program := parse_program(&p)
	check_parser_errors(t, &p)
	defer ast.delete_node(program)

	testing.expectf(
		t,
		len(program.statements) == 1,
		"program has not enough statements. got=%d",
		len(program.statements),
	)
	stmt :=
		program.statements[0].(^ast.Expression_Statement) or_else testing.fail_now(
			t,
			fmt.tprint(
				"expected ^ast.Expression_Statement. got=%s",
				stmt_varient_name(program.statements[0]),
			),
		)

	test_literal_expression(t, stmt.expression, "foobar")
}
@(test)
test_integer_literal_expression :: proc(t: ^testing.T) {
	input :: "5;"

	l := lexer.init_lexer(input)
	p := new_parser(l)
	defer parser_free_errors(&p)

	program := parse_program(&p)
	check_parser_errors(t, &p)
	defer ast.delete_node(program)

	testing.expect_value(t, len(program.statements), 1)
	stmt :=
		program.statements[0].(^ast.Expression_Statement) or_else testing.fail_now(
			t,
			fmt.tprint(
				"expected ^ast.Expression_Statement. got=%s",
				stmt_varient_name(program.statements[0]),
			),
		)


	test_literal_expression(t, stmt.expression, int(5))
}
@(test)
test_boolean_literal_expression :: proc(t: ^testing.T) {
	input := "true;"

	l := lexer.init_lexer(input)
	p := new_parser(l)
	defer parser_free_errors(&p)

	program := parse_program(&p)
	check_parser_errors(t, &p)
	defer ast.delete_node(program)

	testing.expect_value(t, len(program.statements), 1)
	stmt :=
		program.statements[0].(^ast.Expression_Statement) or_else testing.fail_now(
			t,
			fmt.tprint(
				"expected ^ast.Expression_Statement. got=%s",
				stmt_varient_name(program.statements[0]),
			),
		)


	test_literal_expression(t, stmt.expression, true)

}
@(test)
test_parsing_prefix_expressions :: proc(t: ^testing.T) {
	prefix_tests := []struct {
		input:         string,
		operator:      string,
		integer_value: Expected_Value,
	}{{"!5", "!", int(5)}, {"-15", "-", int(15)}, {"!true;", "!", true}, {"!false;", "!", false}}

	for tt in prefix_tests {
		l := lexer.init_lexer(tt.input)
		p := new_parser(l)
		defer parser_free_errors(&p)

		program := parse_program(&p)
		defer ast.delete_node(program)
		check_parser_errors(t, &p)

		testing.expect_value(t, len(program.statements), 1)

		stmt :=
			program.statements[0].(^ast.Expression_Statement) or_else testing.fail_now(
				t,
				fmt.tprint(
					"expected ^ast.Expression_Statement. got=%s",
					stmt_varient_name(program.statements[0]),
				),
			)


		exp :=
			stmt.expression.(^ast.Prefix_Expression) or_else testing.fail_now(
				t,
				fmt.tprint(
					"expected ^ast.Prefix_Expression. got=%s",
					expr_varient_name(stmt.expression),
				),
			)


		testing.expect_value(t, exp.operator, tt.operator)

		test_literal_expression(t, exp.right, tt.integer_value)
	}
}

@(test)
test_parsing_infix_expressions :: proc(t: ^testing.T) {
	infix_tests := []struct {
		input:       string,
		left_value:  Expected_Value,
		operator:    string,
		right_value: Expected_Value,
	} {
		{"5 + 5;", i64(5), "+", i64(5)},
		{"5 - 5;", i64(5), "-", i64(5)},
		{"5 * 5;", i64(5), "*", i64(5)},
		{"5 / 5;", i64(5), "/", i64(5)},
		{"5 > 5;", i64(5), ">", i64(5)},
		{"5 < 5;", i64(5), "<", i64(5)},
		{"5 == 5;", i64(5), "==", i64(5)},
		{"5 != 5;", i64(5), "!=", i64(5)},
		{"true == true", true, "==", true},
		{"true != false", true, "!=", false},
		{"false == false", false, "==", false},
	}

	for tt in infix_tests {
		l := lexer.init_lexer(tt.input)
		p := new_parser(l)
		defer parser_free_errors(&p)

		program := parse_program(&p)
		defer ast.delete_node(program)
		check_parser_errors(t, &p)

		testing.expect_value(t, len(program.statements), 1)

		stmt :=
			program.statements[0].(^ast.Expression_Statement) or_else testing.fail_now(
				t,
				fmt.tprint(
					"expected ^ast.Expression_Statement. got=%s",
					stmt_varient_name(program.statements[0]),
				),
			)


		exp :=
			stmt.expression.(^ast.Infix_Expression) or_else testing.fail_now(
				t,
				fmt.tprint(
					"expected ^ast.InfixExpression. got=%s",
					expr_varient_name(stmt.expression),
				),
			)


		test_literal_expression(t, exp.left, tt.left_value)

		testing.expect_value(t, exp.operator, tt.operator)

		test_literal_expression(t, exp.right, tt.right_value)
	}
}
@(test)
test_operator_precedence_parsing :: proc(t: ^testing.T) {
	tests := []struct {
		input:    string,
		expected: string,
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
	}

	for tt in tests {
		l := lexer.init_lexer(tt.input)
		p := new_parser(l)
		defer parser_free_errors(&p)

		program := parse_program(&p)
		defer ast.delete_node(program)
		check_parser_errors(t, &p)

		actual := ast.node_string(program)

		testing.expect_value(t, actual, tt.expected)
	}
}

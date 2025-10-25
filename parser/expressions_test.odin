#+private
package parser

import "../ast"
import "../lexer"
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
	stmt := program.statements[0].(^ast.Expression_Statement)

	ident := stmt.expression.(^ast.Identifier)

	testing.expect_value(t, ident.value, "foobar")
	testing.expect_value(t, ast.token_literal(ident), "foobar")
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
	stmt := program.statements[0].(^ast.Expression_Statement)

	literal := stmt.expression.(^ast.Integer_Literal)

	testing.expect_value(t, literal.value, 5)

	testing.expect_value(t, ast.token_literal(literal), "5")
}
@(test)
test_parsing_prefix_expressions :: proc(t: ^testing.T) {
	prefix_tests := []struct {
		input:         string,
		operator:      string,
		integer_value: i64,
	}{{"!5", "!", 5}, {"-15", "-", 15}}

	for tt in prefix_tests {
		l := lexer.init_lexer(tt.input)
		p := new_parser(l)
		defer parser_free_errors(&p)

		program := parse_program(&p)
		defer ast.delete_node(program)
		check_parser_errors(t, &p)

		testing.expect_value(t, len(program.statements), 1)

		stmt := program.statements[0].(^ast.Expression_Statement)

		exp := stmt.expression.(^ast.Prefix_Expression)

		testing.expect_value(t, exp.operator, tt.operator)

		test_integer_literal(t, exp.right, tt.integer_value)
	}
}

@(test)
test_parsing_infix_expressions :: proc(t: ^testing.T) {
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
		l := lexer.init_lexer(tt.input)
		p := new_parser(l)
		defer parser_free_errors(&p)

		program := parse_program(&p)
		defer ast.delete_node(program)
		check_parser_errors(t, &p)

		testing.expect_value(t, len(program.statements), 1)

		stmt := program.statements[0].(^ast.Expression_Statement)

		exp := stmt.expression.(^ast.Infix_Expression)

		test_integer_literal(t, exp.left, tt.left_value)

		testing.expect_value(t, exp.operator, tt.operator)

		test_integer_literal(t, exp.right, tt.right_value)
	}
}

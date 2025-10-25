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

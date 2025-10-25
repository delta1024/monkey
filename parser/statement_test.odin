#+private
package parser

import "../ast"
import "../lexer"
import "core:fmt"
import "core:testing"

@(test)
test_let_statements :: proc(t: ^testing.T) {


	tests := []struct {
		input:               string,
		expected_identifier: string,
		expected_value:      Expected_Value,
	}{{"let x = 5;", "x", int(5)}, {"let y = true;", "y", true}, {"let foobar = y", "foobar", "y"}}

	for tt, i in tests {
		l := lexer.init_lexer(tt.input)
		p := new_parser(l)
		defer parser_free_errors(&p)

		program := parse_program(&p)
		defer ast.delete_node(program)
		check_parser_errors(t, &p)

		testing.expect_value(t, len(program.statements), 1)

		stmt := program.statements[0]
		test_let_statement(t, stmt, tt.expected_identifier)

		val := stmt.(^ast.Let_Statement)
		let_val := val.value
		test_literal_expression(t, let_val, tt.expected_value)
	}
}

@(test)
test_return_statements :: proc(t: ^testing.T) {
	input := `
return 5;
return 10;
return 993322;
`


	l := lexer.init_lexer(input)
	p := new_parser(l)
	defer parser_free_errors(&p)

	program := parse_program(&p)
	check_parser_errors(t, &p)
	defer ast.delete_node(program)
	testing.expect_value(t, len(program.statements), 3)

	for stmt in program.statements {
		ret_stmt := stmt.(^ast.Return_Statement)

		tok_lit := ast.token_literal(ret_stmt)
		testing.expect_value(t, tok_lit, "return")
	}

}

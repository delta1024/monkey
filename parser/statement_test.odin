#+private
package parser

import "../ast"
import "../lexer"
import "core:testing"

@(test)
test_let_statements :: proc(t: ^testing.T) {
	input := `
let x = 5;
let y = 10;
let foobar = 838383;
`


	l := lexer.init_lexer(input)
	p := new_parser(l)
	defer parser_free_errors(&p)

	program := parse_program(&p)
	if program == nil {
		testing.fail_now(t, "parse_program returned nil")
	}
	defer ast.delete_node(program)
	check_parser_errors(t, &p)

	testing.expect_value(t, len(program.statements), 3)

	tests := []struct {
		expected_identifier: string,
	}{{"x"}, {"y"}, {"foobar"}}

	for tt, i in tests {
		stmt := program.statements[i]
		test_let_statement(t, stmt, tt.expected_identifier)
	}
}

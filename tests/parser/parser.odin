package parser_tests

import "../../src/ast"
import "../../src/ast/parser"
import "../../src/tokenizer"
import "core:testing"
@(test)
test_let_statements :: proc(t: ^testing.T) {
	using parser
	input :: `
let x = 5;
let y = 10;
let foobar = 838383;
`


	lexer: tokenizer.Tokenizer
	tokenizer.tokenizer_init(&lexer, input)
	parser := parser_create(lexer)
	defer parser_destroy(parser)

	program := parse_program(&parser)
	check_parser_error(t, &parser)
	if program == nil {
		testing.fail_now(t, "parse_program() returned nil")
	}
	defer ast.node_delete(program)
	testing.expectf(
		t,
		len(program.statements) == 3,
		"program.statements does not contain 3 statements. got=%d",
		len(program.statements),
	)

	tests := []struct {
		expected_identifier: string,
	}{{"x"}, {"y"}, {"foobar"}}

	for tt, i in tests {
		stmt := program.statements[i]
		test_let_statement(t, stmt, tt.expected_identifier)
	}
}
@(test)
test_return_statement :: proc(t: ^testing.T) {
	using parser
	input :: `
return 5;
return 10;
return 993322;
`


	lexer: tokenizer.Tokenizer
	tokenizer.tokenizer_init(&lexer, input)

	parser := parser_create(lexer)
	defer parser_destroy(parser)

	program := parse_program(&parser)
	check_parser_error(t, &parser)
	defer ast.node_delete(program)

	testing.expectf(
		t,
		len(program.statements) == 3,
		"program.statements does not contain 3 statements. got=%d",
		len(program.statements),
	)

	for stmt in program.statements {
		return_stmt := stmt.(^ast.ReturnStatement)

		testing.expectf(
			t,
			ast.token_literal(return_stmt) == "return",
			"token_literal(return_stmt) not 'return'. get %s",
			ast.token_literal(return_stmt),
		)
	}


}

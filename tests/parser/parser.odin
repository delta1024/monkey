package parser_tests

import "../../src/ast"
import "../../src/ast/parser"
import "../../src/tokenizer"
import "core:testing"
@(test)
test_let_statements :: proc(t: ^testing.T) {
	using parser
	tests := []struct {
		input:               string,
		expected_identifier: string,
		expected_value:      LiteralVaule,
	}{{"let x = 5;", "x", 5}, {"let y = true;", "y", true}, {"let foobar = y;", "foobar", "y"}}

	for tt in tests {
		lexer: tokenizer.Tokenizer
		tokenizer.tokenizer_init(&lexer, tt.input)
		parser := parser_create(lexer)
		defer parser_destroy(parser)
		program := parse_program(&parser)
		check_parser_error(t, &parser)
		defer ast.node_delete(program)

		testing.expectf(
			t,
			len(program.statements) == 1,
			"program.statements does not contain 1 statements. got=%d",
			len(program.statements),
		)

		stmt := program.statements[0]
		test_let_statement(t, "stmt", stmt, tt.expected_identifier)

		val_stmt := stmt.(^ast.LetStatement)
		val := val_stmt.value

		test_literal_expression(t, "val", val, tt.expected_value)
	}


}
@(test)
test_return_statement :: proc(t: ^testing.T) {
	using parser
	tests := []struct {
		input:          string,
		expected_value: i64,
	}{{"return 5;", 5}, {"return 10;", 10}, {"return 993322;", 993322}}

	for tt in tests {
		lexer: tokenizer.Tokenizer
		tokenizer.tokenizer_init(&lexer, tt.input)

		parser := parser_create(lexer)
		defer parser_destroy(parser)

		program := parse_program(&parser)
		check_parser_error(t, &parser)
		defer ast.node_delete(program)

		testing.expectf(
			t,
			len(program.statements) == 1,
			"program.statements does not contain 1 statements. got=%d",
			len(program.statements),
		)


		return_stmt, ok := program.statements[0].(^ast.ReturnStatement)
		if !ok {
			fail_expected_statement(
				t,
				"program.statements[0]",
				"ast.ReturnStatement",
				program.statements[0],
			)
		}
		testing.expectf(
			t,
			ast.token_literal(return_stmt) == "return",
			"token_literal(return_stmt) not 'return'. get %s",
			ast.token_literal(return_stmt),
		)

		test_literal_expression(
			t,
			"return_stmt.return_value",
			return_stmt.return_value,
			tt.expected_value,
		)
	}


}
@(test)
test_string :: proc(t: ^testing.T) {
	using ast
	stmts := make([dynamic]Statement)
	append(
		&stmts,
		&LetStatement {
			token = {.Let, "let"},
			name = &Identifier{token = {.Ident, "myVar"}, value = "myVar"},
			value = &Identifier{token = {.Ident, "anotherVar"}, value = "anotherVar"},
		},
	)
	defer delete(stmts)
	program := &Program{statements = stmts}
	program_str := node_string(program)
	defer delete(program_str)

	testing.expect_value(t, program_str, "let myVar = anotherVar;")
}

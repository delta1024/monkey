package parser_tests

import "../../src/ast"
import "../../src/ast/parser"
import "core:fmt"
import "core:strings"
import "core:testing"
@(private)
test_let_statement :: proc(
	t: ^testing.T,
	stmt: ast.Statement,
	name: string,
	loc := #caller_location,
) {
	testing.expectf(
		t,
		ast.token_literal(stmt) == "let",
		"token_literal(stmt) not 'let'. got=%s",
		ast.token_literal(stmt),
		loc = loc,
	)
	let_stmt := stmt.(^ast.LetStatement)

	testing.expectf(
		t,
		let_stmt.name.value == name,
		"let_stmt.name.value not '%s'. got=%s",
		name,
		let_stmt.name.value,
		loc = loc,
	)
}

@(private)
check_parser_error :: proc(t: ^testing.T, using parser: ^parser.Parser, loc := #caller_location) {
	if len(errors) == 0 {
		return
	}

	builder := strings.builder_make()
	fmt.sbprintfln(&builder, "parser has %d errors", len(errors))

	for msg in errors {
		fmt.sbprintfln(&builder, "parser error: %s", msg)
	}

	testing.fail_now(t, strings.to_string(builder), loc = loc)
}

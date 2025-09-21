package parser_tests

import "../../src/ast"
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

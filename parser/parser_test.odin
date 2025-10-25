#+private
package parser

import "../ast"
import "core:fmt"
import "core:testing"

test_let_statement :: proc(
	t: ^testing.T,
	s: ast.Statement,
	name: string,
	loc := #caller_location,
) {
	tok_lit := ast.token_literal(s)
	testing.expect_value(t, tok_lit, "let", loc = loc)

	let_stmt, stmt_ok := s.(^ast.Let_Statement)

	testing.expect_value(t, let_stmt.name.value, name, loc = loc)

	tok_lit = ast.token_literal(let_stmt.name)
	testing.expect_value(t, tok_lit, name, loc = loc)
}

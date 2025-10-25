#+private
package parser

import "../ast"
import "core:fmt"
import "core:log"
import "core:strings"
import "core:testing"

check_parser_errors :: proc(t: ^testing.T, p: ^Parser, loc := #caller_location) {
	if len(p.errors) == 0 {
		return
	}
	sb := strings.builder_make(context.temp_allocator)
	fmt.sbprintfln(&sb, "parser had %d errors", len(p.errors))
	for msg in p.errors {
		fmt.sbprintfln(&sb, "parser error: %q", msg)
	}
	testing.fail_now(t, strings.to_string(sb), loc = loc)
}
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

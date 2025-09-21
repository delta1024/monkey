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

@(private)
test_integer_literal :: proc(
	t: ^testing.T,
	int_lit: ast.Expression,
	value: i64,
	loc := #caller_location,
) {
	integer := int_lit.(^ast.IntegerLiteral)

	testing.expectf(
		t,
		integer.value == value,
		"integer.vaule not %d. got=%d",
		value,
		integer.value,
		loc = loc,
	)

	buf: [256]byte

	num_str := fmt.bprintf(buf[:], "%d", value)

	testing.expectf(
		t,
		ast.token_literal(integer) == num_str,
		"token_literal(integer) not %d. got=%s",
		value,
		ast.token_literal(integer),
	)


}

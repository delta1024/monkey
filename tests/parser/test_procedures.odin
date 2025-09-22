package parser_tests

import "../../src/ast"
import "../../src/ast/parser"
import "base:builtin"
import "core:fmt"
import "core:strings"
import "core:testing"
@(private)
test_let_statement :: proc(
	t: ^testing.T,
	var_name: string,
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
	let_stmt, ok := stmt.(^ast.LetStatement)
	if !ok {
		fail_expected_statement(t, var_name, "ast.LetStatement", stmt, loc = loc)
	}
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
	var_name: string,
	int_lit: ast.Expression,
	value: i64,
	loc := #caller_location,
) {
	integer, ok := int_lit.(^ast.IntegerLiteral)
	if !ok {
		fail_expected_expression(t, var_name, "ast.IntegerLiteral", int_lit, loc = loc)
	}

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

@(private)
LiteralVaule :: union {
	string,
	bool,
	i64,
}
@(private)
test_literal_expression :: proc(
	t: ^testing.T,
	var_name: string,
	lit: ast.Expression,
	value: LiteralVaule,
	loc := #caller_location,
) {
	switch v in value {
	case i64:
		test_integer_literal(t, var_name, lit, v, loc = loc)
	case string:
		test_identifier(t, var_name, lit, v, loc = loc)
	case bool:
		test_boolean_literal(t, var_name, lit, v, loc = loc)
	}
}
test_boolean_literal :: proc(
	t: ^testing.T,
	var_name: string,
	bool_lit: ast.Expression,
	value: bool,
	loc := #caller_location,
) {
	boolean, ok := bool_lit.(^ast.Boolean)
	if !ok {
		fail_expected_expression(t, var_name, "ast.Boolean", bool_lit, loc = loc)
	}

	testing.expectf(
		t,
		boolean.value == value,
		"boolean.vaule not %d. got=%d",
		value,
		boolean.value,
		loc = loc,
	)

	buf: [256]byte

	num_str := fmt.bprintf(buf[:], "%v", value)

	testing.expectf(
		t,
		ast.token_literal(boolean) == num_str,
		"token_literal(integer) not %d. got=%s",
		value,
		ast.token_literal(boolean),
	)
}
@(private)
test_infix_expression :: proc(
	t: ^testing.T,
	var_name: string,
	exp: ast.Expression,
	left: $T,
	operator: string,
	right: $U,
	loc := #caller_location,
) {
	op_exp, ok := exp.(^ast.InfixExpression)
	if !ok {
		fail_expected_expression(t, var_name, "ast.InfixExpression", exp, loc = loc)
	}

	test_literal_expression(t, "op_exp.left", op_exp.left, left, loc = loc)

	testing.expectf(
		t,
		op_exp.operator == operator,
		"op_exp.operator is not '%s'. got=%s",
		operator,
		op_exp.operator,
	)

	test_literal_expression(t, "op_exp.right", op_exp.right, right, loc = loc)
}
@(private)
test_identifier :: proc(
	t: ^testing.T,
	var_name: string,
	exp: ast.Expression,
	value: string,
	loc := #caller_location,
) {
	ident, ok := exp.(^ast.Identifier)

	if !ok {
		fail_expected_expression(t, var_name, "ast.Identifier", exp)
	}

	testing.expectf(
		t,
		ident.value == value,
		"ident.value not %s. got=%s",
		value,
		ident.value,
		loc = loc,
	)

	testing.expectf(
		t,
		ast.token_literal(ident) == value,
		"token_literal(ident) not %s. got=%s",
		value,
		ast.token_literal(ident),
		loc = loc,
	)

}
@(private)
fail_expected_expression :: proc(
	t: ^testing.T,
	field_name, expected_name: string,
	value: ast.Expression,
	loc := #caller_location,
) {
	switch expr in value {
	case ^ast.Identifier:
		fail_expected_type(t, field_name, expected_name, expr, loc = loc)
	case ^ast.IntegerLiteral:
		fail_expected_type(t, field_name, expected_name, expr, loc = loc)
	case ^ast.InfixExpression:
		fail_expected_type(t, field_name, expected_name, expr, loc = loc)
	case ^ast.PrefixExpression:
		fail_expected_type(t, field_name, expected_name, expr, loc = loc)
	case ^ast.Boolean:
		fail_expected_type(t, field_name, expected_name, expr, loc = loc)
	case ^ast.IfExpression:
		fail_expected_type(t, field_name, expected_name, expr, loc = loc)
	case ^ast.FunctionLiteral:
		fail_expected_type(t, field_name, expected_name, expr, loc = loc)
	}
}
@(private)
fail_expected_statement :: proc(
	t: ^testing.T,
	field_name, expected_name: string,
	value: ast.Statement,
	loc := #caller_location,
) {
	switch stmt in value {
	case ^ast.LetStatement:
		fail_expected_type(t, field_name, expected_name, stmt, loc = loc)
	case ^ast.ReturnStatement:
		fail_expected_type(t, field_name, expected_name, stmt, loc = loc)
	case ^ast.BlockStatement:
		fail_expected_type(t, field_name, expected_name, stmt, loc = loc)
	case ^ast.ExpressionStatement:
		fail_expected_type(t, field_name, expected_name, stmt, loc = loc)
	}
}
@(private)
fail_expected_type :: proc(
	t: ^testing.T,
	field_name, expected_name: string,
	value: any,
	loc := #caller_location,
) {
	testing.expectf(t, false, "%s not ^%s. got=%T", field_name, expected_name, value, loc = loc)
}

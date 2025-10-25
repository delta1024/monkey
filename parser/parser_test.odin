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

	let_stmt :=
		s.(^ast.Let_Statement) or_else testing.fail_now(
			t,
			fmt.tprintf("stmt not ^ast.Let_Statement. got=%s", stmt_varient_name(s)),
			loc = loc,
		)

	testing.expect_value(t, let_stmt.name.value, name, loc = loc)

	tok_lit = ast.token_literal(let_stmt.name)
	testing.expect_value(t, tok_lit, name, loc = loc)
}

test_integer_literal :: proc(
	t: ^testing.T,
	il: ast.Expression,
	value: i64,
	loc := #caller_location,
	value_expr := #caller_expression(value),
) {
	integ :=
		il.(^ast.Integer_Literal) or_else testing.fail_now(
			t,
			fmt.tprintf("exp not ^ast.Integer_Literal. got=%s", expr_varient_name(il)),
			loc = loc,
		)

	testing.expect_value(t, integ.value, value, loc = loc, value_expr = value_expr)
	testing.expect_value(t, ast.token_literal(integ), fmt.tprintf("%d", value))
}

test_identifier :: proc(
	t: ^testing.T,
	exp: ast.Expression,
	value: string,
	loc := #caller_location,
	exp_expression := #caller_expression(exp),
) {
	ident :=
		exp.(^ast.Identifier) or_else testing.fail_now(
			t,
			fmt.tprintf("exp not ^ast.Identifier. got=%s", expr_varient_name(exp)),
			loc = loc,
		)

	testing.expect_value(t, ident.value, value, loc = loc, value_expr = exp_expression)
	testing.expect_value(t, ast.node_string(ident), value, loc = loc)
}

test_boolean_literal :: proc(
	t: ^testing.T,
	exp: ast.Expression,
	value: bool,
	loc := #caller_location,
	exp_expression := #caller_expression(exp),
) {

	bl :=
		exp.(^ast.Boolean_Literal) or_else testing.fail_now(
			t,
			fmt.tprintf("exp not ^ast.Boolean_Literal. got=%s", expr_varient_name(exp)),
			loc = loc,
		)

	testing.expect_value(t, bl.value, value, loc = loc, value_expr = exp_expression)
	testing.expect_value(t, ast.node_string(bl), value ? "true" : "false", loc = loc)
}
test_infix_expression :: proc(
	t: ^testing.T,
	exp: ast.Expression,
	left: Expected_Value,
	operator: string,
	right: Expected_Value,
	loc := #caller_location,
	exp_expr := #caller_expression(exp),
) {

	exp :=
		exp.(^ast.Infix_Expression) or_else testing.fail_now(
			t,
			fmt.tprint("expected ^ast.InfixExpression. got=%s", expr_varient_name(exp)),
			loc = loc,
		)


	test_literal_expression(t, exp.left, left, loc = loc, exp_expression = exp_expr)

	testing.expect_value(t, exp.operator, operator, loc = loc)

	test_literal_expression(t, exp.right, right, loc = loc, exp_expression = exp_expr)
}
Expected_Value :: union {
	i64,
	int,
	string,
	bool,
}
test_literal_expression :: proc(
	t: ^testing.T,
	exp: ast.Expression,
	expected: Expected_Value,
	loc := #caller_location,
	exp_expression := #caller_expression(exp),
) {
	switch e in expected {
	case i64:
		test_integer_literal(t, exp, e, loc = loc, value_expr = exp_expression)
	case int:
		test_integer_literal(t, exp, i64(e), loc = loc, value_expr = exp_expression)
	case string:
		test_identifier(t, exp, e, loc = loc, exp_expression = exp_expression)
	case bool:
		test_boolean_literal(t, exp, e, loc = loc, exp_expression = exp_expression)
	}
}

stmt_varient_name :: proc(stmt: ast.Statement) -> string {
	switch s in stmt {
	case ^ast.Let_Statement:
		return fmt.tprintf("%T", s)
	case ^ast.Return_Statement:
		return fmt.tprintf("%T", s)
	case ^ast.Block_Statement:
		return fmt.tprintf("%T", s)
	case ^ast.Expression_Statement:
		return fmt.tprintf("%T", s)
	case:
		return "nil"

	}
}
expr_varient_name :: proc(expr: ast.Expression) -> string {
	switch e in expr {
	case ^ast.Identifier:
		return fmt.tprintf("%T", e)
	case ^ast.Integer_Literal:
		return fmt.tprintf("%T", e)
	case ^ast.Infix_Expression:
		return fmt.tprintf("%T", e)
	case ^ast.If_Expression:
		return fmt.tprintf("%T", e)
	case ^ast.Prefix_Expression:
		return fmt.tprintf("%T", e)
	case ^ast.Boolean_Literal:
		return fmt.tprintf("%T", e)
	case ^ast.Function_Literal:
		return fmt.tprintf("%T", e)
	case ^ast.Call_Expression:
		return fmt.tprintf("%T", e)
	case:
		return "nil"
	}
}

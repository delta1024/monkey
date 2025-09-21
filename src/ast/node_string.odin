package ast

import "core:fmt"
import "core:strings"

program_node_string :: proc(using program: ^Program) -> string {
	out := strings.builder_make()

	for stmt in statements {
		stmt_string := node_string(stmt)
		defer delete(stmt_string)
		strings.write_string(&out, stmt_string)
	}

	return strings.to_string(out)
}

statement_node_string :: proc(stmt: Statement) -> (out: string) {
	switch node in stmt {
	case ^LetStatement:
		out = node_string(node)
	case ^ReturnStatement:
		out = node_string(node)
	case ^BlockStatement:
		out = node_string(node)
	case ^ExpressionStatement:
		out = node_string(node)
	case:
		out = string(make_slice([]byte, 1))
	}
	return
}

block_statement_node_string :: proc(using block_node: ^BlockStatement) -> string {
	out := strings.builder_make()

	for s in statements {
		stmt_str := node_string(s)
		defer delete(stmt_str)
		strings.write_string(&out, stmt_str)
	}
	return strings.to_string(out)
}

let_node_string :: proc(using let_stmt: ^LetStatement) -> string {
	out := strings.builder_make()
	name_str := node_string(name)
	defer delete(name_str)
	fmt.sbprintf(&out, "%s %s = ", node.token.literal, name_str)

	if value != nil {
		value_str := node_string(value)
		defer delete(value_str)
		strings.write_string(&out, value_str)
	}
	strings.write_rune(&out, ';')
	return strings.to_string(out)
}
return_node_string :: proc(using ret_stmt: ^ReturnStatement) -> string {
	out := strings.builder_make()

	fmt.sbprintf(&out, "%s ", node.token.literal)

	if return_value != nil {
		ret_str := node_string(return_value)
		defer delete(ret_str)
		strings.write_string(&out, ret_str)
	}
	strings.write_rune(&out, ';')
	return strings.to_string(out)
}

expression_statement_node_string :: proc(using expr_stmn: ^ExpressionStatement) -> string {
	if expression != nil {
		return node_string(expression)
	} else {
		return string(make([]byte, 1))
	}
}

expression_node_string :: proc(expr: Expression) -> (out: string) {
	switch node in expr {
	case ^PrefixExpression:
		out = node_string(node)
	case ^InfixExpression:
		out = node_string(node)
	case ^IfExpression:
		out = node_string(node)
	case ^Identifier:
		out = node_string(node)
	case ^IntegerLiteral:
		out = node_string(node)
	case ^Boolean:
		out = node_string(node)
	case:
		out = string(make_slice([]byte, 1))
	}
	return
}

prefix_expression_node_string :: proc(using prefix_node: ^PrefixExpression) -> string {
	out := strings.builder_make()

	strings.write_byte(&out, '(')
	strings.write_string(&out, operator)

	right_string := node_string(right)
	defer delete(right_string)

	strings.write_string(&out, right_string)

	strings.write_byte(&out, ')')

	return strings.to_string(out)
}

infix_expression_node_string :: proc(using infix_expr: ^InfixExpression) -> string {
	out := strings.builder_make()

	left_str := node_string(left)
	defer delete(left_str)
	right_str := node_string(right)
	defer delete(right_str)

	fmt.sbprintf(&out, "(%s %s %s)", left_str, operator, right_str)

	return strings.to_string(out)
}

if_expression_node_string :: proc(using if_node: ^IfExpression) -> string {
	out := strings.builder_make()

	cond_str := node_string(condition)
	defer delete(cond_str)
	conseq_str := node_string(consequence)
	defer delete(conseq_str)

	fmt.sbprintf(&out, "if%s %s", cond_str, conseq_str)

	if alternative != nil {
		alt_str := node_string(alternative)
		defer delete(alt_str)
		fmt.sbprintf(&out, "else %s", alt_str)
	}
	return strings.to_string(out)
}

identifier_node_string :: proc(using ident_expr: ^Identifier) -> string {
	return strings.clone(value)
}

integer_literal_node_string :: proc(using integer_expr: ^IntegerLiteral) -> string {
	return strings.clone(node.token.literal)
}

boolean_node_string :: proc(using bool_node: ^Boolean) -> string {
	return strings.clone(node.token.literal)
}


node_string :: proc {
	program_node_string,
	statement_node_string,
	block_statement_node_string,
	let_node_string,
	return_node_string,
	expression_statement_node_string,
	expression_node_string,
	prefix_expression_node_string,
	if_expression_node_string,
	infix_expression_node_string,
	identifier_node_string,
	integer_literal_node_string,
	boolean_node_string,
}

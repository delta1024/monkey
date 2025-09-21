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
	case:
		out = string(make_slice([]byte, 1))
	}
	return
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

expression_node_string :: proc(expr: Expression) -> (out: string) {
	switch node in expr {
	case ^Identifier:
		out = node_string(node)
	case:
		out = string(make_slice([]byte, 1))
	}
	return
}

identifier_node_string :: proc(using ident_expr: ^Identifier) -> string {
	return strings.clone(value)
}
node_string :: proc {
	program_node_string,
	statement_node_string,
	let_node_string,
	return_node_string,
	expression_node_string,
	identifier_node_string,
}

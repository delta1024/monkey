package ast

import "core:fmt"
import "core:strings"
program_node_string :: proc(p: ^Program) -> string {
	sb := strings.builder_make(context.temp_allocator)
	for stmt in p.statements {
		fmt.sbprint(&sb, node_string(stmt))
	}
	return strings.to_string(sb)
}

statement_node_string :: proc(s: Statement) -> string {
	switch n in s {
	case ^Let_Statement:
		return node_string(n)
	case ^Return_Statement:
		return node_string(n)
	case ^Expression_Statement:
		return node_string(n)
	case:
		return ""
	}
}

let_statement_node_string :: proc(ls: ^Let_Statement) -> string {
	sb := strings.builder_make(context.temp_allocator)
	fmt.sbprint(
		&sb,
		token_literal(ls),
		node_string(ls.name),
		"=",
		ls.value == nil ? "" : node_string(ls.value),
	)
	fmt.sbprint(&sb, ';')
	return strings.to_string(sb)
}

return_statement_node_string :: proc(rs: ^Return_Statement) -> string {
	sb := strings.builder_make(context.temp_allocator)
	fmt.sbprint(&sb, token_literal(rs), rs.return_value == nil ? "" : node_string(rs.return_value))
	fmt.sbprint(&sb, ';')
	return strings.to_string(sb)
}

expression_statement_node_string :: proc(es: ^Expression_Statement) -> string {
	sb := strings.builder_make(context.temp_allocator)
	fmt.sbprint(&sb, node_string(es.expression))
	return strings.to_string(sb)
}

expression_node_string :: proc(e: Expression) -> string {
	switch n in e {
	case ^Identifier:
		return node_string(n)
	case ^Integer_Literal:
		return node_string(n)
	case:
		return ""
	}
}

identifier_node_string :: proc(i: ^Identifier) -> string {
	return i.value
}
integer_literal_string :: proc(il: ^Integer_Literal) -> string {
	return il.token.literal
}
node_string :: proc {
	program_node_string,
	statement_node_string,
	let_statement_node_string,
	return_statement_node_string,
	expression_statement_node_string,
	expression_node_string,
	identifier_node_string,
	integer_literal_string,
}

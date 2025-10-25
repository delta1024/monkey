package ast

import "../token"
make_base_node :: proc($T: typeid, tok: token.Token) -> ^T {
	n := new(T)
	n.variant = n
	n.token = tok
	return n
}

make_program_node :: proc($T: typeid/Program, statements: []Statement) -> ^T {
	p := new(T)
	p.statements = statements
	return p
}

make_let_statement_node :: proc(
	$T: typeid/Let_Statement,
	tok: token.Token,
	name: ^Identifier = nil,
	value: Expression = nil,
) -> ^T {
	node := make_base_node(T, tok)
	node.name = name
	node.value = value
	return node
}

make_return_statement_node :: proc(
	$T: typeid/Return_Statement,
	t: token.Token,
	return_value: Expression = nil,
) -> ^T {
	node := make_base_node(T, t)
	node.return_value = return_value
	return node
}

make_expression_statement_node :: proc(
	$T: typeid/Expression_Statement,
	tok: token.Token,
	expression: Expression = nil,
) -> ^T {
	node := make_base_node(T, tok)
	node.expression = expression
	return node
}

make_infix_expression_node :: proc(
	$T: typeid/Infix_Expression,
	tok: token.Token,
	left: Expression = nil,
	operator: string = "",
	right: Expression = nil,
) -> ^T {
	node := make_base_node(T, tok)
	node.left = left
	node.operator = operator
	node.right = right
	return node
}

make_prefix_expression_node :: proc(
	$T: typeid/Prefix_Expression,
	tok: token.Token,
	operator: string = "",
	right: Expression = nil,
) -> ^T {
	node := make_base_node(T, tok)
	node.operator = operator
	node.right = right
	return node
}

make_identifier_node :: proc($T: typeid/Identifier, tok: token.Token, value: string = "") -> ^T {
	node := make_base_node(T, tok)
	if value == "" {
		node.value = tok.literal
	} else {
		node.value = value
	}
	return node
}

make_integer_literal_node :: proc(
	$T: typeid/Integer_Literal,
	tok: token.Token,
	value: i64 = 0,
) -> ^T {
	node := make_base_node(T, tok)
	node.value = value
	return node
}
make_node :: proc {
	make_program_node,
	make_let_statement_node,
	make_return_statement_node,
	make_expression_statement_node,
	make_infix_expression_node,
	make_prefix_expression_node,
	make_identifier_node,
	make_integer_literal_node,
}

delete_program_node :: proc(p: ^Program) {
	if p.statements != nil {
		for stmt in p.statements {
			delete_node(stmt)
		}
		delete(p.statements)
	}
	free(p)
}

delete_statement_node :: proc(s: Statement) {
	switch node in s {
	case ^Let_Statement:
		delete_node(node)
	case ^Return_Statement:
		delete_node(node)
	case ^Expression_Statement:
		delete_node(node)
	case:
	}
}

delete_let_statement_node :: proc(ls: ^Let_Statement) {
	delete_node(ls.name)
	if ls.value != nil {

		delete_node(ls.value)
	}
	free(ls)
}

delete_return_statement_node :: proc(rs: ^Return_Statement) {
	if rs.return_value != nil {
		delete_node(rs.return_value)
	}
	free(rs)
}

delete_expression_statement_node :: proc(es: ^Expression_Statement) {
	if es.expression != nil {
		delete_node(es.expression)
	}
	free(es)
}

delete_expression_node :: proc(e: Expression) {
	switch node in e {
	case ^Identifier:
		delete_node(node)
	case ^Integer_Literal:
		delete_node(node)
	case ^Prefix_Expression:
		delete_node(node)
	case ^Infix_Expression:
		delete_node(node)
	case:
	}
}

delete_infix_expression_node :: proc(ie: ^Infix_Expression) {
	delete_node(ie.left)
	delete_node(ie.right)
	free(ie)
}
delete_prefix_expression_node :: proc(pe: ^Prefix_Expression) {
	delete_node(pe.right)
	free(pe)
}
delete_identifier_node :: proc(i: ^Identifier) {
	free(i)
}

delete_integer_literal_node :: proc(il: ^Integer_Literal) {
	free(il)
}
delete_node :: proc {
	delete_program_node,
	delete_statement_node,
	delete_let_statement_node,
	delete_return_statement_node,
	delete_expression_statement_node,
	delete_expression_node,
	delete_infix_expression_node,
	delete_prefix_expression_node,
	delete_identifier_node,
	delete_integer_literal_node,
}

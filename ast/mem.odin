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

make_block_statement_node :: proc(
	$T: typeid/Block_Statement,
	tok: token.Token,
	statements: []Statement = nil,
) -> ^T {
	node := make_base_node(T, tok)
	node.statements = statements
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

make_if_expression_node :: proc(
	$T: typeid/If_Expression,
	tok: token.Token,
	condition: Expression = nil,
	consequence: ^Block_Statement = nil,
	alternative: ^Block_Statement = nil,
) -> ^T {
	node := make_base_node(T, tok)
	node.condition = condition
	node.consequence = consequence
	node.alternative = alternative
	return node
}

make_call_expression_node :: proc(
	$T: typeid/Call_Expression,
	tok: token.Token,
	function: Expression = nil,
	arguments: []Expression = nil,
) -> ^T {
	node := make_base_node(T, tok)
	node.function = function
	node.arguments = arguments
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

make_function_literal_node :: proc(
	$T: typeid/Function_Literal,
	tok: token.Token,
	parameters: []^Identifier = nil,
	body: ^Block_Statement = nil,
) -> ^T {
	node := make_base_node(T, tok)
	node.parameters = parameters
	node.body = body
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
make_boolean_literal_node :: proc(
	$T: typeid/Boolean_Literal,
	tok: token.Token,
	value: bool = false,
) -> ^T {
	node := make_base_node(T, tok)
	node.value = value
	return node
}
make_node :: proc {
	make_program_node,
	make_let_statement_node,
	make_return_statement_node,
	make_block_statement_node,
	make_expression_statement_node,
	make_infix_expression_node,
	make_prefix_expression_node,
	make_if_expression_node,
	make_call_expression_node,
	make_identifier_node,
	make_function_literal_node,
	make_integer_literal_node,
	make_boolean_literal_node,
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
	case ^Block_Statement:
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

delete_block_statement_node :: proc(bs: ^Block_Statement) {
	for stmt in bs.statements {
		delete_node(stmt)
	}
	delete(bs.statements)
	free(bs)
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
	case ^Boolean_Literal:
		delete_node(node)
	case ^If_Expression:
		delete_node(node)
	case ^Function_Literal:
		delete_node(node)
	case ^Call_Expression:
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
delete_if_expression_node :: proc(ie: ^If_Expression) {
	if ie.alternative != nil {
		delete_node(ie.alternative)
	}
	delete_node(ie.condition)
	delete_node(ie.consequence)
	free(ie)
}
delete_call_expression_node :: proc(ce: ^Call_Expression) {
	for expr in ce.arguments {
		delete_node(expr)
	}
	delete(ce.arguments)
	delete_node(ce.function)
	free(ce)
}
delete_identifier_node :: proc(i: ^Identifier) {
	free(i)
}

delete_function_literal_node :: proc(fl: ^Function_Literal) {
	for ident in fl.parameters {
		delete_node(ident)
	}
	delete(fl.parameters)
	delete_node(fl.body)
	free(fl)
}

delete_integer_literal_node :: proc(il: ^Integer_Literal) {
	free(il)
}
delete_boolean_literal_node :: proc(bl: ^Boolean_Literal) {
	free(bl)
}
delete_node :: proc {
	delete_program_node,
	delete_statement_node,
	delete_let_statement_node,
	delete_return_statement_node,
	delete_block_statement_node,
	delete_expression_statement_node,
	delete_expression_node,
	delete_infix_expression_node,
	delete_prefix_expression_node,
	delete_call_expression_node,
	delete_if_expression_node,
	delete_identifier_node,
	delete_function_literal_node,
	delete_integer_literal_node,
	delete_boolean_literal_node,
}

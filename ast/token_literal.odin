package ast

token_literal_base_node :: proc(n: ^Node) -> string {
	return n.token.literal
}

token_literal_statement_node :: proc(s: Statement) -> string {
	node: ^Node
	switch n in s {
	case ^Let_Statement:
		node = n
	case ^Return_Statement:
		node = n
	case:
		return ""
	}
	return token_literal(node)
}

token_literal_expression_node :: proc(e: Expression) -> string {
	node: ^Node
	switch n in e {
	case ^Identifier:
		node = n
	case:
		return ""
	}
	return token_literal(node)
}

token_literal_program :: proc(p: ^Program) -> string {
	if len(p.statements) > 0 {
		return token_literal(p.statements[0])
	} else {
		return ""
	}
}
token_literal :: proc {
	token_literal_base_node,
	token_literal_statement_node,
	token_literal_expression_node,
	token_literal_program,
}

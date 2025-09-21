package ast

program_token_literal :: proc(prog: ^Program) -> string {
	if len(prog.statements) > 0 {
		return token_literal(prog.statements[0])
	} else {
		return ""
	}
}

node_token_literal :: proc(node: ^Node) -> string {
	return node.token.literal
}

statement_token_literal :: proc(stmt: Statement) -> string {
	node: ^Node
	switch n in stmt {
	case ^LetStatement:
		node = n
	case ^ReturnStatement:
		node = n
	case ^ExpressionStatement:
		node = n
	}
	return token_literal(node)
}

expression_token_literal :: proc(expr: Expression) -> string {
	node: ^Node
	switch n in expr {
	case ^Identifier:
		node = n
	}
	return token_literal(node)
}

token_literal :: proc {
	program_token_literal,
	node_token_literal,
	statement_token_literal,
	expression_token_literal,
}

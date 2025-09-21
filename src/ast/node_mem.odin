package ast
import "../tokenizer"

program_node_make :: proc($T: typeid/Program) -> ^T {
	program := new(T)
	program.statements = make([dynamic]Statement)
	return program
}

base_node_make :: proc($T: typeid, token: tokenizer.Token) -> ^T {
	node := new(T)
	node.base_node = node
	node.token = token
	return node
}

let_node_make :: proc(
	$T: typeid/LetStatement,
	token: tokenizer.Token,
	name: ^Identifier = nil,
	value: Expression = nil,
) -> ^T {
	node := base_node_make(T, token)
	node.name = name
	node.value = value
	return node
}

return_node_make :: proc(
	$T: typeid/ReturnStatement,
	token: tokenizer.Token,
	return_value: Expression = nil,
) -> ^T {
	node := base_node_make(T, token)
	node.return_value = return_value
	return node
}

identifier_node_make :: proc($T: typeid/Identifier, token: tokenizer.Token) -> ^T {
	node := base_node_make(T, token)
	node.value = token.literal
	return node
}

node_make :: proc {
	program_node_make,
	let_node_make,
	return_node_make,
	identifier_node_make,
}

program_node_delete :: proc(program: ^Program) {
	for node in program.statements {
		node_delete(node)
	}
	delete(program.statements)
	free(program)
}

statement_node_delete :: proc(stmt: Statement) {
	switch node in stmt {
	case ^LetStatement:
		node_delete(node)
	case ^ReturnStatement:
		node_delete(node)
	}
}

let_node_delete :: proc(node: ^LetStatement) {
	node_delete(node.name)
	node_delete(node.value)
	free(node)
}

return_node_delete :: proc(node: ^ReturnStatement) {
	node_delete(node.return_value)
	free(node)
}

expression_node_delete :: proc(expr: Expression) {
	switch node in expr {
	case ^Identifier:
		node_delete(node)
	}
}

identifier_node_delete :: proc(node: ^Identifier) {
	free(node)
}

node_delete :: proc {
	program_node_delete,
	statement_node_delete,
	let_node_delete,
	return_node_delete,
	expression_node_delete,
	identifier_node_delete,
}

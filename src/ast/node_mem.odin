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

block_statement_node_make :: proc(
	$T: typeid/BlockStatement,
	token: tokenizer.Token,
	statements: [dynamic]Statement = nil,
) -> ^T {
	node := base_node_make(T, token)
	if statements == nil {
		node.statements = make([dynamic]Statement)
	} else {
		node.statements = statements
	}
	return node
}

expression_statement_node_make :: proc(
	$T: typeid/ExpressionStatement,
	token: tokenizer.Token,
	expression: Expression = nil,
) -> ^T {
	node := base_node_make(T, token)
	node.expression = expression
	return node
}

prefix_expression_node_make :: proc(
	$T: typeid/PrefixExpression,
	token: tokenizer.Token,
	right: Expression = nil,
) -> ^T {
	node := base_node_make(T, token)
	node.operator = token.literal
	node.right = right
	return node
}

infix_expression_node_make :: proc(
	$T: typeid/InfixExpression,
	token: tokenizer.Token,
	left: Expression = nil,
	right: Expression = nil,
) -> ^T {
	node := base_node_make(T, token)
	node.operator = token.literal
	node.left = left
	node.right = right
	return node
}

if_expression_node_make :: proc(
	$T: typeid/IfExpression,
	token: tokenizer.Token,
	condition: Expression = nil,
	consequence: ^BlockStatement = nil,
	alternative: ^BlockStatement = nil,
) -> ^T {
	node := base_node_make(T, token)
	node.condition = condition
	node.consequence = consequence
	node.alternative = alternative
	return node
}

identifier_node_make :: proc($T: typeid/Identifier, token: tokenizer.Token) -> ^T {
	node := base_node_make(T, token)
	node.value = token.literal
	return node
}

function_literal_node_make :: proc(
	$T: typeid/FunctionLiteral,
	token: tokenizer.Token,
	parameters: []^Identifier = nil,
	body: ^BlockStatement = nil,
) -> ^T {
	node := base_node_make(T, token)
	node.parameters = parameters
	node.body = body
	return node
}

integer_literal_node_make :: proc(
	$T: typeid/IntegerLiteral,
	token: tokenizer.Token,
	value: i64 = 0,
) -> ^T {
	node := base_node_make(T, token)
	node.value = value
	return node
}

boolean_node_make :: proc($T: typeid/Boolean, token: tokenizer.Token, value: bool) -> ^T {
	node := base_node_make(T, token)
	node.value = value
	return node
}
node_make :: proc {
	program_node_make,
	let_node_make,
	return_node_make,
	block_statement_node_make,
	expression_statement_node_make,
	prefix_expression_node_make,
	infix_expression_node_make,
	if_expression_node_make,
	identifier_node_make,
	function_literal_node_make,
	integer_literal_node_make,
	boolean_node_make,
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
	case ^BlockStatement:
		node_delete(node)
	case ^ExpressionStatement:
		node_delete(node)
	}
}

let_node_delete :: proc(node: ^LetStatement) {
	node_delete(node.name)
	if node.value != nil {
		node_delete(node.value)
	}
	free(node)
}

return_node_delete :: proc(node: ^ReturnStatement) {
	node_delete(node.return_value)
	free(node)
}

block_statement_node_delete :: proc(node: ^BlockStatement) {
	for stmt in node.statements {
		node_delete(stmt)
	}
	delete(node.statements)
	free(node)
}

expression_statement_node_delete :: proc(node: ^ExpressionStatement) {
	node_delete(node.expression)
	free(node)
}

expression_node_delete :: proc(expr: Expression) {
	switch node in expr {
	case ^PrefixExpression:
		node_delete(node)
	case ^InfixExpression:
		node_delete(node)
	case ^IfExpression:
		node_delete(node)
	case ^Identifier:
		node_delete(node)
	case ^FunctionLiteral:
		node_delete(node)
	case ^IntegerLiteral:
		node_delete(node)
	case ^Boolean:
		node_delete(node)
	}
}

prefix_expression_node_delete :: proc(using prefix_node: ^PrefixExpression) {
	node_delete(right)
	free(prefix_node)
}
infix_expression_node_delete :: proc(using infix_node: ^InfixExpression) {
	node_delete(left)
	node_delete(right)
	free(infix_node)
}
if_expression_node_delete :: proc(using if_node: ^IfExpression) {
	node_delete(condition)
	node_delete(consequence)
	if alternative != nil {
		node_delete(alternative)
	}
	free(if_node)
}
identifier_node_delete :: proc(node: ^Identifier) {
	free(node)
}

function_literal_node_delete :: proc(node: ^FunctionLiteral) {
	for ident in node.parameters {
		node_delete(ident)
	}
	delete(node.parameters)
	node_delete(node.body)
	free(node)
}

integer_literal_node_delete :: proc(node: ^IntegerLiteral) {
	free(node)
}

boolean_node_delete :: proc(node: ^Boolean) {
	free(node)
}
node_delete :: proc {
	program_node_delete,
	statement_node_delete,
	let_node_delete,
	return_node_delete,
	block_statement_node_delete,
	expression_statement_node_delete,
	expression_node_delete,
	prefix_expression_node_delete,
	infix_expression_node_delete,
	if_expression_node_delete,
	identifier_node_delete,
	function_literal_node_delete,
	integer_literal_node_delete,
	boolean_node_delete,
}

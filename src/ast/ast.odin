package ast
import "../tokenizer"

Node :: struct {
	token:     tokenizer.Token,
	base_node: union {
		^LetStatement,
		^ReturnStatement,
		^BlockStatement,
		^ExpressionStatement,
		^PrefixExpression,
		^InfixExpression,
		^IfExpression,
		^CallExpression,
		^Identifier,
		^FunctionLiteral,
		^IntegerLiteral,
		^Boolean,
	},
}

Program :: struct {
	statements: [dynamic]Statement,
}

Statement :: union {
	^LetStatement,
	^ReturnStatement,
	^BlockStatement,
	^ExpressionStatement,
}

LetStatement :: struct {
	using node: Node,
	name:       ^Identifier,
	value:      Expression,
}

ReturnStatement :: struct {
	using node:   Node,
	return_value: Expression,
}

BlockStatement :: struct {
	using node: Node,
	statements: [dynamic]Statement,
}

ExpressionStatement :: struct {
	using node: Node,
	expression: Expression,
}

Expression :: union {
	^PrefixExpression,
	^InfixExpression,
	^IfExpression,
	^CallExpression,
	^Identifier,
	^FunctionLiteral,
	^IntegerLiteral,
	^Boolean,
}

PrefixExpression :: struct {
	using node: Node,
	operator:   string,
	right:      Expression,
}

InfixExpression :: struct {
	using node: Node,
	left:       Expression,
	operator:   string,
	right:      Expression,
}

IfExpression :: struct {
	using node:  Node,
	condition:   Expression,
	consequence: ^BlockStatement,
	alternative: ^BlockStatement "optional value",
}

CallExpression :: struct {
	using node: Node,
	function:   Expression,
	arguments:  []Expression,
}

Identifier :: struct {
	using node: Node,
	value:      string,
}

FunctionLiteral :: struct {
	using node: Node,
	parameters: []^Identifier,
	body:       ^BlockStatement,
}

IntegerLiteral :: struct {
	using node: Node,
	value:      i64,
}

Boolean :: struct {
	using node: Node,
	value:      bool,
}

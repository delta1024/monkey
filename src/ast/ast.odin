package ast
import "../tokenizer"

Node :: struct {
	token:     tokenizer.Token,
	base_node: union {
		^LetStatement,
		^ReturnStatement,
		^ExpressionStatement,
		^PrefixExpression,
		^InfixExpression,
		^Identifier,
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
	^ExpressionStatement,
}

LetStatement :: struct {
	using node: Node,
	name:       ^Identifier,
	value:      Expression "optional value",
}

ReturnStatement :: struct {
	using node:   Node,
	return_value: Expression,
}

ExpressionStatement :: struct {
	using node: Node,
	expression: Expression,
}

Expression :: union {
	^PrefixExpression,
	^InfixExpression,
	^Identifier,
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

Identifier :: struct {
	using node: Node,
	value:      string,
}

IntegerLiteral :: struct {
	using node: Node,
	value:      i64,
}

Boolean :: struct {
	using node: Node,
	value:      bool,
}

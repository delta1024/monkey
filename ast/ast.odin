package ast

import "../token"

Node :: struct {
	token:   token.Token,
	variant: union {
		^Let_Statement,
		^Return_Statement,
		^Expression_Statement,
		^Infix_Expression,
		^Prefix_Expression,
		^Identifier,
		^Integer_Literal,
		^Boolean_Literal,
	},
}

Program :: struct {
	statements: []Statement,
}

Statement :: union {
	^Let_Statement,
	^Return_Statement,
	^Expression_Statement,
}

Let_Statement :: struct {
	using node: Node,
	name:       ^Identifier,
	value:      Expression,
}

Return_Statement :: struct {
	using node:   Node,
	return_value: Expression,
}

Expression_Statement :: struct {
	using node: Node,
	expression: Expression,
}

Expression :: union {
	^Infix_Expression,
	^Prefix_Expression,
	^Identifier,
	^Integer_Literal,
	^Boolean_Literal,
}

Prefix_Expression :: struct {
	using node: Node,
	operator:   string,
	right:      Expression,
}

Infix_Expression :: struct {
	using node: Node,
	left:       Expression,
	operator:   string,
	right:      Expression,
}

Identifier :: struct {
	using node: Node,
	value:      string,
}

Integer_Literal :: struct {
	using node: Node,
	value:      i64,
}

Boolean_Literal :: struct {
	using node: Node,
	value:      bool,
}

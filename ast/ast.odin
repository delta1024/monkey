package ast

import "../token"

Node :: struct {
	token:   token.Token,
	variant: union {
		^Let_Statement,
		^Return_Statement,
		^Expression_Statement,
		^Identifier,
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
	^Identifier,
}

Identifier :: struct {
	using node: Node,
	value:      string,
}

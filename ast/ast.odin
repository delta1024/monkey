package ast

import "../token"

Node :: struct {
	token:   token.Token,
	variant: union {
		^Let_Statement,
		^Identifier,
	},
}

Program :: struct {
	statements: []Statement,
}

Statement :: union {
	^Let_Statement,
}

Let_Statement :: struct {
	using node: Node,
	name:       ^Identifier,
	value:      Expression,
}

Expression :: union {
	^Identifier,
}

Identifier :: struct {
	using node: Node,
	value:      string,
}

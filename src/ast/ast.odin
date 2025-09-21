package ast
import "../tokenizer"

Node :: struct {
	token:     tokenizer.Token,
	base_node: union {
		^LetStatement,
		^ReturnStatement,
		^Identifier,
	},
}

Program :: struct {
	statements: [dynamic]Statement,
}

Statement :: union {
	^LetStatement,
	^ReturnStatement,
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

Expression :: union {
	^Identifier,
}

Identifier :: struct {
	using node: Node,
	value:      string,
}

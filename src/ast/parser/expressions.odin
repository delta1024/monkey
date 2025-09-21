#+private
package parser

import "../../ast"
Precedence :: enum int {
	Lowest       = 0,
	Equals       = 1,
	Less_Greater = 2,
	Sum          = 3,
	Product      = 4,
	Prefix       = 5,
	Call         = 6,
}

parse_expression :: proc(using parser: ^Parser, precedence: Precedence) -> ast.Expression {
	prefix, ok := prefix_parse_fns[cur_token.type]

	if !ok {
		return nil
	}

	left_exp := prefix(parser)
	return left_exp
}

parse_identifier :: proc(using parser: ^Parser) -> ast.Expression {
	return ast.node_make(ast.Identifier, cur_token)
}

#+private
package parser

import "../ast"

Precedence :: enum u8 {
	Lowest,
	Equals, // ==
	Less_Greater, // > or <
	Sum, // +
	Product, // *
	Prefix, // -X or !X
	Call, // myFunction(X)
}
parse_expression :: proc(p: ^Parser, prec: Precedence) -> ast.Expression {
	prefix, ok := p.prefix_parse_fns[p.cur_token.type]
	if !ok {
		return nil
	}
	left_exp := prefix(p)

	return left_exp
}

parse_identifier :: proc(p: ^Parser) -> ast.Expression {
	return ast.make_node(ast.Identifier, p.cur_token, p.cur_token.literal)
}

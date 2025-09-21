#+private
package parser

import "../../ast"
import "core:fmt"
import "core:strconv"
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
		no_prefix_parse_fn(parser, cur_token.type)
		return nil
	}

	left_exp := prefix(parser)
	return left_exp
}

parse_identifier :: proc(using parser: ^Parser) -> ast.Expression {
	return ast.node_make(ast.Identifier, cur_token)
}

parse_integer_literal :: proc(using parser: ^Parser) -> ast.Expression {
	lit := ast.node_make(ast.IntegerLiteral, cur_token)

	value, ok := strconv.parse_i64(cur_token.literal)

	if !ok {
		ast.node_delete(lit)
		msg := fmt.aprintfln("could not parse %s as integer", cur_token.literal)
		append(&errors, msg)
		return nil
	}

	lit.value = value

	return lit
}

parse_prefix_expression :: proc(using parser: ^Parser) -> ast.Expression {
	expression := ast.node_make(ast.PrefixExpression, cur_token)

	next_token(parser)

	expression.right = parse_expression(parser, .Prefix)
	return expression
}

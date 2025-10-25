#+private
package parser

import "../ast"
import "core:fmt"
import "core:strconv"

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
		no_prefix_parse_fn_error(p, p.cur_token.type)
		return nil
	}
	left_exp := prefix(p)

	for !peek_token_is(p, .Semi_Colon) && prec < peek_precedence(p) {
		infix, infix_ok := p.infix_parse_fns[p.peek_token.type]

		if !infix_ok {
			return left_exp
		}

		next_token(p)

		left_exp = infix(p, left_exp)
	}

	return left_exp
}

parse_identifier :: proc(p: ^Parser) -> ast.Expression {
	return ast.make_node(ast.Identifier, p.cur_token, p.cur_token.literal)
}

parse_integer_literal :: proc(p: ^Parser) -> ast.Expression {
	lit_tok := p.cur_token
	value, ok := strconv.parse_i64(p.cur_token.literal)
	if !ok {
		msg := fmt.aprintf("could not parse %q as integer", p.cur_token.literal)
		append(&p.errors, msg)
		return nil
	}
	return ast.make_node(ast.Integer_Literal, lit_tok, value)
}

parse_prefix_expression :: proc(p: ^Parser) -> ast.Expression {
	expr_tok := p.cur_token

	next_token(p)

	expr_right := parse_expression(p, .Prefix)

	return ast.make_node(ast.Prefix_Expression, expr_tok, expr_tok.literal, expr_right)
}

parse_infix_expression :: proc(p: ^Parser, left: ast.Expression) -> ast.Expression {
	expr_tok := p.cur_token

	precedence := cur_precedence(p)
	next_token(p)
	expr_right := parse_expression(p, precedence)

	return ast.make_node(ast.Infix_Expression, expr_tok, left, expr_tok.literal, expr_right)
}

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
parse_boolean_literal :: proc(p: ^Parser) -> ast.Expression {
	return ast.make_node(ast.Boolean_Literal, p.cur_token, cur_token_is(p, .True))
}

parse_grouped_expressions :: proc(p: ^Parser) -> ast.Expression {
	next_token(p)

	exp := parse_expression(p, .Lowest)

	if !expect_peek(p, .R_Paren) {
		ast.delete_node(exp)
		return nil
	}
	return exp
}

parse_if_expression :: proc(p: ^Parser) -> (expression: ast.Expression) {
	if_tok := p.cur_token

	if !expect_peek(p, .L_Paren) {
		return nil
	}

	next_token(p)

	condition := parse_expression(p, .Lowest)
	defer if expression == nil {
		ast.delete_node(condition)
	}

	if !expect_peek(p, .R_Paren) {
		return nil
	}

	if !expect_peek(p, .L_Brace) {
		return nil
	}

	consequence := parse_block_statement(p)

	alternative: ^ast.Block_Statement
	if peek_token_is(p, .Else) {
		next_token(p)
		if !expect_peek(p, .L_Brace) {
			return nil
		}

		alternative = parse_block_statement(p)
	}

	return ast.make_node(ast.If_Expression, if_tok, condition, consequence, alternative)

}

parse_function_literal :: proc(p: ^Parser) -> (lit: ast.Expression) {
	lit_tok := p.cur_token
	if !expect_peek(p, .L_Paren) {
		return nil
	}
	paramaters := parse_function_paramaters(p)
	defer if lit == nil {
		for i in paramaters {
			ast.delete_node(i)
		}
		delete(paramaters)
	}
	if !expect_peek(p, .L_Brace) {
		return nil
	}

	body := parse_block_statement(p)
	return ast.make_node(ast.Function_Literal, lit_tok, paramaters, body)
}

parse_function_paramaters :: proc(p: ^Parser) -> (params: []^ast.Identifier) {
	identifiers := make([dynamic]^ast.Identifier)
	defer if params == nil {
		for i in identifiers {
			ast.delete_node(i)
		}
		delete(identifiers)
	}
	if peek_token_is(p, .R_Paren) {
		next_token(p)
		return identifiers[:]
	}

	next_token(p)

	ident := ast.make_node(ast.Identifier, p.cur_token, p.cur_token.literal)
	append(&identifiers, ident)
	for peek_token_is(p, .Comma) {
		next_token(p)
		next_token(p)
		ident := ast.make_node(ast.Identifier, p.cur_token, p.cur_token.literal)
		append(&identifiers, ident)
	}
	if !expect_peek(p, .R_Paren) {
		return nil
	}
	return identifiers[:]
}

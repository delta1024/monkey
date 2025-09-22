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
	for !peek_token_is(parser, .Semicolon) && precedence < peek_precedence(parser) {
		infix, ok := infix_parse_fns[peek_token.type]
		if !ok {
			return left_exp
		}

		next_token(parser)

		left_exp = infix(parser, left_exp)
	}
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

parse_infix_expression :: proc(using parser: ^Parser, left: ast.Expression) -> ast.Expression {
	expression := ast.node_make(ast.InfixExpression, cur_token, left)

	prec := cur_precedence(parser)
	next_token(parser)
	expression.right = parse_expression(parser, prec)
	return expression
}

parse_boolean_expression :: proc(using parser: ^Parser) -> ast.Expression {
	return ast.node_make(ast.Boolean, cur_token, cur_token_is(parser, .True))
}

parse_grouped_expression :: proc(using parser: ^Parser) -> ast.Expression {
	next_token(parser)

	exp := parse_expression(parser, .Lowest)

	if !expect_peek(parser, .RParen) {
		ast.node_delete(exp)
		return nil
	}

	return exp
}

parse_if_expression :: proc(using parser: ^Parser) -> (node: ast.Expression) {
	expression := ast.node_make(ast.IfExpression, cur_token)
	defer if node == nil {
		free(expression)
	}

	if !expect_peek(parser, .LParen) {
		return
	}

	next_token(parser)

	expression.condition = parse_expression(parser, .Lowest)
	defer if node == nil {
		ast.node_delete(expression.condition)
	}

	if !expect_peek(parser, .RParen) {
		return nil
	}

	if !expect_peek(parser, .LBrace) {
		return nil
	}

	expression.consequence = parse_block_statement(parser)
	defer if node == nil {
		ast.node_delete(expression.consequence)
	}

	if peek_token_is(parser, .Else) {
		next_token(parser)

		if !expect_peek(parser, .LBrace) {
			return
		}

		expression.alternative = parse_block_statement(parser)
	}
	return expression
}

parse_function_literal :: proc(using parser: ^Parser) -> (node: ast.Expression) {
	lit := ast.node_make(ast.FunctionLiteral, cur_token)
	defer if node == nil {
		free(lit)
	}

	if !expect_peek(parser, .LParen) {
		return
	}

	lit.parameters = parse_function_parameters(parser)
	defer if node == nil {
		for ident in lit.parameters {
			ast.node_delete(ident)
		}
		delete(lit.parameters)
	}

	if !expect_peek(parser, .LBrace) {
		return
	}

	lit.body = parse_block_statement(parser)

	return lit
}

parse_function_parameters :: proc(using parser: ^Parser) -> (params: []^ast.Identifier = nil) {
	identifiers := make([dynamic]^ast.Identifier)
	defer if params == nil {
		for i in identifiers {
			ast.node_delete(i)
		}
		delete(identifiers)
	}
	if peek_token_is(parser, .RParen) {
		next_token(parser)
		return identifiers[:]
	}

	next_token(parser)

	ident := ast.node_make(ast.Identifier, cur_token)
	append(&identifiers, ident)

	for peek_token_is(parser, .Comma) {
		next_token(parser)
		next_token(parser)
		ident = ast.node_make(ast.Identifier, cur_token)
		append(&identifiers, ident)
	}

	if !expect_peek(parser, .RParen) {
		return
	}

	return identifiers[:]
}

parse_call_expression :: proc(using parser: ^Parser, function: ast.Expression) -> ast.Expression {
	exp := ast.node_make(ast.CallExpression, cur_token, function)
	exp.arguments = parse_call_arguments(parser)
	return exp
}

parse_call_arguments :: proc(using parser: ^Parser) -> (ret_args: []ast.Expression = nil) {
	args := make([dynamic]ast.Expression)
	defer if ret_args == nil {
		for a in args {
			ast.node_delete(a)
		}
		delete(args)
	}

	if peek_token_is(parser, .RParen) {
		next_token(parser)
		return args[:]
	}

	next_token(parser)
	append(&args, parse_expression(parser, .Lowest))

	for peek_token_is(parser, .Comma) {
		next_token(parser)
		next_token(parser)
		append(&args, parse_expression(parser, .Lowest))
	}

	if !expect_peek(parser, .RParen) {
		return
	}
	return args[:]
}

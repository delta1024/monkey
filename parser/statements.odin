#+private
package parser
import "../ast"

parse_statement :: proc(p: ^Parser) -> ast.Statement {
	#partial switch p.cur_token.type {
	case .Let:
		return parse_let_statement(p)
	case .Return:
		return parse_return_statement(p)
	case:
		return parse_expression_statement(p)
	}
}

parse_expression_statement :: proc(p: ^Parser) -> ^ast.Expression_Statement {
	stmt_token := p.cur_token

	stmt_expression := parse_expression(p, .Lowest)

	if peek_token_is(p, .Semi_Colon) {
		next_token(p)
	}
	return ast.make_node(ast.Expression_Statement, stmt_token, stmt_expression)
}
parse_let_statement :: proc(p: ^Parser) -> (stmt: ^ast.Let_Statement) {
	let_tok := p.cur_token
	if !expect_peek(p, .Ident) {
		return nil
	}

	stmt_name := ast.make_node(ast.Identifier, p.cur_token)
	defer if stmt == nil {
		ast.delete_node(stmt_name)
	}

	if !expect_peek(p, .Assign) {
		return nil
	}

	next_token(p)

	stmt_value := parse_expression(p, .Lowest)

	if peek_token_is(p, .Semi_Colon) {
		next_token(p)
	}

	return ast.make_node(ast.Let_Statement, let_tok, stmt_name, stmt_value)
}

parse_return_statement :: proc(p: ^Parser) -> ^ast.Return_Statement {
	ret_token := p.cur_token
	next_token(p)

	ret_val := parse_expression(p, .Lowest)

	if peek_token_is(p, .Semi_Colon) {
		next_token(p)
	}
	return ast.make_node(ast.Return_Statement, ret_token, ret_val)
}
parse_block_statement :: proc(p: ^Parser) -> ^ast.Block_Statement {

	block_tok := p.cur_token
	stmts := make([dynamic]ast.Statement)

	next_token(p)

	for !cur_token_is(p, .R_Brace) && !cur_token_is(p, .Eof) {
		stmt := parse_statement(p)
		if stmt != nil {
			append(&stmts, stmt)
		}
		next_token(p)
	}
	return ast.make_node(ast.Block_Statement, block_tok, stmts[:])

}

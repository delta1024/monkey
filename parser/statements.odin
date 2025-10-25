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
		return nil
	}
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

	// TODO: We're skipping the expressions until we
	// encounter a semicolon
	for !cur_token_is(p, .Semi_Colon) {
		next_token(p)
	}
	return ast.make_node(ast.Let_Statement, let_tok, stmt_name)
}

parse_return_statement :: proc(p: ^Parser) -> ^ast.Return_Statement {
	ret_token := p.cur_token
	next_token(p)

	// TODO: We're skipping the expressions until we
	// encounter a semicolon
	for !cur_token_is(p, .Semi_Colon) {
		next_token(p)
	}
	return ast.make_node(ast.Return_Statement, ret_token)
}

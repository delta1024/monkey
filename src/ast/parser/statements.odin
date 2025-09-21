#+private
package parser
import "../../ast"

parse_statement :: proc(using parser: ^Parser) -> (stmt: ast.Statement) {
	#partial switch cur_token.type {
	case .Let:
		stmt = parse_let_statement(parser)
	}
	return
}

parse_let_statement :: proc(using parser: ^Parser) -> ^ast.LetStatement {
	using ast
	stmt := node_make(ast.LetStatement, cur_token)
	if !expect_peek(parser, .Ident) {
		node_delete(stmt)
		return nil
	}

	stmt.name = node_make(ast.Identifier, cur_token)

	if !expect_peek(parser, .Assign) {
		node_delete(stmt)
		return nil
	}

	// TODO: We're skipping the expressions until we
	// encounter a semicolon
	for !cur_token_is(parser, .Semicolon) {
		next_token(parser)
	}

	return stmt
}

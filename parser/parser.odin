package parser
import "../ast"
import "../lexer"
import "../token"

Parser :: struct {
	l:          lexer.Lexer,
	cur_token:  token.Token,
	peek_token: token.Token,
}

new_parser :: proc(l: lexer.Lexer) -> Parser {
	p: Parser
	p.l = l
	next_token(&p)
	next_token(&p)
	return p
}

parse_program :: proc(p: ^Parser) -> ^ast.Program {
	statements := make([dynamic]ast.Statement)

	for p.cur_token.type != .Eof {
		stmt := parse_statement(p)
		if stmt != nil {
			append(&statements, stmt)
		}
		next_token(p)
	}

	return ast.make_node(ast.Program, statements[:])
}

@(private)
next_token :: proc(p: ^Parser) {
	p.cur_token = p.peek_token
	p.peek_token = lexer.next_token(&p.l)
}
@(private)
cur_token_is :: proc(p: ^Parser, t: token.Token_Type) -> bool {
	return p.cur_token.type == t
}
@(private)
peek_token_is :: proc(p: ^Parser, t: token.Token_Type) -> bool {
	return p.peek_token.type == t
}
@(private)
expect_peek :: proc(p: ^Parser, t: token.Token_Type) -> bool {
	if peek_token_is(p, t) {
		next_token(p)
		return true
	} else {
		return false
	}
}

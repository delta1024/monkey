package parser

import "../../ast"
import "../../tokenizer"

Parser :: struct {
	lexer:                 tokenizer.Tokenizer,
	cur_token, peek_token: tokenizer.Token,
}

parser_create :: proc(lexer: tokenizer.Tokenizer) -> Parser {
	parser := Parser {
		lexer = lexer,
	}

	next_token(&parser)
	next_token(&parser)
	return parser
}

parser_destroy :: proc(using parser: Parser) {}
parse_program :: proc(using parser: ^Parser) -> ^ast.Program {
	program := ast.node_make(ast.Program)

	for cur_token.type != .Eof {
		stmt := parse_statement(parser)
		if stmt != nil {
			append(&program.statements, stmt)
		}
		next_token(parser)
	}

	return program
}

@(private)
next_token :: proc(using parser: ^Parser) {
	cur_token = peek_token
	peek_token = tokenizer.tokenizer_next(&lexer)
}

@(private)
cur_token_is :: proc(using parser: ^Parser, t: tokenizer.TokenType) -> bool {
	return cur_token.type == t
}

@(private)
peek_token_is :: proc(using parser: ^Parser, t: tokenizer.TokenType) -> bool {
	return peek_token.type == t
}

@(private)
expect_peek :: proc(using parser: ^Parser, t: tokenizer.TokenType) -> bool {
	if peek_token_is(parser, t) {
		next_token(parser)
		return true
	} else {
		return false
	}
}

#+feature dynamic-literals
package parser

import "../../ast"
import "../../tokenizer"
import "core:fmt"

Prefix_Parse_Fn :: #type proc(_: ^Parser) -> ast.Expression
Infix_Parse_Fn :: #type proc(_: ^Parser, _: ast.Expression) -> ast.Expression
Parser :: struct {
	lexer:                 tokenizer.Tokenizer,
	cur_token, peek_token: tokenizer.Token,
	errors:                [dynamic]string,
	prefix_parse_fns:      map[tokenizer.TokenType]Prefix_Parse_Fn,
	infix_parse_fns:       map[tokenizer.TokenType]Infix_Parse_Fn,
	precedences:           map[tokenizer.TokenType]Precedence,
}

parser_create :: proc(lexer: tokenizer.Tokenizer) -> Parser {
	parser := Parser {
		lexer = lexer,
		errors = make([dynamic]string),
		prefix_parse_fns = map[tokenizer.TokenType]Prefix_Parse_Fn {
			.Ident = parse_identifier,
			.Int = parse_integer_literal,
			.Bang = parse_prefix_expression,
			.Minus = parse_prefix_expression,
			.True = parse_boolean_expression,
			.False = parse_boolean_expression,
			.LParen = parse_grouped_expression,
			.If = parse_if_expression,
			.Function = parse_function_literal,
		},
		infix_parse_fns = map[tokenizer.TokenType]Infix_Parse_Fn {
			.Plus = parse_infix_expression,
			.Minus = parse_infix_expression,
			.Slash = parse_infix_expression,
			.Asterisk = parse_infix_expression,
			.Eq = parse_infix_expression,
			.Not_Eq = parse_infix_expression,
			.Lt = parse_infix_expression,
			.Gt = parse_infix_expression,
			.LParen = parse_call_expression,
		},
		precedences = map[tokenizer.TokenType]Precedence {
			.Eq = .Equals,
			.Not_Eq = .Equals,
			.Lt = .Less_Greater,
			.Gt = .Less_Greater,
			.Plus = .Sum,
			.Minus = .Sum,
			.Slash = .Product,
			.Asterisk = .Product,
			.LParen = .Call,
		},
	}

	next_token(&parser)
	next_token(&parser)
	return parser
}

parser_destroy :: proc(using parser: Parser) {
	for err in errors {
		delete(err)
	}
	delete(errors)
	delete(infix_parse_fns)
	delete(prefix_parse_fns)
	delete(precedences)
}

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
		peek_error(parser, t)
		return false
	}
}

@(private)
peek_error :: proc(using parser: ^Parser, t: tokenizer.TokenType) {
	msg := fmt.aprintfln(
		"expected next token to be %s, got %s instead",
		tokenizer.token_names[t],
		tokenizer.token_names[peek_token.type],
	)
	append(&errors, msg)
}

@(private)
no_prefix_parse_fn :: proc(using parser: ^Parser, token: tokenizer.TokenType) {
	msg := fmt.aprintfln("no prefix function for %s found", tokenizer.token_names[token])
	append(&errors, msg)
}
@(private)
peek_precedence :: proc(using parser: ^Parser) -> Precedence {
	if p, ok := precedences[peek_token.type]; ok {
		return p
	} else {
		return .Lowest
	}
}
@(private)
cur_precedence :: proc(using parser: ^Parser) -> Precedence {
	if p, ok := precedences[cur_token.type]; ok {
		return p
	} else {
		return .Lowest
	}
}

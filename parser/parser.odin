#+feature dynamic-literals
package parser
import "../ast"
import "../lexer"
import "../token"
import "core:fmt"

Prefix_Parse_Fn :: #type proc(_: ^Parser) -> ast.Expression
Infix_Parse_Fn :: #type proc(_: ^Parser, _: ast.Expression) -> ast.Expression
Parser :: struct {
	l:                lexer.Lexer,
	cur_token:        token.Token,
	peek_token:       token.Token,
	errors:           [dynamic]string,
	prefix_parse_fns: map[token.Token_Type]Prefix_Parse_Fn,
	infix_parse_fns:  map[token.Token_Type]Infix_Parse_Fn,
	precedences:      map[token.Token_Type]Precedence,
}

new_parser :: proc(l: lexer.Lexer) -> Parser {
	p: Parser = {
		l = l,
		errors = make([dynamic]string),
		prefix_parse_fns = map[token.Token_Type]Prefix_Parse_Fn {
			.Ident = parse_identifier,
			.Int = parse_integer_literal,
			.Bang = parse_prefix_expression,
			.Minus = parse_prefix_expression,
			.True = parse_boolean_literal,
			.False = parse_boolean_literal,
			.L_Paren = parse_grouped_expressions,
			.If = parse_if_expression,
		},
		infix_parse_fns = map[token.Token_Type]Infix_Parse_Fn {
			.Plus = parse_infix_expression,
			.Minus = parse_infix_expression,
			.Slash = parse_infix_expression,
			.Asterisk = parse_infix_expression,
			.Eq = parse_infix_expression,
			.Not_Eq = parse_infix_expression,
			.Lt = parse_infix_expression,
			.Gt = parse_infix_expression,
		},
		precedences = map[token.Token_Type]Precedence {
			.Eq = .Equals,
			.Not_Eq = .Equals,
			.Lt = .Less_Greater,
			.Gt = .Less_Greater,
			.Plus = .Sum,
			.Minus = .Sum,
			.Slash = .Product,
			.Asterisk = .Product,
		},
	}
	next_token(&p)
	next_token(&p)
	return p
}
parser_free_errors :: proc(p: ^Parser) {
	for err in p.errors {
		delete(err)
	}
	delete(p.infix_parse_fns)
	delete(p.prefix_parse_fns)
	delete(p.precedences)
	delete(p.errors)
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
		peek_error(p, t)
		return false
	}
}
@(private)
peek_error :: proc(p: ^Parser, t: token.Token_Type) {
	msg := fmt.aprintf(
		"expected next token to be %s, got %s instead",
		token.token_strings[t],
		token.token_strings[p.peek_token.type],
	)
	append(&p.errors, msg)
}
@(private)
no_prefix_parse_fn_error :: proc(p: ^Parser, t: token.Token_Type) {
	msg := fmt.aprintf("no prefix parse function for %s found", token.token_strings[t])
	append(&p.errors, msg)
}
@(private)
peek_precedence :: proc(p: ^Parser) -> Precedence {
	prec := p.precedences[p.peek_token.type] or_else .Lowest
	return prec
}

@(private)
cur_precedence :: proc(p: ^Parser) -> Precedence {
	prec := p.precedences[p.cur_token.type] or_else .Lowest
	return prec
}

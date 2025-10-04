package token

import "core:fmt"
Token_Type :: enum {
	Illegal,
	Eof,
	Ident,
	Int,
	Assign,
	Plus,
	Minus,
	Bang,
	Asterisk,
	Slash,
	Lt,
	Gt,
	Comma,
	Semi_Colon,
	L_Paren,
	R_Paren,
	L_Brace,
	R_Brace,
	Function,
	Let,
}

token_strings := [Token_Type]string {
	.Illegal    = "ILLEGAL",
	.Eof        = "EOF",
	.Ident      = "IDENT",
	.Int        = "INT",
	.Assign     = "=",
	.Plus       = "+",
	.Minus      = "-",
	.Bang       = "!",
	.Asterisk   = "*",
	.Slash      = "/",
	.Lt         = "<",
	.Gt         = ">",
	.Comma      = ",",
	.Semi_Colon = ";",
	.L_Paren    = "(",
	.R_Paren    = ")",
	.L_Brace    = "{",
	.R_Brace    = "}",
	.Function   = "FUNCTION",
	.Let        = "LET",
}

Token :: struct {
	type:    Token_Type,
	literal: string,
}

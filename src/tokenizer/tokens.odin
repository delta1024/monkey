package tokenizer

import "core:fmt"

TokenType :: enum u8 {
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
	Semicolon,
	LParen,
	RParen,
	LBrace,
	RBrace,
	Function,
	Let,
	True,
	False,
	If,
	Else,
	Return,
}

token_names := [TokenType]string {
	.Illegal   = "ILLEGAL",
	.Eof       = "EOF",
	.Ident     = "IDENT",
	.Int       = "INT",
	.Assign    = "=",
	.Plus      = "+",
	.Minus     = "-",
	.Bang      = "!",
	.Asterisk  = "*",
	.Slash     = "/",
	.Lt        = "<",
	.Gt        = ">",
	.Comma     = ",",
	.Semicolon = ";",
	.LParen    = "(",
	.RParen    = ")",
	.LBrace    = "{",
	.RBrace    = "}",
	.Function  = "FUNCTION",
	.Let       = "LET",
	.True      = "TRUE",
	.False     = "FALSE",
	.If        = "IF",
	.Else      = "ELSE",
	.Return    = "RETURN",
}

Token :: struct {
	type:    TokenType,
	literal: string,
}

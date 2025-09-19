package tokenizer

import "core:fmt"

TokenType :: enum u8 {
	Illegal,
	Eof,
	Ident,
	Int,
	Assign,
	Plus,
	Comma,
	Semicolon,
	LParen,
	RParen,
	LBrace,
	RBrace,
	Function,
	Let,
}

token_names := [TokenType]string {
	.Illegal   = "ILLEGAL",
	.Eof       = "EOF",
	.Ident     = "IDENT",
	.Int       = "INT",
	.Assign    = "=",
	.Plus      = "+",
	.Comma     = ",",
	.Semicolon = ";",
	.LParen    = "(",
	.RParen    = ")",
	.LBrace    = "{",
	.RBrace    = "}",
	.Function  = "FUNCTION",
	.Let       = "LET",
}

Token :: struct {
	type:    TokenType,
	literal: string,
}

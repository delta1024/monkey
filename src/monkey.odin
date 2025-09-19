package main

import "core:fmt"
import "core:os"
import "tokenizer"

main :: proc() {
	buf: [256]byte
	using tokenizer

	name := os.get_env_buf(buf[:], "USER")

	fmt.printfln("Hello %s! This is the Monkey programing language!", name)
	fmt.println("Feel free to type in commands")
	for {
		fmt.print(">> ")

		n, err := os.read(os.stdin, buf[:])
		if err != nil {
			fmt.eprintln("Error reading: ", err)
			return
		}
		if n == 0 {
			return
		}
		str := string(buf[:n])

		lexer: Tokenizer
		tokenizer_init(&lexer, str)

		for token := tokenizer_next(&lexer); token.type != .Eof; token = tokenizer_next(&lexer) {
			fmt.println("{ ", token.type, ", ", token.literal, " }")
		}

	}
}

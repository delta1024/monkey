package main

import "core:fmt"
import "core:os"
import "lexer"

main :: proc() {
	using lexer
	buf: [256]byte

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

		lexer := init_lexer(str)

		for tok := next_token(&lexer); tok.type != .Eof; tok = next_token(&lexer) {
			fmt.println(tok)
		}
	}
}

package main

import "ast"
import "core:fmt"
import "core:os"
import "lexer"
import "parser"

main :: proc() {
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

		l := lexer.init_lexer(str)
		p := parser.new_parser(l)
		defer parser.parser_free_errors(&p)

		program := parser.parse_program(&p)
		defer ast.delete_node(program)

		if len(p.errors) != 0 {
			print_parser_errors(p.errors[:])
			continue
		}
		program_str := ast.node_string(program)
		defer free_all(context.temp_allocator)
		fmt.println(program_str)
	}
}

print_parser_errors :: proc(errors: []string) {
	for msg in errors {
		fmt.printfln("\t%s", msg)
	}
}

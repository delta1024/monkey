#+private
package ast

import "../token"
import "core:testing"
@(test)
test_ast_string :: proc(t: ^testing.T) {
	val := Identifier {
		token = token.Token{.Ident, "anotherVar"},
		value = "anotherVar",
	}
	ls := Let_Statement {
		token = {.Let, "let"},
		name  = &Identifier{token = token.Token{.Ident, "someVar"}, value = "someVar"},
		value = &val,
	}
	prog := &Program{statements = []Statement{&ls}}

	testing.expect_value(t, node_string(prog), "let someVar = anotherVar;")
}

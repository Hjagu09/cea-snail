import parser
import lexer
import cpp
import from "./ast_pass/"
import type_pass
import pass_man
import types

let prog = """
'a' + 'b' * (1 + 1) + 'a'
"""
let debug = get_line("debug (Y/*): ") == "Y"
if debug:
	print(prog)
	print("----------")

let lexer = lex.lexer{prog}

if debug: // kör lexern en extra gång och printa alla tokens
	while not lexer.eof():
		let next = lexer.next()
		if next:
			print("{lex.token_type_string(next.type)}: {string(next)} at {lexer.pos}")
		else:
			print("NIL")
	let next = lexer.next()
	if next:
		print("{lex.token_type_string(next.type)}: {string(next)} at {lexer.pos}")
	else:
		print("NIL")
	lexer.reset()

let parser = par.parser{lexer}
let root = parser.parse()
if root != nil and debug:
	print("----------")
	print(root.str())

if root == nil:
	set_exit_code(1)
	return from program

let analyser = pass_man{[
	type_pass{}
]}
let analyser_result = analyser.run_passes(root, debug)
if not all(analyser_result):
	set_exit_code(1)
	return from program
if root != nil and debug:
	print("----------")
	print(root.str())

let cgen = codegen.to_cpp{root}
let cpp_code = cgen.generate().get_code()
print("```\n{cpp_code}\n```")
write_file("a.out.cpp", cpp_code)

import parser
import lexer
import cpp
import from "./ast_pass/"
import type_pass
import pass_man
import ret_pass
import pre_procces
import types

var prog = read_file(command_line_arguments()[0])
guard prog:
	print("input file does not exist")
prog = pre.pre_procces(prog)

let debug = command_line_arguments()[2] == "-"
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
	type_pass(),
	ret_pass{}
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
if debug:
	print("```\n{cpp_code}\n```")
if write_file(command_line_arguments()[1], cpp_code, 0, 1):
	if debug:
		print("c++ code writen to {command_line_arguments()[1]}")
else:
	print("could not write output to {command_line_arguments()[1]}")
	print("compilation faild")
	set_exit_code(3)

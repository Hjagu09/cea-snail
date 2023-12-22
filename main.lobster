import parser
import lexer
import cpp
import from "./ast_pass/"
import type_pass
import pass_man
import types

let prog = read_file("main.unocc")
guard prog:
	print("create main.unocc")

let cmd_raw = command_line_arguments()
var cmd: string = ""
let args = []
if cmd_raw.length == 1:
	cmd = cmd_raw[0]
	for(cmd) arg:
		if arg == '-':
			args.push(true)
		elif arg == '_':
			args.push(false)
		else:
			print("invalid arg string")
			return from program

let debug = args[0]
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
write_file("a.out.cpp", cpp_code)

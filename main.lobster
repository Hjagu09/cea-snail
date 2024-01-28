import parser
import lexer
import cpp
import from "./ast_pass/"
import type_pass
import pass_man
import ret_pass
import pre_procces
import types
import io

var prog = read_file(command_line_arguments()[0])
guard prog:
	log("input file does not exist", OTHER_LOG)
program_raw = prog
prog = pre.pre_procces(prog)
size_diff = length(prog) - length(program_raw)

let debug = command_line_arguments()[2][0] == '-'
if debug:
	debug_log |= OTHER_LOG
if command_line_arguments()[2][1] == '-':
	debug_log |= LEXER_LOG
if command_line_arguments()[2][2] == '-':
	debug_log |= PARSER_LOG 
if command_line_arguments()[2][3] == '-':
	debug_log |= CODE_PASS_LOG
if command_line_arguments()[2][4] == '-':
	debug_log |= CODEGEN_LOG

if debug_log & ~INTERNAL_ERROR != 0:
	print("")

log(prog, OTHER_LOG)
log("----------", OTHER_LOG)

let lexer = lex.lexer{prog}

if debug_log & LEXER_LOG != 0: // kör lexern en extra gång och loga alla tokens
	while not lexer.eof():
		let next = lexer.next()
		if next:
			log("{lex.token_type_string(next.type)}: {string(next)} at {lexer.pos}", LEXER_LOG)
		else:
			log("NIL", LEXER_LOG)
	let next = lexer.next()
	if next:
		log("{lex.token_type_string(next.type)}: {string(next)} at {lexer.pos}", LEXER_LOG)
	else:
		log("NIL", LEXER_LOG)
	lexer.reset()

let parser = par.parser{lexer}
let root = parser.parse()
if root != nil:
	log("----------", PARSER_LOG)
	log(root.str(), PARSER_LOG)

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
if root != nil:
	log("----------", CODE_PASS_LOG)
	log(root.str(), CODE_PASS_LOG)

let cgen = codegen.to_cpp{root}
let cpp_code = cgen.generate().get_code()
log("```\n{cpp_code}\n```", CODEGEN_LOG)
if write_file(command_line_arguments()[1], cpp_code, 0, 1):
	log("c++ code writen to {command_line_arguments()[1]}", OTHER_LOG)
else:
	log("could not write output to {command_line_arguments()[1]}", INTERNAL_ERROR)
	log("compilation faild", OTHER_LOG)
	set_exit_code(3)

import parser
import lexer

let prog = """
3 * (2 + 1)²
"""
let debug = get_line("debug (Y/*): ") == "Y"
if debug:
	print(prog)
	print("----------")

let lexer = lex.lexer{prog}

while not lexer.eof():
	let next = lexer.next()
	if debug:
		if next:
			print("{lex.token_type_string(next.type)}: {string(next)} at {lexer.pos}")
		else:
			print("NIL")
let next = lexer.next()
if debug:
	if next:
		print("{lex.token_type_string(next.type)}: {string(next)} at {lexer.pos}")
	else:
		print("NIL")

lexer.reset()
if not lexer.has_error:
	let parser = par.parser{lexer}
	let root = parser.parse()
	if root != nil and debug:
		print("----------")
		print(root.str())

import lexer

let prog = """
'a' + a * 10|||000
a * b * c × d
'hej * 100_000.464_163_134
"""
print(prog)

print("----------")
let debug = get_line("debug (Y/*): ") == "Y"

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


import lexer

let prog = """
a + 2.35 * b² - 10_000
('a' + 'b') * 2
"""
print(prog)

print("----------")

let lexer = lex.lexer{prog}

while not lexer.eof() and lexer.peek() != nil:
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

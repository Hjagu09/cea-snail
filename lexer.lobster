namespace lex

enum token_types:
	INT_LITERAL,
	FLOAT_LITERAL,
	POWER,
	PLUS,
	MINUS,
	STAR,
	SLASH,
	LPAR,
	RPAR,
	IDENT,
	STRING_LITERAL
	EOF = -1

let pow_2 = string_to_unicode("²")[0]
let pow_3 = string_to_unicode("³")[0]

def token_type_string(type: int) -> string:
	return switch type:
		case INT_LITERAL: "INT_LITERAL"
		case FLOAT_LITERAL: "FLOAT_LITERAL"
		case POWER: "POWER"
		case PLUS: "PLUS"
		case MINUS: "MINUS"
		case STAR: "STAR"
		case SLASH: "SLASH"
		case LPAR: "LPAR"
		case RPAR: "RPAR"
		case IDENT: "IDENT"
		case STRING_LITERAL: "STRING_LITERAL"
		case EOF: "EOF"
		default: "please add {type} to `token_type_string(type: int) -> string`"

class token:
	type: int
	offset: int
	length: int

class string_token : token
	value: string

class int_token : token
	value: int

class float_token : token
	value: float

def is_alpha(char: int):
	return (char >= 'a' and char <= 'z') or (char >= 'A' and char <= 'Z')

def is_num(char: int):
	return (
		char == '0' or
		char == '1' or
		char == '2' or
		char == '3' or
		char == '4' or
		char == '5' or
		char == '6' or
		char == '7' or
		char == '8' or
		char == '9'
	)

def is_alpha_num_under(char: int):
	return is_alpha_num(char) or char == '_'

def is_alpha_num(char: int):
	return is_alpha(char) or is_num(char)

def is_alpha_under(char: int):
	return is_alpha(char) or char == '_'

def is_num_under(char: int):
	return is_num(char) or char == '_'

def at(in, pos: int) -> int:
	if pos < in.length():
		return in[pos]
	else:
		return 0 

class lexer:
	prog_string: string
	prog: [int]? = nil
	pos: int = 0
	has_error: bool = false
	
	def eof() -> bool:
		let peek_token = peek()
		return peek_token != nil and peek_token.type == EOF

	private def gen_next_token(move: bool, offset: int = 0) -> token?:
		if prog == nil:
			prog = string_to_unicode(prog_string)
		assert prog != nil
		
		if pos + offset >= prog.length():
			return token{EOF, pos + offset, 1}
		
		var tok = switch prog.at(pos + offset):
			case '\'', '\"':
				let delim = prog.at(pos + offset)
				let start_i = offset + pos
				offset++
				var name_utf8 = []
				while prog.at(pos + offset) != delim:
					if prog.at(pos + offset) == '\n' or prog.at(pos + offset) == 0:
						if move:
							error(
								"unmatched string opening ({unicode_to_string([delim])})",
								 start_i,
								 name_utf8.length() + 1
							)
							offset += 1
							pos += offset
						return nil
					name_utf8.push(prog.at(pos + offset))
					offset++
				let name = unicode_to_string(name_utf8)
				offset++
				string_token {
					STRING_LITERAL,
					pos + offset - (name_utf8.length() + 2),
					name_utf8.length() + 2,
					name
				}
			case '-':
				offset++
				token {MINUS, pos + offset - 1, 1}
			case '+':
				offset++
				token {PLUS, pos + offset - 1, 1}
			case '*':
				offset++
				token {STAR, pos + offset - 1, 1}
			case '/':
				offset++
				token {SLASH, pos + offset - 1, 1}
			case '(':
				offset++
				token {LPAR, pos + offset - 1, 1}
			case ')':
				offset++
				token {RPAR, pos + offset - 1, 1}
			case pow_2:
				offset++
				int_token {POWER, pos + offset - 1, 1, 2 /* square */}
			case pow_3:
				offset++
				int_token {POWER, pos + offset - 1, 1, 3 /* cube */}
			case ' ', '\t', '\n':
				offset++
				return gen_next_token(move, offset)
			default:
				nil

		if is_alpha_under(prog.at(pos + offset)) and tok == nil:
			var name_utf8 = []
			while is_alpha_num_under(prog.at(pos + offset)):
				name_utf8.push(prog.at(pos + offset))
				offset++
			let name = unicode_to_string(name_utf8)
			tok = string_token {
				IDENT,
				pos + offset - name_utf8.length(),
				name_utf8.length(),
				name
			}
		elif is_num(prog.at(pos + offset)) and tok == nil:
			var number_utf8 = []
			var floating = false
			var len = 0
			while is_num_under(prog.at(pos + offset)) or prog.at(pos + offset) == '.':
				switch prog.at(pos + offset):
					case '.':
						floating = true
						number_utf8.push(prog.at(pos + offset))
					case '_': pass()
					default: number_utf8.push(prog.at(pos + offset))
				offset++
				len++
			let number_string = unicode_to_string(number_utf8)
			if floating:
				let number = string_to_float(number_string)
				tok = float_token {FLOAT_LITERAL, pos + offset - len, len, number}
			else:
				let number = string_to_int(number_string)
				tok = int_token {INT_LITERAL, pos + offset - len, len, number}

		if move:
			if tok == nil:
				let begin = offset + pos
				let new_of, size = skip_errors(offset)
				offset = new_of
				error("unexpected character(s)", begin, size)
			pos += offset
		return tok

	def skip_errors(offset) -> int, int:
		var size = 0
		while gen_next_token(false, offset) == nil:
			offset++
			size++
		return offset, size

	def error(e, at, size):
		has_error = true
		var line_n = 1
		var col = 1
		for(at) i:
			col++
			if prog != nil and prog[i] == '\n':
				line_n++
				col = 1
		let lines = prog_string.tokenize("\n", "")
		let line = lines[line_n - 1]
		print("\nERROR: {e} at {string(line_n)}:{string(col)}")
		print("    {string(line_n)}| {line}")
		let start_buffer = " ".repeat_string(6 + string(line_n).length())
		let at_buffer = " ".repeat_string(col - 1)
		let arrow_line = "-".repeat_string(size - 1)
		print("{start_buffer}{at_buffer}^{arrow_line} here")

	def next() -> token?:
		return gen_next_token(true)

	def peek() -> token?:
		return gen_next_token(false)
	
	def reset():
		prog = nil
		pos = 0

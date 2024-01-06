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
	LF,
	STRING_LITERAL,
	EQUAL_EQUAL,
	NOT_EQUAL,
	LESS_EQUAL,
	GREATER_EQUAL,
	LESS,
	GREATER,
	AND,
	OR,
	NOT,
	TRUE,
	FALSE,
	COMMA,
	EQUAL,
	LET,
	DEF,
	LCURLPAR,
	RCURLPAR,
	COLLON,
	AROW,
	IF,
	ELSE,
	RET,
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
		case LF: "LF"
		case EQUAL_EQUAL: "EQUAL_EQUAL"
		case RET: "RET"
		case NOT_EQUAL: "NOT_EQUAL"
		case LESS_EQUAL: "LESS_EQUAL"
		case GREATER_EQUAL: "GREATER_EQUAL"
		case LESS: "LESS"
		case GREATER: "GREATER"
		case AND: "AND"
		case OR: "OR"
		case NOT: "NOT"
		case TRUE: "TRUE"
		case FALSE: "FALSE"
		case COMMA: "COMMA"
		case LET: "LET"
		case EQUAL: "EQUAL"
		case DEF: "DEF"
		case LCURLPAR: "LCURLPAR"
		case RCURLPAR: "RCURLPAR"
		case COLLON: "COLLON"
		case AROW: "AROW"
		case IF: "IF"
		case ELSE: "ELSE"
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
				let name_utf8 = []
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
				if prog.at(pos + offset) == '>':
					offset++
					token {AROW, pos + offset - 2 , 2}
				else:
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
			case ',':
				offset++
				token {COMMA, pos + offset - 1, 1}
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
			case '=':
				offset++
				if prog.at(pos + offset) == '=':
					offset++
					token {EQUAL_EQUAL, pos + offset - 2, 2}
				else:
					token {EQUAL, pos + offset - 1, 1}
			case '!':
				offset++
				if prog.at(pos + offset) == '=':
					offset++
					token {NOT_EQUAL, pos + offset - 2, 2}
				else:
					nil
			case '<':
				offset++
				if prog.at(pos + offset) == '=':
					offset++
					token {LESS_EQUAL, pos + offset - 2, 2}
				else:
					token {LESS, pos + offset - 1, 1}
			case '>':
				offset++
				if prog.at(pos + offset) == '=':
					offset++
					token {GREATER_EQUAL, pos + offset - 2, 2}
				else:
					token {GREATER, pos + offset - 1, 1}
			case '{':
				offset++
				token {LCURLPAR, pos + offset - 1, 1}
			case '}':
				offset++
				token {RCURLPAR, pos + offset - 1, 1}
			case ':':
				offset++
				token {COLLON, pos + offset - 1, 1}
			case ' ', '\t':
				offset++
				return gen_next_token(move, offset)
			case '\n':
				let start = offset + pos
				while (prog.at(pos + offset) == '\n' or 
					prog.at(pos + offset) == ' ' or
					prog.at(pos + offset) == '\t'):
					offset++
				token {LF, start, 1}
			default:
				nil
		
		// chek if this is an valid identifeier/keyword
		if is_alpha_under(prog.at(pos + offset)) and tok == nil:
			let name_utf8 = []
			while is_alpha_num_under(prog.at(pos + offset)):
				name_utf8.push(prog.at(pos + offset))
				offset++
			let name = unicode_to_string(name_utf8)
			let len = name_utf8.length()
			let start = pos + offset - len
			// match against keywords
			tok = switch name:
				case "and":
					token {AND, start, len}
				case "or":
					token {OR, start, len}
				case "true":
					token {TRUE, start, len}
				case "false":
					token {FALSE, start, len}
				case "not":
					token {NOT, start, len}
				case "let":
					token {LET, start, len}
				case "def":
					token{DEF, start, len}
				case "if":
					token{IF, start, len}
				case "else":
					token{ELSE, start, len}
				case "return":
					token{RET, start, len}
				default:
					// if nothing matched it's a identifeier
					string_token {IDENT, start, len, name}

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

	def error(e: string, at: int, size:int, parser: bool = false) -> void:
		var line_n = 1
		var col = 1
		for(at) i:
			col++
			if prog != nil and prog[i] == '\n':
				line_n++
				col = 1

		var end_line_n = 1
		var end_col = 1
		for(at + size - 1) i:
			end_col++
			if prog != nil and prog[i] == '\n':
				end_line_n++
				end_col = 1

		let lines = prog_string.tokenize("\n", "")

		print("\nERROR: {e} at {string(line_n)}:{string(col)} to {string(end_line_n)}:{string(end_col)}")
		
		if end_line_n == line_n:
			if line_n - 1 < lines.length():
				let line = lines[line_n - 1]
				let error_line = "    {string(line_n)}| {line}"
				print(error_line)
				let start_buffer = " ".repeat_string(6 + string(line_n).length())
				let at_buffer = " ".repeat_string(col - 1)
				let arrow_line = "-".repeat_string(size - 1)
				var arrow = "{start_buffer}{at_buffer}^{arrow_line}"
				print("{arrow} here")
		else:
			for(end_line_n - line_n + 1) l:
				let ln = l + line_n
				if ln - 1 < lines.length():
					let line = lines[ln - 1]
					let error_line = "    {string(ln)}| {line}"
					print(error_line)

		if not parser:
			has_error = true
			pos = at + size
			while not eof():
				next()
			set_exit_code(1)
			return from program // FIXME
		

	def next() -> token?:
		return gen_next_token(true)

	def peek() -> token?:
		return gen_next_token(false)

	// kalla altid på funktionen så här:
	// error = not consume(...) or error
	// inte:
	// error = error or not consume(...)
	def consume(type: int, error: string) -> bool, token?:
		let tok = next()
		if tok != nil and tok.type == type:
			return true, tok
		elif tok != nil:
			if tok.type != LF:
				this.error(error, tok.offset, tok.length, true)
			else:
				this.error(error + " (newline)", tok.offset, tok.length + 1, true)
		else:
			print("\nERROR: {error}")
		return false, tok
	def reset():
		prog = nil
		pos = 0

	def optional(type: int) -> bool:
		let tok = peek()
		if tok != nil and tok.type == type:
			next()
			return false
		else:
			return true
			

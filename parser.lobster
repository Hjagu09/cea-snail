import lexer
import from "./AST/"
import AST
namespace par

class parser:
	lexer: lex.lexer
	has_error: bool = false

	def parse() -> AST_root?:
		let expr = add()
		if expr != nil:
			while true:
				let next = lexer.next()
				if next != nil and next.type == lex.EOF:
					return AST_root{[AST_expr{expr}]}

				elif next != nil and next.type != lex.LF:
					let start = next.offset
					while true:
						let next_ = lexer.next()
						if next_ != nil and (next_.type == lex.EOF):
							let size = next_.offset + next_.length - start - 1
							parse_error("unexpected traling character", start, size)
							return nil
		else:
			return nil

	def add() -> AST_node?:
		let left = term()
		let peek = lexer.peek()
		if peek != nil and peek.type != lex.PLUS and peek.type != lex.MINUS:
			return left
		let op = lexer.next()
		let right = add()
		if left == nil or right == nil or op == nil:
			if op == nil:
				error("bad operator", op)
			return nil
		return switch op.type:
			case lex.PLUS: return AST_add{left, right}
			case lex.MINUS: return AST_sub{left, right}
			default:
				error("bad operator", op)
				nil

	def term() -> AST_node?:
		let left = factor()
		let peek = lexer.peek()
		if peek != nil and peek.type != lex.SLASH and peek.type != lex.STAR:
			return left
		let op = lexer.next()
		let right = term()
		if left == nil or right == nil or op == nil:
			if op == nil:
				error("bad operator", op)
			return nil
		return switch op.type:
			case lex.STAR: return AST_mult{left, right}
			case lex.SLASH: return AST_div{left, right}
			default:
				error("bad operator", op)
				nil

	def factor() -> AST_node?:
		let val = value()
		let next = lexer.peek()
		if next != nil and next.type == lex.POWER and next is lex.int_token and val != nil:
			has_error = lexer.consume(lex.POWER, "bad power") or has_error
			return AST_pow{val, AST_int_literal{next.value}}
		else:
			return val
	
	def value() -> AST_node?:
		let tok = lexer.next()
		if tok != nil:
			if tok.type == lex.INT_LITERAL and tok is lex.int_token:
				return AST_int_literal {tok.value}
			elif tok.type == lex.FLOAT_LITERAL and tok is lex.float_token:
				return AST_float_literal {tok.value}
			elif tok.type == lex.IDENT and tok is lex.string_token:
				return AST_var{tok.value}
			elif tok.type == lex.STRING_LITERAL and tok is lex.string_token:
				return AST_string_literal{tok.value}
			elif tok.type == lex.LPAR:
				let expr = add()
				if expr == nil:
					return nil
				has_error = lexer.consume(lex.RPAR, "unmatched parantese") or has_error
				if expr != nil:
					return AST_group{expr}
		error("bad value", tok)
		return nil

	def error(e, token):
		has_error = true
		if token != nil:
			lexer.error(e, token.offset, token.length, true)
		else:
			print("\nERROR: {e}")
	def parse_error(e, offset, size):
		has_error = true
		lexer.error(e, offset, size, true)

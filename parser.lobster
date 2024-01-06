import lexer
import from "./AST/"
import AST
namespace par

def ret_sig(l: AST_node, r: AST_node) -> AST_node?

class parser:
	lexer: lex.lexer
	has_error: bool = false

	def parse() -> AST_root?:
		var first = true
		let exprs = []
		while true:
			let next = lexer.peek()
			if next != nil and next.type == lex.EOF:
				return AST_root{exprs}

			if not first:
				let err = not lexer.consume(lex.LF, "expected newline after expresion")
				if err:
					has_error = true
					return nil
				let next_2 = lexer.peek()
				if next_2 != nil and next_2.type == lex.EOF:
					return AST_root{exprs}
			first = false
			let expr = top_expr()
			if expr == nil:
				return nil
			else:
				exprs.push(expr)

	def top_expr() -> AST_node?:
		let next = lexer.peek()
		if next == nil:
			return nil
		
		if next.type == lex.LET:
			return asig()
		elif next.type == lex.DEF:
			return func()
		elif next.type == lex.IF or next.type == lex.ELSE:
			return if_else()
		elif next.type == lex.RET:
			return ret()
		else:
			return logic()

	def logic() -> AST_node?:
		let left = comp()

		let op = lexer.peek()
		if op == nil:
			return left

		let ret = fn(ret_func: ret_sig):
			lexer.next()
			let right = comp()
			if left == nil or right == nil:
				return nil
			else:
				return ret_func(left, right)

		switch op.type:
			case lex.AND:
				ret() l, r: AST_and{l, r}
			case lex.OR:
				ret() l, r: AST_or{l, r}
			default:
				return left
	//  ↑
	// skriv ihop dessa med en hjälp funktion
	//  ↓
	def comp() -> AST_node?:
		let left = add()

		let op = lexer.peek()
		if op == nil:
			return left

		let ret = fn(ret_func: ret_sig):
			lexer.next()
			let right = add()
			if left == nil or right == nil:
				return nil from comp
			else:
				return ret_func(left, right) from comp

		switch op.type:
			case lex.GREATER:
				ret() l, r: AST_greater{l, r}
			case lex.LESS:
				ret() l, r: AST_less{l, r}
			case lex.GREATER_EQUAL:
				ret() l, r: AST_greater_equal{l, r}
			case lex.LESS_EQUAL:
				ret() l, r: AST_less_equal{l, r}
			case lex.EQUAL_EQUAL:
				ret() l, r: AST_equal{l, r}
			case lex.NOT_EQUAL:
				ret() l, r: AST_not_equal{l, r}
			default:
				return left

	def add() -> AST_node?: // FIXME skriv om så som comp och logic
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

	def term() -> AST_node?:// FIXME skriv om så som comp och logic
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
			has_error = not lexer.consume(lex.POWER, "bad power") or has_error
			return AST_pow{val, AST_int_literal{next.value}}
		else:
			return val
	
	def value() -> AST_node?:
		let tok = lexer.next()
		var val: AST_node? = nil
		if tok != nil: // FIXME anvönd switch FIXME error: `constructor` (1st argumentet) requiers type `type_struct`
			if tok.type == lex.INT_LITERAL and tok is lex.int_token:
				val = AST_int_literal {tok.value}
			elif tok.type == lex.FLOAT_LITERAL and tok is lex.float_token:
				val = AST_float_literal {tok.value}
			elif tok.type == lex.IDENT and tok is lex.string_token:
				val = AST_var{tok.value}
			elif tok.type == lex.STRING_LITERAL and tok is lex.string_token:
				val = AST_string_literal{tok.value}
			elif tok.type == lex.MINUS:
				let next = value()
				if next != nil:
					val = AST_unary_sub{next}
			elif tok.type == lex.NOT:
				let next = value()
				if next != nil:
					val = AST_not{next}
			elif tok.type == lex.TRUE:
				val = AST_bool_literal{true}
			elif tok.type == lex.FALSE:
				val = AST_bool_literal{false}
			elif tok.type == lex.LPAR:
				let expr = top_expr()
				if expr != nil:
					has_error = not lexer.consume(lex.RPAR, "unmatched parantese") or has_error
					
					if expr != nil:
						val = AST_group{expr}
			else:
				print(tok)
				print(val)
				error("bad value", tok)
		let next = lexer.peek()
		if next != nil and next.type == lex.LPAR: // Function call
			lexer.next() // consume (
			let args = args_list() // list of args
			if args != nil and val != nil:
				has_error = not lexer.consume(lex.RPAR, "unmatched parantese in function call") or has_error
				return AST_call{val, args}
			else:
				return nil
		else:
			return val

	def args_list() -> [AST_node]?:
		var next = lexer.peek()
		if next != nil and next.type != lex.RPAR:
			let args = []
			var arg = top_expr()
			if arg == nil:
				return nil
			args.push(arg)
			next = lexer.peek()
			while next != nil and next.type != lex.RPAR:
				let err = not lexer.consume(lex.COMMA, "expected comma at")
				if err:
					has_error = true
					return nil
				arg = top_expr()
				if arg == nil:
					return nil
				args.push(arg)
				next = lexer.peek()
			return args
		else:
			return []

	def asig() -> AST_node?:
		var err = not lexer.consume(lex.LET, "expected let in variable declaration")
		if err:
			has_error = true
			return nil
		let not_ident_err, ident = lexer.consume(lex.IDENT, "expected identifier")
		if not not_ident_err or ident == nil:
			has_error = true
			return nil
		if not ident is lex.string_token:
			error("expected string token", ident)
			return nil
		err = not lexer.consume(lex.EQUAL, "expected asignment after variable declaration")
		if err:
			has_error = true
			return nil
		let expr = top_expr()
		if expr == nil:
			return nil
		return AST_decl{ident.value, expr}

	def func() -> AST_node?:
		let consume = fn(tok_type, error_str):
			let err, tok = lexer.consume(tok_type, error_str)
			if tok == nil or not err:
				// has_error = true
				return nil from func
			tok

		lexer.consume(lex.DEF, "expected def") // ät "def"
		let name = consume(lex.IDENT, "expected function name") // eat function name
		guard name is lex.string_token:
			print("func name should be string")
			return from program
		consume(lex.LPAR, "expected parantese in function declaration")
		struct arg:
			name: string
			type: type_struct
		let args = []
		var done = false
		let first_arg = lexer.peek()
		if first_arg != nil and first_arg.type == lex.IDENT:
			while not done:
				let arg_name_tok = consume(lex.IDENT, "argument name neaded") // argument name...
				guard arg_name_tok is lex.string_token:
					print("token should be string_token")
					return from program
				let arg_name = arg_name_tok.value
				consume(lex.COLLON, "expected type specifier for function argument")
				let arg_type_tok = consume(lex.IDENT, "argument type neaded")
				guard arg_type_tok is lex.string_token:
					print("token should be string_token")
					return from program
				let arg_type = string_to_type(arg_type_tok.value)            // and argument type
				args.push(arg{arg_name, arg_type})
				let next_tok = lexer.next()
				if next_tok == nil or next_tok.type == lex.RPAR:
					done = true
				elif next_tok.type != lex.COMMA:
					error("expected comma in argument list", next_tok)
		else:
			lexer.consume(lex.RPAR, "expected closing parantese")
		lexer.consume(lex.AROW, "function arrow neaded")
		let func_type_tok = consume(lex.IDENT, "function type neaded")
		guard func_type_tok is lex.string_token:
			print("token should be string_token")
			return from program
		let func_type = string_to_type(func_type_tok.value)
		let func_block = block()
		let arg_types = []
		let arg_names = []
		for(args) v:
			arg_types.push(v.type)
			arg_names.push(v.name)
		return AST_func_decl {
			name.value,
			type_struct(func_type, arg_types),
			arg_names,
			func_block
		}

	def block() -> [AST_node]:
		lexer.optional(lex.LF)
		lexer.consume(lex.LCURLPAR, "expected \'\{\' at begining of block")
		lexer.optional(lex.LF)
		let statments = []
		while true:
			let tok = lexer.peek()
			if tok != nil and tok.type == lex.RCURLPAR:
				lexer.next()
				return statments
			else:
				let statment = top_expr()
				lexer.consume(lex.LF, "expected line fead after statment")
				guard statment != nil:
					return []
				statments.push(statment)

	def if_else() -> AST_node?:
		// IF eller ELSE...
		let keyword = lexer.peek()
		guard keyword and (keyword.type == lex.IF or keyword.type == lex.ELSE):
			// annars är det ett fel
			return nil
		lexer.next() // ät if/else
		
		var condition = nil
		if keyword.type == lex.IF:
			// ät up kravet...
			condition = logic()
			// och se till att det gick vägen
			if condition == nil:
				return nil
		
		// huvuddelen av greningen
		let body = block()

		if keyword.type == lex.IF:
			// detta vet vi
			assert condition
		
			// kolla efter else
			// är nil om det inte fanns
			lexer.optional(lex.LF)
			let next = if_else()
			
			// generara node
			return AST_if {
				body,
				condition,
				next
			}
		else: // if keyword.type == lex.ELSE
			return AST_else { body }
	
	// return statment
	def ret() -> AST_node?:
		// helper for eating tokens
		let consume = fn(tok_type, error_str):
			let err, tok = lexer.consume(tok_type, error_str)
			if tok == nil or not err:
				// has_error = true
				return nil from ret
			tok
		
		// consume "return" keyword
		consume(lex.RET, "expected return keyword in return statment")
		// return value
		let body = top_expr()
		guard body:
			return nil
		// construct node
		return AST_ret{ body }


	def error(e, token):
		has_error = true
		if token != nil:
			if token.type != lex.LF:
				lexer.error(e, token.offset, token.length, true)
			else:
				lexer.error(e + " (newline)", token.offset, token.length + 1, true)
		else:
			print("\nERROR: {e}")
	def parse_error(e, offset, size):
		has_error = true
		lexer.error(e, offset, size, true)

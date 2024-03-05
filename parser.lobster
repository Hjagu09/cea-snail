import io
import lexer
import from "./AST/"
import AST
namespace par

def ret_sig(l: AST_node, r: AST_node) -> AST_node?

struct func_arg:
	name: string
	type: type_struct

class parser:
	lexer: lex.lexer

	def parse() -> AST_root?:
		let exprs = []
		while true:
			let next = lexer.peek()
			if next != nil and next.type == lex.EOF:
				return AST_root{next, exprs}

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
			let right = logic()
			if left == nil or right == nil:
				return nil
			else:
				return ret_func(left, right)

		switch op.type:
			case lex.AND:
				ret() l, r: AST_and{op, l, r}
			case lex.OR:
				ret() l, r: AST_or{op, l, r}
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
			let right = comp()
			if left == nil or right == nil:
				return nil from comp
			else:
				return ret_func(left, right) from comp

		switch op.type:
			case lex.GREATER:
				ret() l, r: AST_greater{op, l, r}
			case lex.LESS:
				ret() l, r: AST_less{op, l, r}
			case lex.GREATER_EQUAL:
				ret() l, r: AST_greater_equal{op, l, r}
			case lex.LESS_EQUAL:
				ret() l, r: AST_less_equal{op, l, r}
			case lex.EQUAL_EQUAL:
				ret() l, r: AST_equal{op, l, r}
			case lex.NOT_EQUAL:
				ret() l, r: AST_not_equal{op, l, r}
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
				error_at_node("bad operator", op)
			return nil
		return switch op.type:
			case lex.PLUS: return AST_add{op, left, right}
			case lex.MINUS: return AST_sub{op, left, right}
			default:
				error_at_node("bad operator", op)
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
				error_at_node("bad operator", op)
			return nil
		return switch op.type:
			case lex.STAR: return AST_mult{op, left, right}
			case lex.SLASH: return AST_div{op, left, right}
			default:
				error_at_node("bad operator", op)
				nil

	def factor() -> AST_node?:
		let val = value()
		let next = lexer.peek()
		if next != nil and next.type == lex.POWER and next is lex.int_token and val != nil:
			lexer.consume(lex.POWER, "bad power")
			return AST_pow{next, val, AST_int_literal{next, next.value}}
		else:
			return val
	
	def value() -> AST_node?:
		let tok = lexer.next()
		var val: AST_node? = nil
		if tok != nil: // FIXME anvönd switch FIXME error: `constructor` (1st argumentet) requiers type `type_struct`
			if tok.type == lex.INT_LITERAL and tok is lex.int_token:
				val = AST_int_literal {tok, tok.value}
			elif tok.type == lex.FLOAT_LITERAL and tok is lex.float_token:
				val = AST_float_literal {tok, tok.value}
			elif tok.type == lex.IDENT and tok is lex.string_token:
				val = AST_var{tok, tok.value}
			elif tok.type == lex.STRING_LITERAL and tok is lex.string_token:
				val = AST_string_literal{tok, tok.value}
			elif tok.type == lex.MINUS:
				let next = value()
				if next != nil:
					val = AST_unary_sub{tok, next}
			elif tok.type == lex.NOT:
				let next = value()
				if next != nil:
					val = AST_not{tok, next}
			elif tok.type == lex.TRUE:
				val = AST_bool_literal{tok, true}
			elif tok.type == lex.FALSE:
				val = AST_bool_literal{tok, false}
			elif tok.type == lex.LPAR:
				let expr = top_expr()
				if expr != nil:
					let _, par_tok = lexer.consume(lex.RPAR, "unmatched parantese")
					guard par_tok
					
					if expr != nil:
						val = AST_group{par_tok, expr}
			elif tok.type == lex.L_SQUARE_PAR:
				let values: [AST_node] = []
				var run = true
				while run:
					let element = top_expr()
					guard element: return nil
					values.push(element)
					lexer.optional(lex.COMMA)
					let next_tok = lexer.peek()
					if next_tok != nil and next_tok.type == lex.R_SQUARE_PAR:
						run = false
						lexer.next()
				return AST_list_literal{ tok, values }
			else:
				log("ERROR", PARSER_LOG)
				log(tok, PARSER_LOG)
				log(val, PARSER_LOG)
				error_at_node("bad value", tok)
		var next = lexer.peek()
		var output_node: AST_node? = val
		while true:
			if next != nil and next.type == lex.LPAR: // Function call
				output_node = func_call(output_node)
			elif next != nil and next.type == lex.EQUAL: // asignment
				let equal_tok = lexer.next() // eat =
				assert equal_tok
				let body = top_expr()
				guard body:
					return nil
				body.str().log(PARSER_LOG)
				if output_node is AST_var:
					output_node = AST_asig {equal_tok, AST_string_literal{ equal_tok,  output_node.name }, body}
				elif output_node is AST_index_op:
					output_node = AST_asig {equal_tok, output_node, body}
				else:
					error_at_node("expected variable or list index for asignment destination", equal_tok)
			elif next != nil and next.type == lex.L_SQUARE_PAR: // indexing operation
				let index = indexing()
				guard output_node: return nil
				guard index: return nil
				guard tok: return nil
				output_node = AST_index_op { tok, output_node, index }
			else:
				return output_node
			next = lexer.peek()

	def indexing() -> AST_node?:
		lexer.consume(lex.L_SQUARE_PAR, "expected parantese in indexing operation")
		let output_node = top_expr()
		lexer.consume(lex.R_SQUARE_PAR, "expected closing bracet (\']\')")
		return output_node
	
	def func_call(func_name) -> AST_node?:
		let open_par_tok = lexer.next() // consume (
		assert open_par_tok
		let args = args_list() // list of args
		if args != nil and func_name != nil:
			let next = lexer.peek()
			if next != nil and next.type == lex.PIPE:
				lexer.next() // eat pipe (aka "|")

				// eat lambda arguments, arrow and return type
				let lambda_args = arg_delc_list()
				let _, arrow_tok = lexer.consume(lex.AROW, "expected lambda return type specifier")
				assert arrow_tok
				let lambda_return_type = type_stmt()

				// separate names and types
				var lambda_args_types = []
				var lambda_args_names = []
				for(lambda_args) arg:
					lambda_args_names.push(arg.name)
					lambda_args_types.push(arg.type)

				// lambda efter funktionen. ska med i "args"
				// ät också )
				lexer.consume(lex.RPAR, "unmatched parantese in function call")
				let body = block()
				let type = type_struct(lambda_return_type, lambda_args_types)
				let lambda_node = AST_lambda {arrow_tok, type, lambda_args_names, body}
				args.push(lambda_node)
			else:
				lexer.consume(lex.RPAR, "unmatched parantese in function call")
			return AST_call{open_par_tok, func_name, args}
		else:
			return nil

	def args_list() -> [AST_node]?:
		var next = lexer.peek()
		if next != nil and next.type != lex.RPAR and next.type != lex.PIPE:
			let args = []
			var arg = top_expr()
			if arg == nil:
				return nil
			args.push(arg)
			next = lexer.peek()
			while next != nil and next.type == lex.COMMA:
				let err = not lexer.consume(lex.COMMA, "expected comma")
				if err:
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
			return nil
		let not_ident_err, ident = lexer.consume(lex.IDENT, "expected identifier")
		if not not_ident_err or ident == nil:
			return nil
		if not ident is lex.string_token:
			error_at_node("expected string token", ident)
			return nil
		err = not lexer.consume(lex.EQUAL, "expected asignment after variable declaration")
		if err:
			return nil
		let expr = top_expr()
		if expr == nil:
			return nil
		return AST_decl{ident, ident.value, expr}

	def arg_delc_list() -> [func_arg]:
		let consume = fn(tok_type, error_str):
			let err, tok = lexer.consume(tok_type, error_str)
			if tok == nil or not err:
				return [] from arg_delc_list
			tok
		let args = []
		var done = false
		let first_arg = lexer.peek()
		if first_arg != nil and first_arg.type == lex.IDENT:
			while not done:
				let arg_name_tok = consume(lex.IDENT, "argument name neaded") // argument name...
				guard arg_name_tok is lex.string_token:
					error("token should be string_token")
					return from program
				let arg_name = arg_name_tok.value
				consume(lex.COLLON, "expected type specifier for function argument")
				args.push(func_arg{arg_name, type_stmt()})
				let next_tok = lexer.peek()
				if next_tok != nil and next_tok.type == lex.COMMA:
					lexer.next()
				else:
					done = true
		return args

	def func() -> AST_node?:
		let consume = fn(tok_type, error_str):
			let err, tok = lexer.consume(tok_type, error_str)
			if tok == nil or not err:
				return nil from func
			tok

		let _, def_tok = lexer.consume(lex.DEF, "expected def") // ät "def"
		assert def_tok
		let name = consume(lex.IDENT, "expected function name") // eat function name
		guard name is lex.string_token:
			error("func name should be string")
			return from program
		consume(lex.LPAR, "expected parantese in function declaration")
		let args = arg_delc_list()
		lexer.consume(lex.RPAR, "expected closing parantese")
		lexer.consume(lex.AROW, "function arrow neaded")
		let func_type = type_stmt()
		let func_block = block()
		let arg_types = []
		let arg_names = []
		for(args) v:
			arg_types.push(v.type)
			arg_names.push(v.name)
		return AST_func_decl {
			def_tok,
			name.value,
			type_struct(func_type, arg_types),
			arg_names,
			func_block
		}

	def block() -> [AST_node]:
		lexer.consume(lex.LCURLPAR, "expected \'\{\' at begining of block")
		let statments = []
		while true:
			let tok = lexer.peek()
			if tok != nil and tok.type == lex.RCURLPAR:
				lexer.next()
				return statments
			else:
				let statment = top_expr()
				guard statment != nil:
					return []
				statments.push(statment)

	def if_else() -> AST_node?:
		// IF eller ELSE...
		let keyword = lexer.peek()
		guard keyword and (keyword.type == lex.IF or keyword.type == lex.ELSE or keyword.type == lex.ELIF):
			// annars är det ett fel
			return nil
		lexer.next() // ät if/else
		
		var condition = nil
		if keyword.type == lex.IF or keyword.type == lex.ELIF:
			// ät up kravet...
			condition = logic()
			// och se till att det gick vägen
			if condition == nil:
				return nil
		
		// huvuddelen av greningen
		let body = block()

		if keyword.type == lex.IF or keyword.type == lex.ELIF:
			// detta vet vi
			assert condition
		
			let next = if_else()
			
			// generara node
			return AST_if {
				keyword,
				body,
				condition,
				next
			}
		else: // if keyword.type == lex.ELSE
			return AST_else { keyword, body }
	
	// return statment
	def ret() -> AST_node?:
		// helper for eating tokens
		let consume = fn(tok_type, error_str):
			let err, tok = lexer.consume(tok_type, error_str)
			if tok == nil or not err:
				return nil from ret
			tok
		
		// consume "return" keyword
		let ret_tok = consume(lex.RET, "expected return keyword in return statment")
		// return value
		let body = top_expr()
		guard body:
			return nil
		// construct node
		return AST_ret{ ret_tok, body }
	
	// type specifier
	def type_stmt() -> type_struct:
		let first = lexer.next()
		guard first:
			return type_struct(UNSET)
		switch first.type:
			case lex.LPAR:
				let inner_type = type_stmt()
				lexer.consume(lex.RPAR, "expected closing parantese")
				return inner_type
			case lex.IDENT:
				assert first is lex.string_token
				return string_to_type(first.value)
			case lex.FN:
				let argumentents = []
				var go = true
				while go:
					let arg_type = type_stmt()
					argumentents.push(arg_type)
					let next = lexer.peek()
					if next != nil and next.type == lex.COMMA:
						lexer.next()
					else:
						go = false
				
				let next_tok = lexer.peek()
				// om vi har en till typ effter det här
				if (next_tok != nil
					and (next_tok.type == lex.LPAR 
					or next_tok.type == lex.IDENT
					or next_tok.type == lex.FN)):
					let ret_type = type_stmt()
					return type_struct(ret_type, argumentents)
				else:
					// om vi helt enkelt kan ta från "argumentents"
					if argumentents.length() == 1:
						let ret_type = argumentents.pop()
						return type_struct(ret_type, [])
					// annars är det ett fel
					else:
						error_at_node("expected return type", next_tok)
						return type_struct(UNSET)
			default:
				error_at_node("expected type", first)
				return type_struct(UNSET)

def error_at_node(e, token):
	if token != nil:
		error(e, token.offset, token.length)
	else:
		print("\nERROR: {e}")

import pass
import from ".."
import types
import scope

class type_pass : ast_pass
	current_scope: scope
	good = true
	def analyse(node: AST_node, error) -> bool:
		let _ = visit(node) e, at: // FIXME let _ borde inte behövas
			good = false
			error(e, at)
		return good

	def visit(node: AST_node, error) -> type_struct:
		return switch node:
			case AST_div: visit_op(node, error)
			case AST_sub: visit_op(node, error)
			case AST_mult: visit_op(node, error)
			case AST_add: visit_op(node, error)
			case AST_pow: visit_op(node, error)
			case AST_root:
				for(node.body) child:
					let _ = visit(child, error) // FIXME let _ borde inte behövas
					pass()
				type_struct(UNSET)
			case AST_expr:
				node.type = visit(node.body, error)
			case AST_group:
				node.type = visit(node.body, error)
			case AST_unary_sub: visit_unary(node, error)
			case AST_float_literal: type_struct(FLOAT)
			case AST_int_literal: type_struct(INT)
			case AST_string_literal: type_struct(STRING)
			case AST_bool_literal: type_struct(BOOL)
			case AST_or: visit_logic(node, error)
			case AST_and: visit_logic(node, error)
			case AST_equal: visit_logic(node, error)
			case AST_not_equal: visit_logic(node, error)
			case AST_greater_equal: visit_logic(node, error)
			case AST_less_equal: visit_logic(node, error)
			case AST_greater: visit_logic(node, error)
			case AST_less: visit_logic(node, error)
			case AST_not: visit_unary(node, error)
			case AST_decl: visit_declr(node, error)
			case AST_var: visit_var(node, error)
			case AST_call: visit_call(node, error)
			case AST_func_decl: visit_func(node, error)
			case AST_if: visit_if(node, error)
			case AST_else: visit_else(node, error)
			case AST_ret:
				let _ = visit(node.body, error)
				type_struct(UNSET)
			default:
				print("type_pass: unknown ast type {node}")
				return type_struct(UNSET)

	def visit_op(node, error) -> type_struct:
		if node is AST_div or node is AST_sub or node is AST_mult or node is AST_add:
			let left = visit(node.left, error)
			let right = visit(node.right, error)

			var op_string: string? = nil
			let op = fn() -> string:
				if op_string == nil:
					op_string = switch node:
						case AST_div: "divide"
						case AST_sub: "subtract"
						case AST_add: "add"
						case AST_mult: "multiply"
						default:
							error("internal type error (unrek node)", node)
							"ERROR"
					op_string
				else:
					op_string

			if not node is AST_mult and not node is AST_add:
				if not right.eq(left):
					error("can\'t {op()} two difrent types", node)
				if not is_num(right):
					error("can\'t {op()} non-number", node.right)
				if not is_num(left):
					error("can\'t {op()} non-number", node.left)
				node.type = right
			
			elif node is AST_add:
				if not right.eq(left):
					error("can\'t {op()} two difrent types", node)
				if not not is_num(right) and right.eq(STRING):
					error("can\'t {op()} non-number", node.right)
				if not not is_num(left) and left.eq(STRING):
					error("can\'t {op()} non-number", node.left)
				node.type = right

			elif node is AST_mult:
				if right.eq(STRING) and left.eq(INT):
					node.type_left = left
					node.type_right = right
					return type_struct(STRING)
				elif right.eq(INT) and left.eq(STRING):
					node.type_left = left
					node.type_right = right
					return type_struct(STRING)
				else:
					if not right.eq(left):
						error("can\'t {op()} two difrent types", node)
					if not is_num(right):
						error("can\'t {op()} non-number", node.right)
					if not is_num(left):
						error("can\'t {op()} non-number", node.left)
					node.type_left = left
					node.type_right = right
					return left
			
			if not node is AST_mult:
				return node.type
			else:
				return type_struct(UNSET) // här ska vi aldrig hamna
			
		elif node is AST_pow:
			// vi vet att exponenten alltid är ett heltal, t.ex. 2²
			assert node.exp is AST_int_literal
			let base = visit(node.base, error)
			if not base.is_num():
				error("can\'t raise non-number", node.base)
			node.type = base
			return node.type
		else:
			error("internal type error (NONOP)", node)
			return type_struct(UNSET)

	def visit_unary(node, error) -> type_struct:
		if node is AST_unary_sub:
			let type = visit(node.body, error)
			if not type.is_num():
				error("can only negate numbers", node.body)
				return type_struct(UNSET)
			node.type = type
			return type
		if node is AST_not:
			let type = visit(node.body, error)
			if not type.eq(BOOL):
				error("can only invert booleans", node.body)
			return type_struct(BOOL)
		else:
			error("internal type error (NONUNOP)", node)
			return type_struct(UNSET)

	def visit_logic(node, error) -> type_struct:
		if node is AST_or or node is AST_and:
			if not visit(node.left, error).eq(BOOL):
				error("can\'t and/or non bool", node.left)
			if not visit(node.right, error).eq(BOOL):
				error("can\'t and/or non bool", node.right)

		elif node is AST_equal or node is AST_not_equal:
			let left = visit(node.left, error)
			let right = visit(node.right, error)
			if not left.eq(right):
				error("can\'t compare two difrent types", node.right)

		elif (node is AST_greater_equal or
			node is AST_less_equal or
			node is AST_greater or
			node is AST_less):
			let left = visit(node.left, error)
			let right = visit(node.right, error)
			if not left.is_num():
				error("can\'t do less/greater then comparison on non-number", node.left)
			if not right.is_num():
				error("can\'t do less/greater then comparison on non-number", node.right)
			if not left.eq(right):
				error("can\'t compare two difrent types", node.right)
			
		else:
			error("internal type error (NOLOGIC)", node)
		
		return type_struct(BOOL)

	def visit_declr(node: AST_decl, error) -> type_struct:
		let type = visit(node.body, error)
		node.type = type
		current_scope.set(node.name, type)
		return type

	def visit_var(node: AST_var, error) -> type_struct:
		let type = current_scope.get(node.name)
		if type.eq(UNSET):
			error("unknown identifier", node)
			return type_struct(UNSET)
		return type

	def visit_call(node: AST_call, error) -> type_struct:
		guard node.func is AST_var:
			error("can only call functions", node.func)
			return type_struct(UNSET)
		let type = current_scope.get(node.func.name)
		if type.type != FUNC or type.func == nil:
			error("unknown identifier", node)
			return type_struct(UNSET)
		else:
			guard type.func.argumentents.length() == node.args.length():
				error("wrong arity", node)
				return type_struct(UNSET)
			for(type.func.argumentents) arg, i:
				if i >= node.args.length:
					error("internal arity error", node)
					return type_struct(UNSET)
				if not visit(node.args[i], error) == arg:
					error("wrong type for function argument {string(i)}", node)
					return type_struct(UNSET)
			node.type = type.func.return_type
			print("ret type: {type.func.return_type} = {node.type}; {node.func.name}")
			return type.func.return_type

	def visit_func(node: AST_func_decl, error) -> type_struct:
		current_scope.set(node.name, node.type)
		current_scope.scope():
			for(node.arg_names.length()) i:
				assert node.type.func
				current_scope.set(node.arg_names[i], node.type.func.argumentents[i])
			for(node.body) child:
				let _ = visit(child, error)
				pass()
		current_scope.print_scope()
		return type_struct(UNSET)

	def visit_if(node, error) -> type_struct:
		current_scope.scope():
			for(node.body) child:
				let _ = visit(child, error)
				pass()
		if node.else_part != nil:
			let _ = visit(node.else_part, error)
			pass()
		guard visit(node.condition, error) == BOOL:
			error("if condition neads to be of type bool", node)
			return type_struct(UNSET)
		return type_struct(UNSET)
	def visit_else(node, error) -> type_struct:
		current_scope.scope():
			for(node.body) child:
				let _ = visit(child, error)
				pass()
		return type_struct(UNSET)


constructor type_pass():
	let new_pass = type_pass{scope{}}
	new_pass.current_scope.set(
		"print",
		type_struct(
			type_struct(NIL),
			[
				type_struct(STRING)
			]
		)
	)
	return new_pass

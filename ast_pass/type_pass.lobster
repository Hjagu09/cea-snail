import pass
import from ".."
import types
import ident_pass

class type_pass : ast_pass
	current_scope: scope
	good = true
	def analyse(node: AST_node, error) -> bool:
		visit(node) e, at:
			good = false
			error(e, at)
		return good

	def visit(node: AST_node, error) -> int:
		return switch node:
			case AST_div: visit_op(node, error)
			case AST_sub: visit_op(node, error)
			case AST_mult: visit_op(node, error)
			case AST_add: visit_op(node, error)
			case AST_pow: visit_op(node, error)
			case AST_root:
				for(node.body) child:
					visit(child, error)
				UNSET
			case AST_expr:
				node.type = visit(node.body, error)
			case AST_group:
				node.type = visit(node.body, error)
			case AST_unary_sub: visit_unary(node, error)
			case AST_float_literal: FLOAT
			case AST_int_literal: INT
			case AST_string_literal: STRING
			case AST_bool_literal: BOOL
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
			default:
				print("type_pass: unknown ast type {node}")
				return  UNSET

	def visit_op(node, error) -> int:
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
				if right != left:
					error("can\'t {op()} two difrent types", node)
				if not is_num(right):
					error("can\'t {op()} non-number", node.right)
				if not is_num(left):
					error("can\'t {op()} non-number", node.left)
				node.type = right
			
			elif node is AST_add:
				if right != left:
					error("can\'t {op()} two difrent types", node)
				if not is_num(right) and right != STRING:
					error("can\'t {op()} non-number", node.right)
				if not is_num(left) and left != STRING:
					error("can\'t {op()} non-number", node.left)
				node.type = right

			elif node is AST_mult:
				if right == STRING and left == INT:
					node.type_left = left
					node.type_right = right
					return STRING
				elif right == INT and left == STRING:
					node.type_left = left
					node.type_right = right
					return STRING
				else:
					if right != left:
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
				return UNSET // här ska vi aldrig hamna
			
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
			return UNSET

	def visit_unary(node, error) -> int:
		if node is AST_unary_sub:
			let type = visit(node.body, error)
			if not type.is_num():
				error("can only negate numbers", node.body)
				return UNSET
			node.type = type
			return type
		if node is AST_not:
			let type = visit(node.body, error)
			if type != BOOL:
				error("can only invert booleans", node.body)
			return BOOL
		else:
			error("internal type error (NONUNOP)", node)
			return UNSET

	def visit_logic(node, error) -> int:
		if node is AST_or or node is AST_and:
			if visit(node.left, error) != BOOL:
				error("can\'t and/or non bool", node.left)
			if visit(node.right, error) != BOOL:
				error("can\'t and/or non bool", node.right)

		elif node is AST_equal or node is AST_not_equal:
			let left = visit(node.left, error)
			let right = visit(node.right, error)
			if left != right:
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
			if left != right:
				error("can\'t compare two difrent types", node.right)
			
		else:
			error("internal type error (NOLOGIC)", node)
		
		return BOOL

	def visit_declr(node: AST_decl, error) -> int:
		let type = visit(node.body, error)
		node.type = type
		current_scope.set(node.name, type)
		return type

	def visit_var(node: AST_var, error) -> int:
		let type = current_scope.get(node.name)
		if type == UNSET:
			error("unknown identifier", node)
			return UNSET
		return type

constructor type_pass():
	let new_pass = type_pass{scope{}}
	return new_pass

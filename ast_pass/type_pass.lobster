import pass
import from ".."
import types

class type_pass : ast_pass
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
			case AST_float_literal: FLOAT
			case AST_int_literal: INT
			case AST_string_literal: STRING
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


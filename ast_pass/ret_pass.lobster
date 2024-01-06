import pass
import from ".."
import types

class ret_pass: ast_pass
	good = true
	current_func: AST_func_decl? = nil
	def analyse(node: AST_node, error) -> bool:
		visit(node) e, at:
			good = false
			error(e, at)
		return good

	def visit(node: AST_node, error) -> bool:
		return switch node:
			case AST_root:
				for(node.body) child:
					visit(child, error)
				false
			case AST_if:
				var ret = false
				for(node.body) child:
					let child_ret = visit(child, error)
					ret = child_ret or ret
				if node.else_part is AST_else:
					var else_ret = false
					for(node.else_part.body) child:
						let child_ret = visit(child, error)
						else_ret = child_ret or else_ret
					ret = else_ret and ret
				ret
			case AST_func_decl:
				let is_void = node.type.func != nil and node.type.func.return_type == NIL
				current_func = node

				var ret = false
				for(node.body) child:
					let child_ret = visit(child, error)
					ret = child_ret or ret

				current_func = nil
				if not ret and not is_void:
					error("function neads to return", node)
				false
			case AST_ret:
				guard current_func:
					error("return neads to be in a function", node)
					true
				let this_ret_type = node.body.get_type()
				assert current_func.type.func != nil
				let func_ret_type = current_func.type.func.return_type
				if func_ret_type != this_ret_type:
					error("wrong return type", node)
				true
			default: false

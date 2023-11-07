abstract class AST_node:
	def str(ind: int = 0) -> string: return "  ".repeat_string(ind) + "node"
class AST_string_literal : AST_node
	value: string
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "string_literal:"
		out += " value " + string(value)
		out += "\n"
		return out
class AST_int_literal : AST_node
	value: int
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "int_literal:"
		out += " value " + string(value)
		out += "\n"
		return out
class AST_float_literal : AST_node
	value: float
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "float_literal:"
		out += " value " + string(value)
		out += "\n"
		return out
class AST_add : AST_node
	type: int = -1
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "add:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
class AST_sub : AST_node
	type: int = -1
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "sub:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
class AST_mult : AST_node
	type_left: int = -1
	type_right: int = -1
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "mult:"
		out += " type_left " + string(type_left)
		out += ", type_right " + string(type_right)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
class AST_div : AST_node
	type: int = -1
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "div:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
class AST_pow : AST_node
	type: int = -1
	base: AST_node
	exp: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "pow:"
		out += " type " + string(type)
		out += "\n"
		out += base.str(ind + 1) + ""
		out += exp.str(ind + 1) + ""
		return out
class AST_group : AST_node
	type: int = -1
	body: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "group:"
		out += " type " + string(type)
		out += "\n"
		out += body.str(ind + 1) + ""
		return out
class AST_root : AST_node
	body: [AST_node]
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "root:"
		out += "\n"
		for(body) __c:
			out += __c.str(ind + 1) + ""
		return out
class AST_var : AST_node
	name: string
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "var:"
		out += " name " + string(name)
		out += "\n"
		return out
class AST_expr : AST_node
	type: int = -1
	body: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "expr:"
		out += " type " + string(type)
		out += "\n"
		out += body.str(ind + 1) + ""
		return out

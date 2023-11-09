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
class AST_unary_sub : AST_node
	type: int = -1
	body: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "unary_sub:"
		out += " type " + string(type)
		out += "\n"
		out += body.str(ind + 1) + ""
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
class AST_and : AST_node
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "and:"
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
class AST_or : AST_node
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "or:"
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
class AST_equal : AST_node
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "equal:"
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
class AST_not_equal : AST_node
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "not_equal:"
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
class AST_less_equal : AST_node
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "less_equal:"
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
class AST_greater_equal : AST_node
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "greater_equal:"
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
class AST_less : AST_node
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "less:"
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
class AST_greater : AST_node
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "greater:"
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
class AST_bool_literal : AST_node
	value: bool
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "bool_literal:"
		out += " value " + string(value)
		out += "\n"
		return out
class AST_not : AST_node
	body: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "not:"
		out += "\n"
		out += body.str(ind + 1) + ""
		return out

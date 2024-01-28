import from ".."
import types
import lexer
abstract class AST_node:
	source_token: lex.token
	def get_type() -> type_struct: return type_struct(UNSET)
	def str(ind: int = 0) -> string: return "  ".repeat_string(ind) + "node"
	def all_childs() -> [AST_node]: return []
class AST_string_literal : AST_node
	value: string
	type: type_struct = type_struct(STRING)
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "string_literal:"
		out += " value " + string(value)
		out += ", type " + string(type)
		out += "\n"
		return out
	def all_childs():
		let __childs = []
		return __childs
	def get_type() -> type_struct:
		return type
class AST_int_literal : AST_node
	value: int
	type: type_struct = type_struct(INT)
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "int_literal:"
		out += " value " + string(value)
		out += ", type " + string(type)
		out += "\n"
		return out
	def all_childs():
		let __childs = []
		return __childs
	def get_type() -> type_struct:
		return type
class AST_float_literal : AST_node
	value: float
	type: type_struct = type_struct(FLOAT)
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "float_literal:"
		out += " value " + string(value)
		out += ", type " + string(type)
		out += "\n"
		return out
	def all_childs():
		let __childs = []
		return __childs
	def get_type() -> type_struct:
		return type
class AST_add : AST_node
	type: type_struct = type_struct(UNSET)
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "add:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(left)
		__childs.push(right)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_sub : AST_node
	type: type_struct = type_struct(UNSET)
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "sub:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(left)
		__childs.push(right)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_mult : AST_node
	type_left: type_struct = type_struct(UNSET)
	type_right: type_struct = type_struct(UNSET)
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
	def all_childs():
		let __childs = []
		__childs.push(left)
		__childs.push(right)
		return __childs
	def get_type() -> type_struct:
		return type_left
class AST_div : AST_node
	type: type_struct = type_struct(UNSET)
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "div:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(left)
		__childs.push(right)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_pow : AST_node
	type: type_struct = type_struct(UNSET)
	base: AST_node
	exp: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "pow:"
		out += " type " + string(type)
		out += "\n"
		out += base.str(ind + 1) + ""
		out += exp.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(base)
		__childs.push(exp)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_unary_sub : AST_node
	type: type_struct = type_struct(UNSET)
	body: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "unary_sub:"
		out += " type " + string(type)
		out += "\n"
		out += body.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(body)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_group : AST_node
	type: type_struct = type_struct(UNSET)
	body: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "group:"
		out += " type " + string(type)
		out += "\n"
		out += body.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(body)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_root : AST_node
	type: type_struct = type_struct(NIL)
	body: [AST_node]
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "root:"
		out += " type " + string(type)
		out += "\n"
		for(body) __c:
			out += __c.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		for(body) __c:
			__childs.push(__c)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_var : AST_node
	name: string
	type: type_struct = type_struct(UNSET)
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "var:"
		out += " name " + string(name)
		out += ", type " + string(type)
		out += "\n"
		return out
	def all_childs():
		let __childs = []
		return __childs
	def get_type() -> type_struct:
		return type
class AST_expr : AST_node
	type: type_struct = type_struct(UNSET)
	body: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "expr:"
		out += " type " + string(type)
		out += "\n"
		out += body.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(body)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_and : AST_node
	type: type_struct = type_struct(BOOL)
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "and:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(left)
		__childs.push(right)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_or : AST_node
	type: type_struct = type_struct(BOOL)
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "or:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(left)
		__childs.push(right)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_equal : AST_node
	type: type_struct = type_struct(BOOL)
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "equal:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(left)
		__childs.push(right)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_not_equal : AST_node
	type: type_struct = type_struct(BOOL)
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "not_equal:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(left)
		__childs.push(right)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_less_equal : AST_node
	type: type_struct = type_struct(BOOL)
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "less_equal:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(left)
		__childs.push(right)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_greater_equal : AST_node
	type: type_struct = type_struct(BOOL)
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "greater_equal:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(left)
		__childs.push(right)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_less : AST_node
	type: type_struct = type_struct(BOOL)
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "less:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(left)
		__childs.push(right)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_greater : AST_node
	type: type_struct = type_struct(BOOL)
	left: AST_node
	right: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "greater:"
		out += " type " + string(type)
		out += "\n"
		out += left.str(ind + 1) + ""
		out += right.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(left)
		__childs.push(right)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_bool_literal : AST_node
	value: bool
	type: type_struct = type_struct(BOOL)
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "bool_literal:"
		out += " value " + string(value)
		out += ", type " + string(type)
		out += "\n"
		return out
	def all_childs():
		let __childs = []
		return __childs
	def get_type() -> type_struct:
		return type
class AST_not : AST_node
	type: type_struct = type_struct(BOOL)
	body: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "not:"
		out += " type " + string(type)
		out += "\n"
		out += body.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(body)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_call : AST_node
	type: type_struct = type_struct(UNSET)
	func: AST_node
	args: [AST_node]
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "call:"
		out += " type " + string(type)
		out += "\n"
		out += func.str(ind + 1) + ""
		for(args) __c:
			out += __c.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(func)
		for(args) __c:
			__childs.push(__c)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_decl : AST_node
	name: string
	type: type_struct = type_struct(NIL)
	body: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "decl:"
		out += " name " + string(name)
		out += ", type " + string(type)
		out += "\n"
		out += body.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(body)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_asig : AST_node
	name: string
	type: type_struct = type_struct(NIL)
	body: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "asig:"
		out += " name " + string(name)
		out += ", type " + string(type)
		out += "\n"
		out += body.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(body)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_func_decl : AST_node
	name: string
	type: type_struct
	arg_names: [string]
	body: [AST_node]
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "func_decl:"
		out += " name " + string(name)
		out += ", type " + string(type)
		out += ", arg_names " + string(arg_names)
		out += "\n"
		for(body) __c:
			out += __c.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		for(body) __c:
			__childs.push(__c)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_lambda : AST_node
	type: type_struct
	arg_names: [string]
	body: [AST_node]
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "lambda:"
		out += " type " + string(type)
		out += ", arg_names " + string(arg_names)
		out += "\n"
		for(body) __c:
			out += __c.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		for(body) __c:
			__childs.push(__c)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_if : AST_node
	type: type_struct = type_struct(NIL)
	body: [AST_node]
	condition: AST_node
	else_part: AST_node?
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "if:"
		out += " type " + string(type)
		out += "\n"
		for(body) __c:
			out += __c.str(ind + 1) + ""
		out += condition.str(ind + 1) + ""
		if else_part != nil:
			out += else_part.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		for(body) __c:
			__childs.push(__c)
		__childs.push(condition)
		if else_part != nil:
			__childs.push(else_part)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_else : AST_node
	type: type_struct = type_struct(NIL)
	body: [AST_node]
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "else:"
		out += " type " + string(type)
		out += "\n"
		for(body) __c:
			out += __c.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		for(body) __c:
			__childs.push(__c)
		return __childs
	def get_type() -> type_struct:
		return type
class AST_ret : AST_node
	type: type_struct = type_struct(NIL)
	body: AST_node
	def str(ind: int = 0) -> string:
		var out = "  ".repeat_string(ind) + "ret:"
		out += " type " + string(type)
		out += "\n"
		out += body.str(ind + 1) + ""
		return out
	def all_childs():
		let __childs = []
		__childs.push(body)
		return __childs
	def get_type() -> type_struct:
		return type

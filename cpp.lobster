import codegen
import from ".."
import types 
namespace codegen

class cpp_code_builder:
	main: bool
	prots = []
	decs = []
	code = []
	var_name: int = 0
	def func(signature, body: cpp_code_builder):
		func(signature, body.get_code())
	def func(signature, body: string):
		prots.push(signature + ";")
		decs.push(signature + "\{\n")
		decs.push(body)
		decs.push("\}\n")

	def cvar(name, type):
		prots.push("{type} {name}")
	def code_line(line):
		code.push(line)
	def get_code():
		let output = [
			concat_string(prots, "\n"),
			concat_string(decs, "\n")
		]
		if main:
			let main_func = [
				"int main()\{",
				concat_string(code, "\n"),
				"\}"
			]
			output.push(concat_string(main_func, "\n"))
		else:
			output.push(concat_string(code, "\n"))
		return concat_string(output, "\n\n")
	def include(line):
		prots.push(line)
	def get_var_name() -> string:
		return "__{number_to_string(var_name++, 16, 4)}__"

class to_cpp : codegen
	builder = cpp_code_builder{true}
	def generate() -> to_cpp:
		builder.include("#include <math.h>")
		builder.include("#include <cstddef>")
		builder.include("#include <iostream>")
		builder.include("#include <string>")
		// här måste vi va färdiga med "#include ..."s om vi ska generera snygg kod

		builder.func(
			"std::string repeat(size_t n, const std::string& str)",
			"""
				if (n == 0 || str.empty()) return {};
				if (n == 1) return str;
				const auto period = str.size();
				if (period == 1) return std::string(n, str.front());

				std::string ret(str);
				ret.reserve(period * n);
				std::size_t m {2};
				for (; m < n; m *= 2) ret += ret;
				ret.append(ret.c_str(), (n - (m / 2)) * period);
				return ret;
			""".replace_string("\t", "")
		)
		visit_root(ast)
		return this
	def get_code() -> string:
		return builder.get_code()
	def error(node):
		print("internalt codegen cpp error, {node.str()}")

	def visit_root(node: AST_node) -> void:
		if node is AST_root:
			for(node.body) child:
				visit_expr(child)
		else:
			error(node)

	def visit_expr(node: AST_node) -> void:
		if node is AST_expr:
			builder.code_line("std::cout << " + eval(node.body) + " << std::endl;")
		else:
			error(node)

	def eval(node: AST_node) -> string:
		return switch node:
			case AST_add: visit_add(node)
			case AST_sub: visit_sub(node)
			case AST_div: visit_div(node)
			case AST_mult: visit_mult(node)
			case AST_pow: visit_pow(node)
			case AST_int_literal: visit_int(node)
			case AST_float_literal: visit_float(node)
			case AST_var: visit_var(node)
			case AST_group: visit_group(node)
			case AST_string_literal: visit_string(node)
			case AST_unary_sub: visit_un_sub(node)
			case AST_equal: visit_equal(node)
			case AST_greater_equal: visit_greater_equal(node)
			case AST_less_equal: visit_less_equal(node)
			case AST_greater: visit_greater(node)
			case AST_less: visit_less(node)
			case AST_not_equal: visit_not_equal(node)
			case AST_and: visit_and(node)
			case AST_or: visit_or(node)
			case AST_not: visit_not(node)
			case AST_bool_literal:
				if node.value:
					"true"
				else:
					"false"
			default:
				error(node)
				"/* ERROR */"

	// lägg till tmp för att fixa ordning
	def visit_group(node: AST_group) -> string:
		return "(" + eval(node.body) + ")"
	def visit_add(node: AST_add) -> string:
		return "(" + eval(node.left) + " + " + eval(node.right) + ")"
	def visit_sub(node: AST_sub) -> string:
		return "(" + eval(node.left) + " - " + eval(node.right) + ")"
	def visit_mult(node: AST_mult) -> string:
		if node.type_left == STRING:
			return "repeat({eval(node.right)}, {eval(node.left)})"
		if node.type_right == STRING:
			return "repeat({eval(node.left)}, {eval(node.right)})"
		else:
			return "(" + eval(node.left) + " * " + eval(node.right) + ")"
	def visit_div(node: AST_div) -> string:
		return "(" + eval(node.left) + " / " + eval(node.right) + ")"
	def visit_pow(node: AST_pow) -> string:
		return "pow(" + eval(node.base) + ", " + eval(node.exp) + ")"
	def visit_un_sub(node: AST_unary_sub) -> string:
		return "-{eval(node.body)}"

	def visit_int(node: AST_int_literal) -> string:
		return string(node.value)
	def visit_float(node: AST_float_literal) -> string:
		return string(node.value)
	def visit_var(node: AST_var) -> string:
		return string(node.name)
	def visit_string(node: AST_string_literal) -> string:
		return "std::string(\"{node.value}\")"

	def visit_not_equal(node: AST_not_equal) -> string:
		return "({eval(node.left)} != {eval(node.right)})"
	def visit_equal(node: AST_equal) -> string:
		return "({eval(node.left)} == {eval(node.right)})"
	def visit_greater(node: AST_greater) -> string:
		return "({eval(node.left)} < {eval(node.right)})"
	def visit_less(node: AST_less) -> string:
		return "({eval(node.left)} < {eval(node.right)})"
	def visit_less_equal(node: AST_less_equal) -> string:
		return "({eval(node.left)} <= {eval(node.right)})"
	def visit_greater_equal(node: AST_greater_equal) -> string:
		return "({eval(node.left)} >= {eval(node.right)})"
	// FIXME AST är backochfram
	def visit_or(node: AST_or) -> string:
		let left, right = builder.get_var_name(), builder.get_var_name()
		builder.code_line("const auto {left} = {eval(node.left)};")
		builder.code_line("const auto {right} = {eval(node.right)};")
		return "({left} or {right})"
	def visit_and(node: AST_and) -> string:
		let left, right = builder.get_var_name(), builder.get_var_name()
		builder.code_line("const auto {left} = {eval(node.left)};")
		builder.code_line("const auto {right} = {eval(node.right)};")
		return "({left} and {right})"

	def visit_not(node: AST_not) -> string:
		return "!({eval(node.body)})"

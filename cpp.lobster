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
	def builder_func(signature, body: cpp_code_builder):
		assert main
		func(signature, body.get_code())
	def func(signature, body: string):
		assert main
		prots.push(signature + ";")
		decs.push(signature + "\{\n")
		decs.push(body)
		decs.push("\}\n")
	def func(name: string, return_type: type_struct, arg_type: [type_struct], arg_names: [string], body_builder):
		assert main
		var signature = ""
		signature += return_type.type_to_cpp() + " "
		signature += cpp_ident(name) + "("
		for(arg_names.length()) i:
			if i != 0:
				signature += ", "
			signature += arg_type[i].type_to_cpp() + " " + cpp_ident(arg_names[i])
		signature += ")"
		let body = cpp_code_builder{false}
		body_builder(body)
		builder_func(signature, body)
	def block(body):
		code_line("{{")
		body()
		code_line("}}")

	def cvar(name, type):
		prots.push("{type} {name};")
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
			output.push(concat_string(code, "\n")) // FIXME kommer inte funka
		return concat_string(output, "\n\n")
	def include(line):
		prots.push(line)
	def get_var_name() -> string:
		return "__{number_to_string(var_name++, 16, 4)}__"
	def cpp_ident(name: string) -> string:
		return "___identifier___{name}___"

def type_to_cpp(type: type_struct) -> string:
	return switch type.type:
		case INT: "int"
		case STRING: "std::string"
		case FLOAT: "double"
		case BOOL: "bool"
		case UNSET: "/* ERROR unset type */"
		case NIL: "void" // kanske måste va void*
		case FUNC:
			assert type.func
			var type_str = "std::function<{type_to_cpp(type.func.return_type)}("
			for(type.func.argumentents) arg, i:
				if i != 0:
					type_str += ","
				type_str += type_to_cpp(arg)
			type_str += ")>"
			type_str
		default: "/* ERROR unknown type (cpp.lobster 53) */"

class to_cpp : codegen
	builder = cpp_code_builder{true}
	def generate() -> to_cpp:
		load_std_lib()
		visit_root(ast)
		return this
	def get_code() -> string:
		return builder.get_code()
	def error(node):
		print("internalt codegen cpp error, {node.str()}")

	def load_std_lib():
		let includes = scan_folder(command_line_arguments()[3] + "/rc/c++/include") // what headers to include
		let std_libs = scan_folder(command_line_arguments()[3] + "/rc/c++/lib/") // other code that may use those headers
		guard includes != nil:
			print("can\'t find std_include")
			return from program
		guard std_libs != nil:
			print("can\'t find std_lib")
			return from program
		for(includes) include_file_name:
			// cmd line arg 3 är var vi ör
			let include = read_file(command_line_arguments()[3] + "/rc/c++/include/" + include_file_name)
			assert include != nil
			builder.include(include)
		for(std_libs) include_file_name:
			let include = read_file(command_line_arguments()[3] + "/rc/c++/lib/" + include_file_name)
			assert include != nil
			builder.include(include)
		

	def visit_root(node: AST_node) -> void:
		if node is AST_root:
			for(node.body) child:
				builder.code_line("{eval(child)};")
		else:
			error(node)

	def visit_expr(node: AST_node) -> string:
		if node is AST_expr:
			return eval(node.body)
		else:
			error(node)
			return "/*ERROR*/"

	def eval(node: AST_node, new_builder: cpp_code_builder? = nil) -> string:
		let old_builder = builder
		if new_builder:
			builder = new_builder
		let ret_code = switch node:
			case AST_add: visit_add(node)
			case AST_sub: visit_sub(node)
			case AST_div: visit_div(node)
			case AST_mult: visit_mult(node)
			case AST_pow: visit_pow(node)
			case AST_int_literal: visit_int(node)
			case AST_float_literal: visit_float(node)
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
			case AST_decl: visit_var_decl(node)
			case AST_var: visit_var_cgen(node)
			case AST_expr: visit_expr(node)
			case AST_call: visit_call(node)
			case AST_func_decl: visit_func_decl(node)
			case AST_if: visit_if(node)
			case AST_else: visit_else(node)
			case AST_ret: visit_return(node)
			case AST_lambda: visit_lambda(node)
			case AST_asig: visit_asig(node)
			case AST_bool_literal:
				if node.value:
					"true"
				else:
					"false"
			default:
				error(node)
				"/* ERROR */"
		if new_builder :
			builder = old_builder
		return ret_code

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

	def visit_var_cgen(node: AST_var) -> string:
		return "___identifier___{node.name}___"
	def visit_var_decl(node: AST_decl) -> string:
		print("visit_var_decl")
		if builder.main:
			builder.cvar(builder.cpp_ident(node.name), type_to_cpp(node.type))
			builder.code_line("___identifier___{node.name}___ = {eval(node.body)};")
		else:
			builder.code_line("{type_to_cpp(node.type)} ___identifier___{node.name}___ = {eval(node.body)};")
		return "___identifier___{node.name}___"

	def visit_call(node: AST_call) -> string:
		assert node.func is AST_var
		var args = ""
		for(node.args) arg, i:
			if i == 0:
				args += "{eval(arg)}"
			else:
				args += ", {eval(arg)}"
		if node.type.type >= 0: // inte NIL eller UNSET
			let name = builder.get_var_name()
			builder.code_line("auto {name} = {builder.cpp_ident(node.func.name)}({args});")
			return name
		else:
			builder.code_line("{builder.cpp_ident(node.func.name)}({args});")
			return "NULL"

	def visit_lambda(node: AST_lambda) -> string:
		let name = builder.get_var_name()
		var arg_list = ""
		assert node.type.func
		for(node.arg_names) arg_name, index:
			if index != 0:
				arg_list += ","
			arg_list += "{type_to_cpp(node.type.func.argumentents[index])} {builder.cpp_ident(arg_name)}"
	
		builder.code_line("auto {name} = [&]({arg_list}) -> {type_to_cpp(node.type.func.return_type)} {{")
		for(node.body) child:
			builder.code_line("{eval(child)};")
		builder.code_line("}};")
		return name

	def visit_func_decl(node: AST_func_decl) -> string:
		assert node.type.func
		builder.func(
			node.name,
			node.type.func.return_type,
			node.type.func.argumentents,
			node.arg_names
		) func_builder:
			for(node.body) child:
				func_builder.code_line("{eval(child, func_builder)};")
		return builder.cpp_ident(node.name)

	def visit_if(node: AST_if) -> string:
		// condition
		builder.code_line("if ({eval(node.condition)})")
		builder.block():
			// if body
			for(node.body) child:
				builder.code_line("{eval(child)};")
		// if there is no else part, return
		guard node.else_part:
			return "NULL"
		
		// else do the else
		eval(node.else_part)
		return "NULL"
	def visit_else(node: AST_else) -> string:
		builder.code_line("else")
		builder.block():
			for(node.body) child:
				builder.code_line("{eval(child)};")
		return "NULL"

	def visit_return(node: AST_ret) -> string:
		return "return {eval(node.body)}"

	def visit_asig(node: AST_asig) -> string:
		builder.code_line("{builder.cpp_ident(node.name)} = {eval(node.body)};")
		return builder.cpp_ident(node.name)

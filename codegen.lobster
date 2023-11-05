namespace codegen
import from "./AST/"
import AST

abstract class codegen:
	ast: AST_root
	def generate() -> codegen: return this
	def get_code() -> string: return "code"

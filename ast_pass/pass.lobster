import from "../AST/"
import AST

abstract class ast_pass:
	def analyse(node: AST_node, error) -> bool: return true

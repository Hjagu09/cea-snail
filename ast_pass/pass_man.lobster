import pass

class pass_man:
	passes: [ast_pass]
	def run_passes(node: AST_node, debug) -> [bool]:
		let ok = []
		if debug:
			print("--------")
			print("pass_man running passes:")
		for(passes) p:
			if debug:
				print("  runing pass {p}")

			let error_func = fn error, at:
				print("ERROR: {error} at node \"{at.str()}\"")
				ok.push(false)
				return ok from run_passes

			ok.push(p.analyse(node, error_func))
		return ok

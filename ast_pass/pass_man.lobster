import pass

class pass_man:
	passes: [ast_pass]
	def run_passes(node: AST_node, debug) -> [bool]:
		let ok = []
		if debug:
			log("--------", CODE_PASS_LOG)
			log("pass_man running passes:", CODE_PASS_LOG)
		for(passes) p:
			if debug:
				log("  runing pass {p}", CODE_PASS_LOG)

			let error_func = fn e, at:
				error("{e}", at.source_token.offset, at.source_token.length, false)
				ok.push(false)
				return ok from run_passes

			ok.push(p.analyse(node, error_func))
		return ok

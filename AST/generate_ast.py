import json

with open("AST.json") as file:
	data = json.load(file)
	nodes = [
		"import from \"..\"",
		"import types",
		f"abstract class {data['name_pre'] + data['base']}:",
		"	def str(ind: int = 0) -> string: return \"  \".repeat_string(ind) + \"node\"",
		"\tdef all_childs() -> [AST_node]: return []"
	]
	for node in data["nodes"]:
		nodes.append(
			f"class {data['name_pre'] + node['name']} : {data['name_pre'] + data['base']}"
		)
		to_str = [
			"	def str(ind: int = 0) -> string:",
			f"		var out = \"  \".repeat_string(ind) + \"{node['name']}:\""
		]
		first = True
		for const in node["const"]:
			if len(const) == 2:
				nodes.append(
					f"	{const[0]}: {const[1]}"
				)
			else:
				nodes.append(
					f"	{const[0]}: {const[1]} = {const[2]}"
				)
			comma = ""
			if not first:
				comma = ","
			to_str.append(
				f"		out += \"{comma} {const[0]} \" + string({const[0]})"
			)
			first = False
		to_str.append("		out += \"\\n\"")
		all_childs = [
			"\tdef all_childs():",
			"\t\tlet __childs = []"
		]
		all_childs_first = True
		for child in node["childs"]:
			type = "node"
			if len(child) > 1:
				type = child[1]
			if type[-1] == "?":
				nodes.append(
					f"	{child[0]}: {data['name_pre'] + type}"
				)
				to_str.append(
					f"\t\tif {child[0]} != nil:"
				)
				to_str.append(
					f"\t\t\tout += {child[0]}.str(ind + 1) + \"\""
				)
				all_childs.append(
					f"\t\t__childs.push({child[0]})"
				)
			elif type[0:1] != "*":
				nodes.append(
					f"	{child[0]}: {data['name_pre'] + type}"
				)
				to_str.append(
					f"		out += {child[0]}.str(ind + 1) + \"\""
				)
				all_childs.append(
					f"\t\t__childs.push({child[0]})"
				)
			else:
				nodes.append(
					f"	{child[0]}: [{data['name_pre'] + type[1:]}]"
				)
				all_childs.append(
					f"\t\tfor({child[0]}) __c:\n\t\t\t__childs.push(__c)"
				)
				to_str.append(
					f"		for({child[0]}) __c:\n			out += __c.str(ind + 1) + \"\""
				)
		to_str.append("		return out")
		all_childs.append("\t\treturn __childs")
		nodes.append("\n".join(to_str))
		nodes.append("\n".join(all_childs))
	print("\n".join(nodes))

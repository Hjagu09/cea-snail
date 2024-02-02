enum types:
	STRING
	INT
	FLOAT
	BOOL
	FUNC
	UNSET = -1
	NIL = -2

struct type_struct

class func_class:
	return_type: type_struct 
	argumentents: [type_struct]

struct type_struct:
	type: int // typ från ovan --^
	func: func_class?
	list: bool
	def eq(comp_type: int) -> bool:
		return comp_type == type
	def eq(comp: type_struct) -> bool: 
		return type == comp.type and func.equal(comp.func)
	def operator==(comp_type: int) -> bool:
		return comp_type == type
	def operator==(comp: type_struct) -> bool:
		return eq(comp)

constructor type_struct(rtype: type_struct, argumentents: [type_struct]):
	return type_struct{FUNC, func_class{rtype, argumentents}, false}
constructor type_struct(type: int):
	return type_struct{type, nil, false}
constructor type_struct(type: int, list: bool):
	return type_struct{type, nil, list}

def is_num(type):
	return switch type.type:
		case INT: true
		case FLOAT: true
		default: false

def string_to_type(type_string: string):
	let type_int = switch type_string:
		case "int": INT
		case "nil": NIL
		case "bool": BOOL
		case "float": FLOAT
		case "str": STRING
		case "[int]": INT
		case "[nil]": NIL
		case "[bool]": BOOL
		case "[float]": FLOAT
		case "[str]": STRING
		default: UNSET
	return type_struct(type_int, type_string.find_string("[") > 0)

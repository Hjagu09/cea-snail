enum types:
	STRING
	INT
	FLOAT
	BOOL
	FUNC
	LIST
	UNSET = -1
	NIL = -2

class type_struct:
	type: int
	def operator==(comp_type: int) -> bool:
		return comp_type == type
	def operator==(comp_type: type_struct) -> bool:
		return comp_type.type == type
	def inner() -> int:
		return type
class func_class : type_struct
	return_type: type_struct
	argumentents: [type_struct]
	def operator==(comp_type: type_struct) -> bool:
		return comp_type is func_class and comp_type.return_type.equal(return_type) and comp_type.argumentents.equal(argumentents)
class list_class : type_struct
	inner_type: type_struct
	def operator==(comp_type: type_struct) -> bool:
		return comp_type is list_class and comp_type.inner_type.equal(inner_type)
	def inner() -> int:
		return inner_type.inner()

def type_struct(rtype: type_struct, argumentents: [type_struct]):
	return func_class{FUNC, rtype, argumentents}
def type_struct(type: int):
	return type_struct{type}
def list_class(type: int):
	return list_class{LIST, type_struct(type)}
def list_class(type: type_struct):
	return list_class{LIST, type}


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
		case "[int]": INT // TODO
		case "[nil]": NIL
		case "[bool]": BOOL
		case "[float]": FLOAT
		case "[str]": STRING
		default: UNSET
	if type_string.find_string("[") > 0:
		return list_class(type_int)
	else:
		return type_struct(type_int)

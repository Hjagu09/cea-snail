enum types:
	STRING
	INT
	FLOAT
	BOOL
	FUNC
	UNSET = -1
	NIL = -2

def is_num(type):
	return switch type:
		case INT: true
		case FLOAT: true
		default: false

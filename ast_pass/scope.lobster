import pass
import dictionary
import from ".."
import types

class scope:
	dict = dictionary<string, type_struct>(10) // vet inte vad argumentet gör
	parent: scope?
	def set(key: string, type: type_struct):
		dict.set(key, type)
	def get(key: string) -> type_struct:
		let val_here = dict.get(key, type_struct(UNSET))
		if val_here.type == UNSET:
			guard parent != nil
			return parent.get(key)
		return val_here
	def print_scope() -> void:
		if parent != nil:
			parent.print_scope()
		print("\nSCOPE:")
		print(dict)
		print("--------------------\n")
	def push_scope() -> scope:
		return scope{this}
	def pop_scope() -> scope:
		guard parent:
			return this
		return parent


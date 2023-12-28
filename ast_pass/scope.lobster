import pass
import dictionary
import from ".."
import types

class scope_layer:
	dict = dictionary<string, type_struct>(10) // vet inte vad argumentet gör
	parent: scope_layer?
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

class scope:
	current_scope: scope_layer = scope_layer{nil}
	def print_scope() -> void:
		current_scope.print_scope()
	def push_scope() -> scope:
		current_scope = scope_layer{current_scope}
		return this
	def pop_scope():
		if current_scope.parent:
			current_scope = current_scope.parent
		return this
	def scope(do):
		push_scope()
		do()
		pop_scope()

	def set(key: string, type: type_struct):
		current_scope.set(key, type)
	def get(key: string) -> type_struct:
		return current_scope.get(key)

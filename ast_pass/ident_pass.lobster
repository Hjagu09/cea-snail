import pass
import dictionary
import from ".."
import types

class scope:
	dict = dictionary<string, type_struct>(10) // vet inte vad argumentet gör
	def set(key: string, type: type_struct):
		dict.set(key, type)
	def get(key: string) -> type_struct:
		return dict.get(key, type_struct(UNSET))
	def print_scope():
		print("\nSCOPE:")
		print(dict)
		print("--------------------\n")


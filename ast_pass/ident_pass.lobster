import pass
import dictionary
import from ".."
import types

class scope:
	dict = dictionary<string, int>(10) // vet inte vad argumentet gör
	def set(key: string, type: int):
		dict.set(key, type)
	def get(key: string) -> int:
		return dict.get(key, UNSET)
	def print_scope():
		print("\nSCOPE:")
		print(dict)
		print("--------------------\n")


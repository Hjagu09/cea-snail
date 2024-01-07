namespace pre

def get_stdlib_code() -> string:
	let stdlib_files = scan_folder("./rc/std_lib/")
	guard stdlib_files != nil:
		print("can not find stdlib (./rc/std_lib/)")
		return from program
	
	var stdlib = ""
	for(stdlib_files) file:
		let content = read_file("./rc/std_lib/" + file)
		assert content != nil
		stdlib += content
	return stdlib

def add_stdlib(code: string) -> string:
	return get_stdlib_code() + "\n" + code

def pre_procces(code: string) -> string:
	// just nu finns bara en grej, kanske lägger vi till fler saker och då
	// skulle den här funktionen växa
	return code.add_stdlib()

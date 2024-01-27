
enum_flags log_types:
	PARSER_LOG
	LEXER_LOG
	CODEGEN_LOG
	OTHER_LOG
	INTERNAL_ERROR
	CODE_PASS_LOG

var debug_log = INTERNAL_ERROR
var program_raw = ""

def log(message, type):
	guard debug_log & type != 0
	print(message)


def error(e: string, at: int, size:int, tips:string? = nil) -> void:
	var line_n = 1
	var col = 1
	for(at) i:
		col++
		if program_raw != nil and program_raw[i] == '\n':
			line_n++
			col = 1

	var end_line_n = 1
	var end_col = 1
	for(at + size - 1) i:
		end_col++
		if program_raw != nil and program_raw[i] == '\n':
			end_line_n++
			end_col = 1

	let lines = program_raw.tokenize("\n", "")

	print("\nERROR: {e} at {string(line_n)}:{string(col)} to {string(end_line_n)}:{string(end_col)}")
	
	if end_line_n == line_n:
		if line_n - 1 < lines.length():
			let line = lines[line_n - 1]
			let error_line = "    {string(line_n)}| {line}"
			print(error_line)
			let start_buffer = " ".repeat_string(6 + string(line_n).length())
			let at_buffer = " ".repeat_string(col - 1)
			let arrow_line = "-".repeat_string(size - 1)
			var arrow = "{start_buffer}{at_buffer}^{arrow_line}"
			print("{arrow} here")
	else:
		for(end_line_n - line_n + 1) l:
			let ln = l + line_n
			if ln - 1 < lines.length():
				let line = lines[ln - 1]
				let error_line = "    {string(ln)}| {line}"
				print(error_line)

	if tips:
		print("""


        @             _________
         \____       /         \
         /    \     /    ___    \
         \_    \   /    /        \
  _____//_ \    \ (    (          )
 /i have a\ \    \_\    \___     /
(sugestion ) \      \           /___
 \________/   \______\_________/____\"-_
		""")
		print(tips)
	

	return from program // FIXME

def error(e: string, tips:string? = nil) -> void:
	print("\nERROR: {e}")
	if tips:
		print("""


        @             _________
         \____       /         \
         /    \     /    ___    \
         \_    \   /    /        \
  _____//_ \    \ (    (          )
 /i have a\ \    \_\    \___     /
(sugestion ) \      \           /___
 \________/   \______\_________/____\"-_
		""")
		print(tips)
	

	return from program // FIXME

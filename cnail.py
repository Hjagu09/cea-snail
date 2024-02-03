#!/usr/bin/env python3
import argparse
from pathlib import Path
import subprocess
from shutil import copy

parser = argparse.ArgumentParser(
	prog="c-snail",
	description="a programing language i made :).\
	compiles to c++ and from there to nativ machide code or\
	wasm + html and js glue code (aka a web page). it's inspired\
	by c, henc the name."
)
parser.add_argument(
	"filename",
	help="source file",
	metavar="source-file",
	type=Path
)
parser.add_argument(
	"-t",
	"--target",
	choices=["wasm", "nativ"],
	dest="target",
	default="nativ",
	help="target platform"
)
parser.add_argument(
	"-d",
	"--debug",
	action="store",
	dest="debug",
	default=[],
	choices=["other", "lexer", "parser", "pass", "codegen", "all", "lobster"],
	help="compiler debug options for difrent sub systems",
	nargs="+"
)
parser.add_argument(
	"-o",
	"--output",
	dest="output",
	metavar="file",
	type=Path,
	help="file used for output (directory if you're compiling to wasm)"
)
parser.add_argument(
	"-r",
	"--run",
	dest="run",
	action="store_true",
	default=False,
	help="run the program after compilation with no arguments, if posibile"
)
args = parser.parse_args()

debug = "other" in args.debug or "all" in args.debug
source = args.filename.resolve(True)

output = Path("a.out") if args.output is None else args.output
if args.target == "wasm" and not output.exists():
	output.mkdir()
output = output.resolve()

script = Path(__file__).resolve().parent
compiler = (script / "./main.lobster").resolve()
if debug:
	print(f"c-snail compiler: {compiler}")

output_cpp = (script / "./.build/a.out.cpp").resolve()

lobster_debug = "lobster" in args.debug
argend = ""
for system in ["other", "lexer", "parser", "pass", "codegen"]:
	if system in args.debug:
		argend += "-"
	else:
		argend += "_"
if "all" in args.debug:
	lobster_debug = True
	argend = "-----"

to_cpp = [
	"lobster",
	str(compiler)
]
if lobster_debug:
	to_cpp += [
		"--full-error",
		"--runtime-stack-traces",
		"--runtime-debug"
	]
to_cpp += [
	"--",
	str(source),
	str(output_cpp),
	argend,
	str(script)
]
if debug:
	print(" ".join(to_cpp))
	print("\n-------------------------")

try:
	comp = subprocess.run(to_cpp, capture_output=True, text=True)
	if comp.stdout != "" and comp.stdout is not None:
		print(comp.stdout)
	if comp.stderr != "" and comp.stderr is not None:
		print(comp.stderr)
	if debug:
		print(f"compiler returned {comp.returncode}")
	if comp.returncode != 0:
		if debug:
			print("c++ compiler not invoked")
		exit(-1)

	if args.target == "nativ":
		cmd = [
			"g++",
			str(output_cpp),
			"-o",
			str(output)
		]
		if debug:
			print(" ".join(cmd))
		subprocess.run(cmd)

		if args.run:
			cmd = [str(output)]
			if debug:
				print(" ".join(cmd))
			subprocess.run(cmd)
	if args.target == "wasm":
		cmd = [
			"em++",
			str(output_cpp),
			"--bind",
			"-O3",
			"-sASYNCIFY",
			"-o",
			str(output / "index.js")
		]
		if args.run:
			cmd.append("--emrun")
		if debug:
			print(" ".join(cmd))
		subprocess.run(cmd)
		
		templates = (script / "./web/").resolve()
		copy(templates / "console.js", output / "console.js")
		copy(templates / "console.css", output / "console.css")
		copy(templates / "console.html", output / "index.html")

		if args.run:
			cmd = ["emrun", str(output / "index.html")]
			if debug:
				print(" ".join(cmd))
			subprocess.run(cmd)
			
except KeyboardInterrupt:
	exit(1)

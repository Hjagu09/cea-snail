cea snail
=========

This is my first programing languge. The code is a a complete mess almost without comments
and the comments that exist are writen in 50% swedish and 50% badly spelled english. Also this
project is writen in lobster and the CLI writen in python. **The automatic c++ compilation will
not work under windows**. However, the rest of the project should work so windows users will
just have to compile the generated C++ code by them selfs for now.

There is currently suport for WASM, nativ binarys and what ever you manege to compile the c++ code
to :) To chose what you want to compile to use the `-t` flag. Valid options are `cpp`, `wasm` and
`nativ`. The wasm STD libary is kinda broken (try `notes/exampels/coal.cnail` and you'll see what i
mean).

If you want to get an idea of what this languge is like, take a look att the exampels in `notes/exampels/`. 
The most intersting one is probebly three in a row. There is also the (mabey up to date) gramar
for the languge in `notes/gramar.txt`. cea snail is wery much inspierd by lobster. The only (mabey)
intresting feture is that there are no statment terminators, neither semi colons or line breaks.
This is probebly going to become a problem some time soon but for now you can write code like this:
```cnail
let a = 10 for(0, a | n: int → nil) { print_int(n) }
```
The only trade of i have had to make for this so far is the weird lambda syntax seen in the for
loop above. Writen out properly that code would become:
```cnail
let a = 10
for(0, a | n: int → nil) {
	print_int(n)
}
```


Why you should not use this languge
-----------------------------------

- it was made by a teen who dosen't know what he's doing
- this is my first *ever* programing languge, it barely works at all
- almost all error messages are weird and unhelpful


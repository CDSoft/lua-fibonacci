all: fib.pdf

%.pdf: %.typ fib.lua
	ypp -l fib $< -o $<.tmp
	typst compile $<.tmp $@
	rm $<.tmp

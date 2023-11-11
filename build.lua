var "builddir" ".build"

local pdf = pipe {
    rule "ypp.typ"   { command = "ypp -l fib $in -o $out", implicit_in = "fib.lua" },
    rule "typst.pdf" { command = "typst compile $in $out" },
}

pdf "fib.pdf" { "fib.typ" }

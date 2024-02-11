var "builddir" ".build"

local pdf = pipe {
    rule "ypp.typ"   { command = "ypp -l fib --MF $depfile $in -o $out", depfile = "$builddir/$out.d" },
    rule "typst.pdf" { command = "typst compile $in $out" },
}

pdf "fib.pdf" { "fib.typ" }

var "builddir" ".build"

local pdf = pipe {
    build.ypp:new "ypp.typ" : add "flags" "-l fib" : set "depfile" "$builddir/$out.d",
    build.typst,
}

pdf "fib.pdf" { "fib.typ" }

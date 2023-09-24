var "builddir" ".build"

rule "ypp" {
    command = "ypp -l fib $in -o $out",
    implicit_in = "fib.lua",
}

rule "typst" {
    command = "typst compile $in $out",
}

build "fib.pdf" {
    "typst",
    build "$builddir/fib.typ" { "ypp", "fib.typ" },
}

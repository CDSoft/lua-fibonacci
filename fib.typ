@comment [===[
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]===]

#set document(
  title: "Fibonacci",
  author: "Christophe Delord",
)

#set page(
  paper: "a4",
  header: align(right)[Fibonacci sequence],
  numbering: "1",
)

#set par(justify: true)

#set text(
  font: "Linux Libertine",
  size: 11pt,
)

#align(center, text(17pt)[
  *Fibonacci sequence*
])
#grid(
  columns: (1fr),
  align(center)[
    Christophe Delord \
    #link("http://cdelord.fr") \
    #link("https://github.com/CDSoft/lua-fibonacci") \
  ]
)

#align(center)[
  #set par(justify: false)
  *Abstract* \
  The Fibonacci sequence is a famous numerical sequence used to test algorithm performances.
  This paper briefly defines the Fibonacci sequence and compares some implementations.
  The Fibonacci sequence is here just a pretext to test
  #link("http://cdelord.fr/ypp", "ypp") and #link("https://typst.app", "typst").
]

= Fibonacci sequence

#grid(
  columns: (1fr, 1.2fr),
  gutter: 1em,
  [ The Fibonacci sequence is defined as:

    $ F_0 &= 1 \
      F_1 &= 1 \
      F_n &= F_(n-1) + F_(n-2) \
    $

    We will compare here some implementations in Lua.
  ],
  [ #table(
      columns: (auto, auto, auto),
      align: horizon,
      [$n$], [$F_n$], [Details],
      @F.range(0, 5):map(example)
    )
  ]
)

= Naive implementation

#grid(
  columns: (1fr, 1.2fr),
  gutter: 1em,
  [ ```lua
    function fib(n)
      if n <= 1 then return 1 end
      return fib(n-1) + fib(n-2)
    end
    ```

    The naive implementation involes a lot of additions and is rather inefficient.

    $F_n$ requires $F_n-1$ additions
    (i.e. $cal(O)(F_n) = F_n$, which is pretty inefficient since $F_n ~ 1/sqrt(5)((1+sqrt(5))/2)^n$).
  ],
  [ #table(
      columns: (auto, auto, auto, auto),
      align: horizon,
      [$n$], [$F_n$], [Additions], [Multiplications],
      @F.range(10, 50, 10):map(perf_naive)
    )
  ]
)


= Linear implementation

#grid(
  columns: (1fr, 1.2fr),
  gutter: 1em,
  [ The naive implementation computes the same Fibonacci values several times.
    Memoization dramatically improves performances.

    ```lua
    local fibs = {}
    function fib(n)
      if n <= 1 then return 1 end
      local f = fibs[n]
      if f then return f end
      f = fib(n-1) + fib(n-2)
      fibs[n] = f
      return f
    end
    ```

    $F_n$ requires $n-1$ additions (i.e. $cal(O)(F_n) = n$).
  ],
  [ #table(
      columns: (auto, auto, auto, auto),
      align: horizon,
      [$n$], [memoized $F_n$], [Additions], [Multiplications],
      @F.range(10, 50, 10):map(perf_memo)
      @F.range(100, 500, 100):map(perf_memo)
    )
  ]
)


= Faster implementation

The properties of the Fibonacci sequence can be exploited to improve performences.

Let’s try to apply the definition several times to compute several steps at once:

$
F_n &= F_(n-1)                &+ F_(n-2) \
    &= F_(n-2) + F_(n-3)      &+ F_(n-2) \
    &= 2 F_(n-2)              &+ F_(n-3) \
    &= 2 (F_(n-3) + F_(n-4))  &+ F_(n-3) \
    &= 3 F_(n-3)              &+ 2 F_(n-4) \
    &= 3 (F_(n-4) + F_(n-5))  &+ 2 F_(n-4) \
    &= 5 F_(n-4)              &+ 3 F_(n-5) \
    &= ...
$

The coefficients seem to be Fibonacci numbers as well.

Let’s prove by induction (over $k$) that:

$ F_n = F_k F_(n-k) + F_(k-1) F_(n-k-1) $

The property is obviously true for $k = 1$:

$
F_n &= F_1 F_(n-1) &+ F_(1-1) F_(n-1-1) \
    &= F_1 F_(n-1) &+ F_0     F_(n-2  ) \
    &= 1   F_(n-1) &+ 1       F_(n-2  ) \
    &=     F_(n-1) &+         F_(n-2  ) \
$

Lets prove that
$F_n = F_k F_(n-k) + F_(k-1) F_(n-k-1) ==> F_n = F_(k+1) F_(n-k-1) + F_k F_(n-k-2)$.

$
F_(k+1) F_(n-k-1) + F_k F_(n-k-2) &= (F_k + F_(k-1)) F_(n-k-1) + F_k F_(n-k-2) \
                                  &= F_k (F_(n-k-1) + F_(n-k-2)) + F_(k-1) F_(n-k-1) \
                                  &= F_k F_(n-k) + F_(k-1) F_(n-k-1) \
$

The Fibonacci sequence can then be defined by:

$
F_0 &= 1 \
F_1 &= 1 \
F_n &= F_k F_(n-k) + F_(k-1) F_(n-k-1), forall n >= 2, forall k in [1, n-1] \
$

The trivial implementation is slow because of the double recursivity. We now have four recursions but:

1. The call tree is reduced by _jumping_ from $n$ to $n-k$ instead of just $n-1$
2. By choosing $k$ wisely some redundant computations can be avoided

Intuitively if $k$ is close to $n-k$ then subtrees will be close too.
If $k = n-k$ (i.e. $k = n/2$) then the first term of $F_n$ is a square ($F_k = F_(n-k)$).

*First case*: $n$ is even ($n = 2k$)

$
F_n &= F_k F_(n-k) &+ F_(k-1) F_(n-k-1) \
    &= F_k F_k     &+ F_(k-1) F_(k-1) &, (n-k-1 = 2k-k-1 = k-1) \
    &= F_k^2       &+ F_(k-1)^2 \
$

*Second case*: $n$ is odd ($n = 2k+1$)

$
F_n &= F_k F_(n-k) &+ F_(k-1) F_(n-k-1) \
    &= F_k F_(k+1) &+ F_(k-1) F_(n-k-1) &, (n-k = 2k+1-k = k+1) \
    &= F_k F_(k+1) &+ F_(k-1) F_(k) &, (n-k-1 = k) \
    &= F_k (F_k + F_(k-1)) &+ F_(k-1) F_(k) \
    &= F_k^2 + 2 F_k F_(k-1) \
    &= F_k (F_k + 2 F_(k-1)) \
$

#grid(
  columns: (1fr, 1.2fr),
  gutter: 1em,
  [ This definition can be easily implemented in Lua:

    ```lua
    function fast_fib(n)
      if n <= 1 then return 1 end
      local r = n & 1
      local k = n >> 1
      local fk = fast_fib(k)
      local fk1 = fast_fib(k-1)
      if r == 0 then
        return fk*fk + fk1*fk1
      else
        return fk*(fk + 2*fk1)
      end
    end
    ```

  This is not as fast as the memoized naive version. Memoization should help.
  ],
  [ #table(
      columns: (auto, auto, auto, auto),
      align: horizon,
      [$n$], [fast $F_n$], [Additions], [Multiplications],
      @F.range(10, 50, 10):map(perf_fast)
      @F.range(100, 500, 100):map(perf_fast)
      @perf_fast(1000)
    )
  ]
)

#grid(
  columns: (1fr, 1.2fr),
  gutter: 1em,
  [ Same algorithm with memoization:

    ```lua
    local fibs = {}
    function fast_fib(n)
        if n <= 1 then return 1 end
        local f = fibs[n]
        if f then return f end
        local r = n & 1
        local k = n >> 1
        local fk = fast_fib(k)
        local fk1 = fast_fib(k-1)
        local f
        if r == 0 then
          f = fk*fk + fk1*fk1
        else
          f = fk*(fk + 2*fk1)
        end
        fibs[n] = f
        return f
    end
    ```
  ],
  [ #table(
      columns: (auto, auto, auto, auto),
      align: horizon,
      [$n$], [memoized fast $F_n$], [Additions], [Multiplications],
      @F.range(10, 50, 10):map(perf_memo_fast)
      @F.range(100, 500, 100):map(perf_memo_fast)
      @F.range(1000, 5000, 1000):map(perf_memo_fast)
      @perf_memo_fast(10000)
      @perf_memo_fast(100000)
    )
  ]
)

@@[[
  N = 10*1000
  f = tostring(memo_fast_fib(N):unpack())
]]

= $F_@N$

$F_@N$ contains $@(#f)$ digits.

$F_@N = $ @@[===[
  local ds = F{}
  tostring(f)
    : reverse()
    : gsub("..?.?", function(d) ds[#ds+1] = d end)
  return ds
    : reverse()
    : map(string.reverse)
    : unwords()
]===]

= References

#let ref(description, name:"", url:"") = [
  == *#name*

  #description

  see: #link(url)
]

#ref(name:"ypp - Yet another PreProcessor", url:"http://cdelord.fr/ypp")[
  `ypp` is yet another preprocessor. It’s an attempt to merge
  #link("http://cdelord.fr/upp", "upp") and
  #link("http://cdelord.fr/panda", "Panda").
  It acts as a generic text preprocessor as upp and comes with macros reimplementing most of the Panda functionalities
  (i.e. Panda facilities not restricted to #link("https://pandoc.org", "Pandoc") but also
  available to softwares like #link("https://typst.app/", "Typst")).

  Ypp is a minimalist and generic text preprocessor using Lua macros.

  It provides several interesting features:

  - full Lua interpreter
  - variable expansion (minimalistic templating)
  - conditional blocks
  - file inclusion (e.g. for source code examples)
  - script execution (e.g. to include the result of a command)
  - diagrams (Graphviz, PlantUML, Asymptote, blockdiag, mermaid, Octave, ...)
  - documentation extraction (e.g. from comments in source files)
]

#ref(name:"Typst", url:"https://typst.app")[
  Typst is a new markup-based typesetting system for the sciences.
  It is designed to be an alternative both to advanced tools like LaTeX and simpler tools like Word and Google Docs.
  The goal with Typst is to build a typesetting tool that is highly capable and a pleasure to use.
]

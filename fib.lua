--[[
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
--]]

local one = imath.new(1)

function naive_fib(n)
    if n <= 1 then return F{one, 0, 0} end
    local f1, a1, m1 = naive_fib(n-1):unpack()
    local f2, a2, m2 = naive_fib(n-2):unpack()
    return F{f1+f2, a1+a2+1, m1+m2}
end

naive_fib = F.memo1(naive_fib) -- just cheat a little bit...

function sfib(n)
    if n <= 1 then return ("F_%d = %d"):format(n, 1) end
    local a, b = naive_fib(n-1):head(), naive_fib(n-2):head()
    return ("F_%d = F_%d + F_%d = %s + %s = %s"):format(n, n-1, n-2, tostring(a), tostring(b), tostring(a+b))
end

function example(i)
    return F.unwords{
      "[$"..i.."$],",
      "[$"..tostring(naive_fib(i):head()).."$],",
      "[$"..sfib(i).."$],",
    }
end

local big = imath.new(10)^12

function p(n)
    if n < big then return n end
    local s = tostring(n)
    local k = (#s-1)//3
    local e = 3*k
    return ("%s.10^%d"):format(s:sub(1, #s-e), e)
end

local fibs = {}

function perf(func, i)
    fibs = {}
    local f, a, m = func(i):unpack()
    return F.unwords{
      "[$"..i.."$],",
      "[$"..tostring(p(f)).."$],",
      "[$"..(a>0 and a or "").."$],",
      "[$"..(m>0 and m or "").."$],",
    }
end

perf_naive = F.partial(perf, naive_fib)

function memo_fib(n)
    if n <= 1 then return F{one, 0, 0} end
    local f = fibs[n]
    if f then return F{f, 0, 0} end
    local f1, a1, m1 = memo_fib(n-1):unpack()
    local f2, a2, m2 = memo_fib(n-2):unpack()
    f = f1+f2
    fibs[n] = f
    return F{f, a1+a2+1, m1+m2}
end

perf_memo = F.partial(perf, memo_fib)

function fast_fib(n)
    if n <= 1 then return F{one, 0, 0} end
    local k, r = F.div_mod(n, 2)
    local fk, a1, m1 = fast_fib(k):unpack()
    local fk1, a2, m2 = fast_fib(k-1):unpack()
    if r == 0 then
        return F{fk*fk + fk1*fk1, a1+a2+1, m1+m2+2}
    else
        return F{fk*(fk + 2*fk1), a1+a2+1, m1+m2+2}
    end
end

perf_fast = F.partial(perf, fast_fib)

function memo_fast_fib(n)
    if n <= 1 then return F{one, 0, 0} end
    --if n <= 80 then return memo_fib(n) end
    local f = fibs[n]
    if f then return F{f, 0, 0} end
    local k, r = F.div_mod(n, 2)
    local fk, a1, m1 = memo_fast_fib(k):unpack()
    local fk1, a2, m2 = memo_fast_fib(k-1):unpack()
    if r == 0 then
        f = fk*fk + fk1*fk1
        fibs[n] = f
        return F{f, a1+a2+1, m1+m2+2}
    else
        f = fk*(fk+2*fk1)
        fibs[n] = f
        return F{f, a1+a2+1, m1+m2+2}
    end
end

perf_memo_fast = F.partial(perf, memo_fast_fib)

# FastRationals.jl

### rationals with unreal performance <sup>[𝓪](#source)</sup>

##### Copyright © 2017-2019 by Jeffrey Sarnoff. This work is released under The MIT License.
----

```
using FastRationals, Polynomials
using BenchmarkTools

w,x,y,z = 1//121, -2//877, 3//454, -4//171; q = 1//87
poly = Poly([w,x,y,z])

a,b,c,d = FastRational.([w,x,y,z]); p = FastRational(q)
fastpoly = Poly([a,b,c,d])

polyval(poly, q) == polyval(fastpoly, p)
# true

floor((@belapsed polyval($poly, $q)) / (@belapsed polyval($fastpoly, $p)))
# 14.0
```

```
x, y, z = 1234//3451, 345//78912, 987//53
a, b, c = FastRational.([x, y, z])

function test(x,y,z)
   a = x + y
   b = x * y
   c = z - b
   d = a / c
   return d
end

test(x,y,z) == test(a,b,c)
# true

floor( (@belapsed test(Ref($x)[],Ref($y)[],Ref($z)[])) / 
       (@belapsed test(Ref($a)[],Ref($b)[],Ref($c)[])))
# 14.0
```

Arithmetic works like `Rational` for eltypes `Int8, .., Int128, UInt8, ..` except there is no Infinity, no NaN comparisons.

----

<sup><a name="source">[𝓪](#attribution)</a></sup> Harmon Stopples on 2019-06-14

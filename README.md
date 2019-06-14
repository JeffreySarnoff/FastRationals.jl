# FastRationals.jl
rational numbers with performant arithmetic

```
using FastRationals, Polynomials
using BenchmarkTools

w,x,y,z = 1//121, -2//877, 3//454, -4//171; q = 1//87
poly = Poly([w,x,y,z])

a,b,c,d = FastRational.([w,x,y,z]); p = FastRational(q)
fastpoly = Poly([a,b,c,d])

floor((@belapsed polyval($poly, $q)) / (@belapsed polyval($fastpoly, $r)))
# 17.0
```

```
x, y, z = 12345//34512, 345//789123, 9876//53
a, b, c = FastRational.(x, y, z)

function test(x,y,z)
   a = x + y
   b = x * y
   c = z - b
   d = a / c
   return d
 end

floor( (@belapsed test(Ref($x)[],Ref($y)[],Ref($z)[])) / 
       (@belapsed test(Ref($a)[],Ref($b)[],Ref($c)[])))
# 20.0
```

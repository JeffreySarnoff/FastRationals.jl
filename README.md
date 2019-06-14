# FastRationals.jl
rational numbers with performant arithmetic

```
using FastRationals, Polynomials
using BenchmarkTools

w,x,y,z = 1//121, -2//877, 3//454, -4//171
q = 1//87
ply = Poly([w,x,y,z])
a,,b,c,d = FastRational.([w,x,y,z])
r = FaatRational(q)
fastply = Poly([a,b,c,d])

@btime polyval(ply, $q)
  539.474 ns (0 allocations: 0 bytes)
44696529964877//5424936821574534

@btime polyval($fastply, $r)
  30.684 ns (0 allocations: 0 bytes)
44696529964877//5424936821574534

floor(@belapsed polyval(ply, $q))) / (@belapsed polyval(fastply, $r)))
12.0
```

##  __I am busy breaking, fixing, testing, and refining (June 17th--23rd)__

>  (  This will become available for use in concert with its announcement on Discourse.  )
>
> _please know that your interest and attentiveness are matters of moment and import_    

----
----

# FastRationals.jl

----

### rationals with unreal performance <sup>[𝓪](#source)</sup>

##### Copyright © 2017-2019 by Jeffrey Sarnoff. This work is released under The MIT License.
----

### using FastRationals


`FastRationals` exports two types: `FastQ32`, `FastQ64`, corresponding to `Rational{Int32}` and `Rational{Int64}`, respectively.
FastRationals are intended for use with _smaller_ rational values.  

The _multiplicative magnitude_ of a rational number is given by `multmag(q::Rational{T}) where {T} = max(abs(q.num), abs(q.den))` (the second `abs` is there for completeness).  From that, we obtain the _significant magnitude_ as `sigmag(q::Rational{T}) where {T} = bitsof(T) - leading_zeros(multmag(q))` where `bitsof(x::T) = sizeof(T) * 8`. 

```julia
using FastRationals

```

### performance relative to system Rationals


With smaller rationals, arithmetic sequences run about 12x..16x faster.
With smaller rationals, matrix operations run about 2x..6x faster.

|  _small rationals_ |  Relative Speedup |
|:------------------------|:-----------------:|
|      mul/div            |       20          |
|      polyval            |       18          |
|      add/sub            |       15          |
|      4x4 matrix         |                   |
|      mul                |       10          |
|      lu                 |        5          | 
|      inv                |        3          |

----

### Benchmarking

```
using FastRationals, Polynomials, BenchmarkTools

w,x,y,z = Rational{Int32}.([1//12, -2//77, 3//54, -4//17]); q = Rational{Int32}(1//7);
a,b,c,d = FastRational.((w,x,y,z)); p = FastRational(q);

poly = Poly([w,x,y,z])
fastpoly = Poly([a,b,c,d])

polyval(poly, q) == polyval(fastpoly, p)
# true

relative_speedup =
    floor((@belapsed polyval($poly, $q)) / (@belapsed polyval($fastpoly, $p)))

# relative_speedup is ~16
```

```
using FastRationals, BenchmarkTools

x, y, z = Rational{Int32}.((1234//345, 345//789, 987//53))
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

relative_speedup =
    floor( (@belapsed test(Ref($x)[],Ref($y)[],Ref($z)[])) / 
           (@belapsed test(Ref($a)[],Ref($b)[],Ref($c)[])))

# relative_speedup is ~4
```

Arithmetic works like `Rational` for eltypes `Int8, .., Int128, UInt8, ..` except there is no Infinity, no NaN comparisons.

----

<sup><a name="source">[𝓪](#attribution)</a></sup> Harmen Stoppels on 2019-06-14

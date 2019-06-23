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

## using FastRationals

- __FastRationals__ exports types `FastRational{Int32} (FastQ32)` and `FastRational{Int64} (FastQ64)`.
- Arithmetic is 12x..16x faster and matrix ops are 2x..6x faster when using appropriately ranged values.


__FastRationals__ are intended for use with _smaller_ rational values.  To compare two rationals or to calculate the sum, difference, product, or ratio of two rationals requires pairwise multiplication of the constituents of one by the constituents of the other.  Whether or not it overflow depends on the number of leading zeros (`leading_zeros`) in the binary representation of the absolute value of the numerator and the denominator given with each rational.  

Of the numerator and denominator, we really want whichever is the larger in magnitude from each value used in an arithmetic op. These values determine whether or not their product may be formed without overflow. That is important to know. It is alright to work as though there is a possiblity of overflow where in fact no overflow will occur.  It is not alright to work as though there is no possiblity of overflow where in fact overflow will occur.  In the first instance, some unnecessary yet unharmful effort is extended.  In the second instance, an overflow error stops the computation.

##### `mayoverflow(rational, rational)`

```julia
bitsof(::Type{T}) where {T} = sizeof(T) * 8

maxmag(q::Rational{T}) where {T} = max(abs(q.num), abs(q.den))  # q.den != typemin(T)
magzeros(q::Rational{T}) where {T} = leading_zeros(maxmag(q))
maxbits(q::Rational{T}) where {T} = bitsof(T) - leading_zeros(maxmag(q))
maxbits(q1::Rational{T}, q2::Rational{T}) where {T} = maxbits(q1) + maxbits(q2)

mayoverflow(q1::Rational{T}, q2::Rational{T}) where {T} = bitsof(T) <= maxbits(q1, q2)
mayoverflow(q1::Rational{T}, q2::Rational{T}) where {T} = bitsof(T) >= magzeros(q1) + magzeros(q2)
```

### working with rational ranges

__FastRationals__ are at their most performant where overflow is absent or uncommon.  And vice versa: where overflow happens frequently, FastRationals have no intrinsic advantage.  How do we know what range of rational values are desireable?  We want to work with rational values that, for the most part, do not overflow when added, subtracted, multiplied or divided.  As rational calculation tends to grow numerator aor denominator magnitudes, it makes sense to further constrain the working range.  These tables are of some guidance. 

----

|   FastQ32   |  range      | refinement  |
|-------------|-------------|-------------|
|             |             |             |
| sweet spot  |    ±215//1  |  ±1//215    |
|             |             |             |
| preferable  |    ±255//1  |  ±1//255    |
|             |             |             |
| workable    |  ±1_023//1  |  ±1//1_023  |
|             |             |             |
| testable    | ±4_095//1   |  ±1//4_095  |
|             |             |             |

----

|   FastQ64   |  range         | refinement     |
|-------------|----------------|----------------|
|             |                |                |
| sweet spot  |    ±55_108//1  |  ±1//55_108    |
|             |                |                |
| preferable  |    ±65_535//1  |  ±1//65_535    |
|             |                |                |
| workable    |  ±262_143//1   |  ±1//262_143   |
|             |                |                |
| testable    | ±1_048_575//1  | ±1//1_048_575  |
|             |                |                |

----

The calculation of these magnitudes appears [here]( https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/docs/src/thestatelessway.md#quantifying-the-desireable).

----

## performance relative to system rationals

#### actual results

The code that generates these results is available in the `benchmarks` directory, run this file:
[relative_speedup.jl](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/benchmarks/relative_speedup.jl).
You are welcome to submit a PR with the results of your benchmarking.  There is a file dedicated to this:
[results.md](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/benchmarks/results.md).


|    computation          |  Relative Speedup |
|:------------------------|:-----------------:|
|      mul/div            |       20          |
|      polyval            |       18          |
|      add/sub            |       15          |
|                         |                   |
|      mat mul            |       10          |
|      mat lu             |        5          |
|      mat inv            |        3          |

- polynomial deg is 4
- matrix size is 4x4
----

### what is not carried over from system rationals 

- There is no `FastRational` representation for Infinity
- There is no support for comparing a `FastRational` with NaN

- _reserved for unintentional omissions_

### what fast rationals do beyond system rationals

#### enhanced rounding

`FastRationals` support two kinds of directed rounding, one maintains type, the other yields an integer.
- all rounding modes are available
    - `RoundNearest`, `RoundUp`, `RoundDown`, `RoundToZero`, `RoundFromZero`
```
> q = FastQ32(22, 7)
(3//1, 3//1)

> round(q), round(q, RoundNearest), round(-q), round(-q, RoundNearest)
(3//1, 3//1, -3//1, -3//1)

> round(q, RoundToZero), round(q, RoundFromZero), round(-q, RoundToZero), round(-q, RoundFromZero)
(3//1, 4//1, -3//1, -4//1)

> round(q, RoundDown), round(q, RoundUp), round(-q, RoundDown), round(-q, RoundUp)
(3//1, 4//1, -4//1, -3//1)


> round(Integer, q, RoundUp), typeof(round(Integer, q, RoundUp))
4, Int32

> round(Int16, -q, RoundUp), typeof(round(Int16, -q, RoundUp))
-3, Int16
```

----

### references

This work stems from a [discussion](https://github.com/JuliaLang/julia/issues/11522) that began in 2015.

----

<sup><a name="source">[𝓪](#attribution)</a></sup> Harmen Stoppels on 2019-06-14

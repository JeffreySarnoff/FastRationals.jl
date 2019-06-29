# FastRationals.jl

----

### rationals with unreal performance <sup>[𝓪](#source)</sup>

##### Copyright © 2017-2019 by Jeffrey Sarnoff. This work is released under The MIT License.
----
[![Build Status](https://travis-ci.org/JeffreySarnoff/FastRationals.jl.svg?branch=master)](https://travis-ci.org/JeffreySarnoff/FastRationals.jl)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[![codecov](https://codecov.io/gh/JeffreySarnoff/FastRationals.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JeffreySarnoff/FastRationals.jl)

----
## Rationals using BigInt

##### what works well

The first column holds the number of random Rational{Int128}s used    
to generate the random `Rational{BigInt}` values that were processed.

----

| n rand Rationals   | ~denom digits | `sum` relspeed | `prod` relspeed |
|:------------------:|:-------------:|:------------:|:-------------:| 
|200                 | 7_150         |  200         | 360           |
|500                 | 17_700        |  340         | 600           |


| n rand Rationals   | matmul relspeed | `tr` relspeed |
|:------------------:|:---------------:|:-------------:| 
| 64 (8x8)           |  40             |      20       |
| 225 (15x15)        |  50             |      45       |

----

##### what does not work well

However, other matrix functions (`det`, `lu`, `inv`) take way too long at this size.
- insight into the remedy is welcome

----

The Bailey–Borwein–Plouffe formula (BBP formula) is a formula for π
```
const big1 = BigInt(1)
const big2 = BigInt(2)
const big4 = BigInt(4)
const big5 = BigInt(5)
const big6 = BigInt(6)
const big8 = BigInt(8)
const big16 = BigInt(16)

function bpp(::Type{T}, n) where {T}
    result = zero(T)
    for k = 0:n
       eightk = big8 * k
       cur = T(big4,eightk+1) -
             T(big2,eightk+4) -
             T(big1,eightk+5) -
             T(big1,eightk+6)
       cur = T(big1, big16^k) * cur
       result = result + cur
    end
    return result
end

# err ~1e-28, 403 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},20);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},20);
julia> floor(Int,systemqtime/fastqtime)
3.9

# err ~1e-54, 1_328 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},40);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},40);
julia> floor(Int,systemqtime/fastqtime)
4.5

# err ~1e-102, 4_671 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},80);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},80);
julia> round(systemqtime/fastqtime, digits=2)
4.8

# err ~1e247, 26_431 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},200);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},200);
julia> floor(Int,systemqtime/fastqtime)
2.5

# err ~1e368, 57_914 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},300);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},300);
julia> floor(Int,systemqtime/fastqtime)
1.25

# err ~1e402, 68_889 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},328);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},328);
julia> floor(Int,systemqtime/fastqtime)
0.99

# err ~1e610, 157_166 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},500);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},500);
julia> floor(Int,systemqtime/fastqtime)
0.5
```

----

## using FastRationals

- __FastRationals__ exports types `FastRational{Int32} (FastQ32)` and `FastRational{Int64} (FastQ64)`.
- Arithmetic is 12x..16x faster and matrix ops are 2x..6x faster when using appropriately ranged values.


__FastRationals__ are intended for use with _smaller_ rational values.  To compare two rationals or to calculate the sum, difference, product, or ratio of two rationals requires pairwise multiplication of the constituents of one by the constituents of the other.  Whether or not it overflow depends on the number of leading zeros (`leading_zeros`) in the binary representation of the absolute value of the numerator and the denominator given with each rational.  

Of the numerator and denominator, we really want whichever is the larger in magnitude from each value used in an arithmetic op. These values determine whether or not their product may be formed without overflow. That is important to know. It is alright to work as though there is a possiblity of overflow where in fact no overflow will occur.  It is not alright to work as though there is no possiblity of overflow where in fact overflow will occur.  In the first instance, some unnecessary yet unharmful effort is extended.  In the second instance, an overflow error stops the computation.

### working with rational ranges

__FastRationals__ are at their most performant where overflow is absent or uncommon.  And vice versa: where overflow happens frequently, FastRationals have no intrinsic advantage.  How do we know what range of rational values are desireable?  We want to work with rational values that, for the most part, do not overflow when added, subtracted, multiplied or divided.  As rational calculation tends to grow numerator aor denominator magnitudes, it makes sense to further constrain the working range.  These tables are of some guidance. 

----

|   FastQ32   |  range      | refinement  | lead 0 bits |
|-------------|-------------|-------------|:-----------:|
|             |             |             |             |
| sweet spot  |    ±215//1  |  ±1//215    |    24       |
|             |             |             |             |
| preferable  |    ±255//1  |  ±1//255    |    24       |
|             |             |             |             |
| workable    |  ±1_023//1  |  ±1//1_023  |    22       |
|             |             |             |             |
| admissible  | ±4_095//1   |  ±1//4_095  |    20       |
|             |             |             |             |

----

|   FastQ64   |  range         | refinement     | lead 0 bits |
|-------------|----------------|----------------|:-----------:|
|             |                |                |             |
| sweet spot  |    ±55_108//1  |  ±1//55_108    |     48      |
|             |                |                |             |
| preferable  |    ±65_535//1  |  ±1//65_535    |     48      |
|             |                |                |             |
| workable    |  ±262_143//1   |  ±1//262_143   |     46      |
|             |                |                |             |
| admissable  | ±1_048_575//1  | ±1//1_048_575  |     44      |
|             |                |                |             |

----

The calculation of these magnitudes appears [here]( https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/docs/src/thestatelessway.md#quantifying-the-desireable).

----

## performance relative to system rationals

#### actual results


|    computation          |  Relative Speedup |
|:------------------------|:-----------------:|
|      mul/div            |       20          |
|      polyval            |       18          |
|      add/sub            |       15          |
|                         |                   |
|      mat mul            |       10          |
|      mat lu             |        5          |
|      mat inv            |        3          |

- polynomial degree is 4, matrix size is 4x4
----

- This timing harness provided the [relative speedups](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/benchmarks/relative_speedup.jl).

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


## more about it

> [Context Rather Than State](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/docs/src/thestatelessway.md)

> [what slows FastRationals](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/docs/src/metaphoricalflashlight.md)

> [the `mayoverflow` predicate](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/docs/src/mayoverflow.md)

----

### references

This work stems from a [discussion](https://github.com/JuliaLang/julia/issues/11522) that began in 2015.

----

<sup><a name="source">[𝓪](#attribution)</a></sup> Harmen Stoppels on 2019-06-14

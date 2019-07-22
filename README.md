# FastRationals.jl

### rationals with unreal performance <sup>[𝓪](#source)</sup>

##### Copyright © 2017-2019 by Jeffrey Sarnoff. This work is released under The MIT License.
----
[![Build Status](https://travis-ci.org/JeffreySarnoff/FastRationals.jl.svg?branch=master)](https://travis-ci.org/JeffreySarnoff/FastRationals.jl)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[![codecov](https://codecov.io/gh/JeffreySarnoff/FastRationals.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JeffreySarnoff/FastRationals.jl)

----

#### `FastRationals`

- [`FastRational{Int64}`](https://github.com/JeffreySarnoff/FastRationals.jl#fastrationals-using-fast-integers)
   - [performance relative to system rationals](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/README.md#performance-relative-to-system-rationals)

- [`FastRational{BigInt}`](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/README.md#rationals-using-bigint)
   - [what works well](https://github.com/JeffreySarnoff/FastRationals.jl#what-works-well)
   - [what does not](https://github.com/JeffreySarnoff/FastRationals.jl#what-does-not-work-well)

#### additional functionality
- [rational compactification](https://github.com/JeffreySarnoff/FastRationals.jl#rational-compactification)
- [enhanced rounding](https://github.com/JeffreySarnoff/FastRationals.jl#enhanced-rounding)

----

## FastRational types

System rationals reduce the result of every rational input and each arithmetic operation to lowest terms.  FastRational types (`FastQ32`, `FastQ64`, `FastQBig`) reduce all rational inputs and reduce each rational value prior to presenting the value. Unlike system rationals, the result of a FastRational arithmetic operation is reduced only if overflow occur while it is being calculated.  With appropriately sized numerators and denominators, this takes less time. 

### FastRationals using fast integers

- These types use fast integers : `FastRational{Int32} (FastQ32)` and `FastRational{Int64} (FastQ64)`.
- Arithmetic is 12x..16x faster and matrix ops are 2x..6x faster when using appropriately ranged values.


These `FastRational` types are intended for use with _smaller_ rational values.  To compare two rationals or to calculate the sum, difference, product, or ratio of two rationals requires pairwise multiplication of the constituents of one by the constituents of the other.  Whether or not it overflow depends on the number of leading zeros (`leading_zeros`) in the binary representation of the absolute value of the numerator and the denominator given with each rational.  

Of the numerator and denominator, we really want whichever is the larger in magnitude from each value used in an arithmetic op. These values determine whether or not their product may be formed without overflow. That is important to know. It is alright to work as though there is a possiblity of overflow where in fact no overflow will occur.  It is not alright to work as though there is no possiblity of overflow where in fact overflow will occur.  In the first instance, some unnecessary yet unharmful effort is extended.  In the second instance, an overflow error stops the computation.

### FastRationals using large integers

- __FastRationals__ exports types `FastRational{Int128} (FastQ128)` and `FastRational{BigInt} (FastQBig)`.

    - `FastQ128` is 1.25x..2x faster than `Rational{Int128}` when using appropriately ranged values.

    - `FastQBig` with large rationals speeds arithmetic by 25x..250x, and excels at `sum` and `prod`.
    - `FastQBig` is best with numerators and denominators that have no more than 25_000 decimal digits.


## performance relative to system rationals


|    computation          | avg rel speedup |
|:------------------------|:-----------------:|
|      mul/div            |       20          |
|      polyval            |       18          |
|      add/sub            |       15          |
|                         |                   |
|      mat mul            |       10          |
|      mat lu             |        5          |
|      mat inv            |        3          |

- avg is of FastQ32 and FastQ64
- polynomial degree is 4, matrix size is 4x4

- This script provided the [relative speedups](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/benchmarks/relspeed_Q32_Q64.jl).

----
## Rationals using BigInt


#### 25_000 decimal digits

Up to 25_000 digits, FastRational{BigInt}s `FastQBigInt` handily outperform `Rational{BigInt}`s in arithmetic calculation.
When applied to appropriate computations, `FastQBigInt`s often run 2x-5x faster. These speedups were obtained evaluating
[The Bailey–Borwein–Plouffe formula for π](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/benchmarks/BBP_for_pi.jl)
at various depths (number of iterations) using `Rational{BigInt}` and `FastRational{BigInt}`. 

----

#### what works well

The first column holds the number of random Rational{Int128}s used    
to generate the random `Rational{BigInt}` values that were processed.

These relative performance numbers are throughput multipliers.    
In the time it takes to square an 8x8 Rational{BigInt} matrix,    
__thirty__ 8x8 FastRational{BigInt} matrices may be squared.    

- `sum` and `prod` 

|  n rationals       | `sum` relspeed | `prod` relspeed |
|:------------------:|:--------------:|:---------------:| 
|  200               |    100         | 200             |
|  500               |    200         | 350             |


- matrix multiply and trace

| n rationals        | `mul` relspeed  | `tr` relspeed |
|:------------------:|:---------------:|:-------------:| 
| 64 (8x8)           |  15             |      10       |
| 225 (15x15)        |  20             |      15       |

This script provided the [relative speedups](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/benchmarks/relspeed_QBigInt.jl).

----

#### what does not work well

Other matrix functions (`det`, `lu`, `inv`) take much, much longer.  >> Fixes welcome <<.

Meanwhile, some matrix functions convert first convert FastRationals to system rationals,    
compute the result, and reconvert to FastRationals.

----

### Most performant ranges using fast integers

__FastRationals__ are at their most performant where overflow is absent or uncommon.  And vice versa: where overflow happens frequently, FastRationals have no intrinsic advantage.  How do we know what range of rational values are desireable?  We want to work with rational values that, for the most part, do not overflow when added, subtracted, multiplied or divided.  As rational calculation tends to grow numerator aor denominator magnitudes, it makes sense to further constrain the working range.  These tables are of some guidance. 

----

  ###     ________  FastQ32  ______________________________  FastQ64  __________
  |  range      | refinement  |                | range           | refinement     |
  |:-----------:|:-----------:|:--------------:|:---------------:|:--------------:|
  |             |             |                |                 |                |
  |    ±215//1  |  ±1//215    |    sweet spot  |     ±55_108//1  |  ±1//55_108    |
  |             |             |                |                 |                |
  |    ±255//1  |  ±1//255    |    preferable  |     ±65_535//1  |  ±1//65_535    |
  |             |             |                |                 |                |
  |  ±1_023//1  |  ±1//1_023  |    workable    |   ±262_143//1   |  ±1//262_143   |
  |             |             |                |                 |                |
  | ±4_095//1   |  ±1//4_095  |    admissible  |  ±1_048_575//1  | ±1//1_048_575  |
  |             |             |                |                 |                |


> The calculation of these magnitudes appears [here]( https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/docs/src/thestatelessway.md#quantifying-the-desireable).

----

## additional functionality


### rational compactification

- `compactify`(rational_to_compactify, rational_radius_of_indifference)

From all rationals that exist in the immediate neighborhood<sup>[𝒃](#def)</sup>
of the rational_to_compactify, obtains the unique rational with the smallest denominator.
And, if there be more than one, obtains that rational having the smallest numerator.


```
using FastRationals

midpoint = 76_963 // 100_003

coarse_radius  = 1//64
fine_radius    = 1//32_768
tiny_radius    = 1//7_896_121_034

coarse_compact = compactify(midpoint, coarse_radius)      #         7//9
fine_compact   = compactify(midpoint, fine_radius)        #       147//191
tiny_compact   = compactify(midpoint, passthru_radius)    #    76_963//100_003

abs(midpoint - tiny_compact)   < tiny_radius    &&
abs(midpoint - fine_compact)   < fine_radius    &&
abs(midpoint - coarse_compact) < coarse_radius            #  true
```

<sup><a name="neighborhood">[𝒃](#def)</a></sup> This `neighborhood` is given by 
 ±_the radius of indifference_, centered at the rational to compactify. 


### enhanced rounding

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

### what is not carried over from system rationals 

- There is no `FastRational` representation for Infinity
- There is no support for comparing a `FastRational` with NaN

----

## more about it

> [Context Rather Than State](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/docs/src/thestatelessway.md)

> [what slows FastRationals](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/docs/src/metaphoricalflashlight.md)

> [the `mayoverflow` predicate](https://github.com/JeffreySarnoff/FastRationals.jl/blob/master/docs/src/mayoverflow.md)

----

## acknowledgements

Klaus Crusius has contributed to this effort.

## references

This work stems from a [discussion](https://github.com/JuliaLang/julia/issues/11522) that began in 2015.

The [rational compactifying algorithm](https://dl.acm.org/citation.cfm?id=2733711&dl=ACM&coll=DL) paper is in the ACM digital library. 

----

<sup><a name="source">[𝓪](#attribution)</a></sup> Harmen Stoppels on 2019-06-14

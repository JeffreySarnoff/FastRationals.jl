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

`FastRationals` exports two types: `FastQ32`, `FastQ64`, corresponding to `Rational{Int32}` and `Rational{Int64}`, respectively.
FastRationals are intended for use with _smaller_ rational values.  To compare two rationals or to calculate the sum, difference, product, or ratio of two rationals requires pairwise multiplication of the constituents of one by the constituents of the other.  Whether or not it overflow depends on the number of leading zeros (`leading_zeros`) in the binary representation of the absolute value of the numerator and the denominator given with each rational.  

We really want the larger in magnitude of the numerator and denominator. This is the value that determines the number of bits available to form a product without overflowing. Looked at another way, this is the value that determines whether forming a product could possibly overflow. That is the information of most use in this context. It is alright to determine there is a possiblity of overflow where in fact no overflow will occur.  It is not alright to determine there is no possiblity of overflow where in fact overflow will occur.  In the first instance, some additional work will be done.  In the second instance, an overflow error would stop the computation.

#### `mayoverflow(rational, rational)`

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

FastRationals are at their most performant where overflow is absent or uncommon.  And vice versa: where overflow happens frequently, FastRationals have no intrinsic advantage.  How do we know what range of rational values are desireable?  A good place to start is to work with rational quantities that, paired `!mayoverflow(q1, q2)`.  As it is the nature of rational arithmetic to generate increasingly larger denominators, it makes sense to further constrain the working range.  These tables provide some guidance.

----

|   FastQ32   |  range      | refinement  |
|-------------|-------------|-------------|
|             |             |             |
| desireable  |    ±255//1  |  ±1//255    |
|             |             |             |
| preferable  |  ±1_023//1  |  ±1//1_023  |
|             |             |             |
| admissible  | ±4_095//1   |  ±1//4_095  |

----

|   FastQ64   |  range         | refinement     |
|-------------|----------------|----------------|
|             |                |                |
| desireable  |    ±65_535//1  |  ±1//65_535    |
|             |                |                |
| preferable  |  ±262_143//1   |  ±1//262_143   |
|             |                |                |
| admissible  | ±1_048_575//1  | ±1//1_048_575  |


## performance relative to system Rationals


With appropriately ranged rationals, arithmetic sequences run 12x..16x faster and matrix ops run about 2x..6x faster.

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


```

Arithmetic works like `Rational` for eltypes `Int8, .., Int128, UInt8, ..` except there is no Infinity, no NaN comparisons.

----

----

<sup><a name="source">[𝓪](#attribution)</a></sup> Harmen Stoppels on 2019-06-14

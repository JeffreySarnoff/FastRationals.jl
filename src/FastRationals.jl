module FastRationals

export FastQ32, FastQ64


using Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow

import Base: hash, show, repr, string, tryparse,
    zero, one, iszero, isone, isinteger,
    numerator, denominator, eltype, convert, promote_rule, decompose,
    isinteger, typemax, typemin, sign, signbit, copysign, flipsign, abs, float,
    ==, !=, <, <=, >=, >,
    +, -, *, /, ^, //,
    inv, div, fld, cld, rem, mod, trunc, floor, ceil, round

const FastInt = Union{Int8, Int16, Int32, Int64}

include("FatQ32.jl")
include("FatQ64.jl")

end # FastRationals

module FastRationals

export FastQ32, FastQ64, FastRational


using Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow

import Base: hash, show, repr, string, tryparse,
    zero, one, iszero, isone, isinteger,
    numerator, denominator, eltype, convert, promote_rule, decompose,
    isinteger, typemax, typemin, sign, signbit, copysign, flipsign, abs, float,
    ==, !=, <, <=, >=, >,
    +, -, *, /, ^, //,
    inv, div, fld, cld, rem, mod, trunc, floor, ceil, round

const FastInt = Union{Int8, Int16, Int32, Int64}

abstract type FastRational <: Real end

function canonical(num::T, den::T) where {T<:FastInt}
    num, den = flipsign(num, den), abs(den)
    gcdval = Base.gcd(num, den)
    gcdval === one(T) && return num, den
    num = div(num, gcdval)
    den = div(den, gcdval)
    return num, den
end

include("FastQ32.jl")
include("FastQ64.jl")


numerator(x::T) where {T<:FastRational} = x.num
denominator(x::T) where {T<:FastRational} = x.den


FastQ64(x::FastQ32) = FastQ64(Rational{Int64}(x.num//x.den))
FastQ32(x::FastQ64) = FastQ32(Rational{Int32}(x.num//x.den))

promote_rule(::Type{FastQ64}, ::Type{FastQ32}) = FastQ64
convert(::Type{FastQ64}, x::FastQ32) = FastQ64(x)

end # FastRationals

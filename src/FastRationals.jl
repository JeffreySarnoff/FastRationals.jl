module FastRationals

export FastQ32, FastQ64, FastRational,
       basetype


using Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow

import Base: BitSigned, hash, show, repr, string, tryparse,
    zero, one, iszero, isone, isinteger,
    numerator, denominator, eltype, convert, promote_rule, decompose,
    isinteger, typemax, typemin, sign, signbit, copysign, flipsign, abs, float,
    ==, !=, <, <=, >=, >,
    +, -, *, /, ^, //,
    inv, div, fld, cld, rem, mod, trunc, floor, ceil, round

const FastInt = Union{Int8, Int16, Int32, Int64}

abstract type FastRational <: Real end

function canonical(num::T, den::T) where {T<:BitSigned}
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

include("promote_convert.jl")

round(::Type{Integer}, x::T) where {T<:FastRational} = round(Integer, x.num//x.den)
round(::Type{I}, x::T) where {I<:Integer, T<:FastRational} = round(I, x.num//x.den)
ceil(::Type{Integer}, x::T) where {T<:FastRational} = ceil(Integer, x.num//x.den)
ceil(::Type{I}, x::T) where {I<:Integer, T<:FastRational} = ceil(I, x.num//x.den)
floor(::Type{Integer}, x::T) where {T<:FastRational} = floor(Integer, x.num//x.den)
floor(::Type{I}, x::T) where {I<:Integer, T<:FastRational} = floor(I, x.num//x.den)
trunc(::Type{Integer}, x::T) where {T<:FastRational} = trunc(Integer, x.num//x.den)
trunc(::Type{I}, x::T) where {I<:Integer, T<:FastRational} = trunc(I, x.num//x.den)

round(::Type{Integer}, x::T, ::RoundingMode{:ToZero}) where {T<:Rational} = trunc(Integer, x.num//x.den)
round(::Type{I}, x::T, ::RoundingMode{:ToZero}) where {I<:Integer, T<:FastRational} = trunc(I, x.num//x.den)
round(::Type{Integer}, x::T, ::RoundingMode{:FromZero}) where {T<:Rational} = -trunc(Integer, -x.num//x.den)
round(::Type{I}, x::T, ::RoundingMode{:FromZero}) where {I<:Integer, T<:FastRational} = -trunc(I, -x.num//x.den)
round(::Type{Integer}, x::T, ::RoundingMode{:RoundUp}) where {T<:Rational} = ceil(Integer, x.num//x.den)
round(::Type{I}, x::T, ::RoundingMode{:RoundUp}) where {I<:Integer, T<:FastRational} = ceil(I, x.num//x.den)
round(::Type{Integer}, x::T, ::RoundingMode{:RoundDown}) where {T<:Rational} = floor(Integer, x.num//x.den)
round(::Type{I}, x::T, ::RoundingMode{:RoundDown}) where {I<:Integer, T<:FastRational} = floor(I, x.num//x.den)
round(::Type{Integer}, x::T, ::RoundingMode{:RoundNearest}) where {T<:Rational} = round(Integer, x.num//x.den)
round(::Type{I}, x::T, ::RoundingMode{:RoundNearest}) where {I<:Integer, T<:FastRational} = round(I, x.num//x.den)

end # FastRationals

module FastRationals

export FastRational, FastQ32, FastQ64, FastQ128, FastQBig,
       basetype

using Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow

import Base: Signed, BitSigned, hash, show, repr, string, tryparse,
    zero, one, iszero, isone, isinteger,
    numerator, denominator, eltype, convert, promote_rule, decompose,
    isinteger, typemax, typemin, sign, signbit, copysign, flipsign, abs, float,
    ==, !=, <, <=, >=, >,
    +, -, *, /, ^, //,
    inv, div, fld, cld, rem, mod, trunc, floor, ceil, round

const FastInt = Union{Int8, Int16, Int32, Int64}


struct FastRational{T} <: Real
    num::T
    den::T
       
    FastRational{T}(num::T, den::T) where {T<:Signed} = new{T}(num, den)
end

numerator(x::FastRational{T}) where {T<:Signed} = x.num
denominator(x::FastRational{T}) where {T<:Signed} = x.den

const FastQ32 = FastRational{Int32}
const FastQ64 = FastRational{Int64}
const FastQ128 = FastRational{Int128}
const FastQBig = FastRational{BigInt}


@inline function FastRational(num::T, den::T) where {T<:Signed}
    iszero(den) && throw(DivideError)
    return FastRational{T}(num, den)
end

function canonical(num::T, den::T) where {T<:Signed}
    num, den = flipsign(num, den), abs(den)
    gcdval = Base.gcd(num, den)
    gcdval === one(T) && return num, den
    num = div(num, gcdval)
    den = div(den, gcdval)
    return num, den
end

canonical(num::T, den::T) where {T<:Integer} = Base.divgcd(num,den)

FastRational(x::FastRational{T}) where {T<:Signed} = x
FastRational{T}(x::FastRational{T}) where {T<:Signed} = x
FastRational{T}(x::FastRational{T1}) where {T,T<:T1<:Signed} = FastRational{T}(x.num, x.den)
FastRational{T}(num::T1, den::T1) where {T,T<:T1<:Signed} = FastRational{T}(T(num), T(den))
FastRational{T}(numden::Tuple{T1,T1}) where {T,T<:T1<:Signed} = FastRational{T}(T.(canonical(numden[1], numden[2])))

include("generic.jl")
include("conform_to_int.jl")
include("promote_convert.jl")

end # FastRationals

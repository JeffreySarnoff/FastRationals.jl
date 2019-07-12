module FastRationals

export FastRational, FastQ32, FastQ64, FastQ128, FastQBig,
       compactify, basetype

using Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow

import Base: BitInteger, BitSigned, hash, show, repr, string, tryparse,
    zero, one, iszero, isone, isinteger,
    numerator, denominator, eltype, convert, promote_rule, decompose,
    isinteger, typemax, typemin, sign, signbit, copysign, flipsign, abs, float,
    ==, !=, <, <=, >=, >,
    +, -, *, /, ^, //,
    inv, div, fld, cld, rem, mod, trunc, floor, ceil, round, widen

const SUN = Union{Signed, Unsigned}
const FastSUN = Union{Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64}

struct FastRational{T} <: Real
    num::T
    den::T
       
    FastRational{T}(num::T, den::T) where {T<:Union{Signed,Unsigned}} = new{T}(num, den)
    function FastRational(num::T, den::T) where {T<:Union{Signed,Unsigned}}
        iszero(den) && throw(DivideError)
        return new{T}(num, den)
    end
end
const RationalUnion = Union{FastRational,Rational}

numerator(x::FastRational{T}) where {T<:Integer} = x.num
denominator(x::FastRational{T}) where {T<:Integer} = x.den

const FastQ32 = FastRational{Int32}
const FastQ64 = FastRational{Int64}
const FastQ128 = FastRational{Int128}
const FastQBig = FastRational{BigInt}

function canonical(num::T, den::T) where {T<:Signed}
    num, den = flipsign(num, den), abs(den)
    gcdval = Base.gcd(num, den)
    gcdval === one(T) && return num, den
    num = div(num, gcdval)
    den = div(den, gcdval)
    return num, den
end

canonical(num::T, den::T) where {T<:Integer} = Base.divgcd(num,den)

include("generic.jl")
include("promote_convert.jl")
include("conform_to_int.jl")
include("compactify.jl")

end # FastRationals

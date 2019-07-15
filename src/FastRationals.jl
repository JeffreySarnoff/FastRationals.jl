module FastRationals

export FastRational, FastQ32, FastQ64, FastQ128, FastQBig,
       compactify, basetype

using Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow

import Base: BitInteger, BitSigned, hash, show, repr, string, tryparse,
    zero, one, iszero, isone, isinteger, iseven, isodd, isfinite, issubnormal, isinf, isnan,
    numerator, denominator, eltype, convert, promote_rule, decompose,
    isinteger, typemax, typemin, sign, signbit, copysign, flipsign, abs, abs2, float,
    ==, !=, <, <=, >=, >, cmp, isequal, isless,
    +, -, *, /, ^, //,
    inv, div, fld, cld, rem, mod, trunc, floor, ceil, round, widen

const SUN = Union{Signed, Unsigned}
const FastSUN = Union{Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64}

struct FastRational{T} <: Real
    num::T
    den::T
    
    # this constructor is used when den might be <= 0 excluding typemin(T)
    function FastRational(num::T, den::T) where {T<:SUN}
        iszero(den) && throw(DivideError)
        num, den = flipsign(num, den), abs(den)
        return new{T}(num, den)
    end
     
    # this constructor is used when it is known that den>0   
    FastRational{T}(num::T, den::T) where {T<:SUN} =
        new{T}(num, den)
end

function FastRationalDenomOfT(num::T, den::T) where T<:SUN
    iszero(den) && throw(DivideError)
    num, den = flipsign(num, den), abs(den)
    signbit(den) && throw(DomainError("denominator is typemin($T)"))
    return FastRational{T}(num, den)
end

function FastRationalDenomNonneg(num::T, den::T) where T<:SUN
    iszero(den) && throw(DivideError)
    return FastRational{T}(num, den)
end

function FastRationalDenomNonzero(num::T, den::T) where T<:SUN
    num, den = flipsign(num, den), abs(den)
    signbit(den) && throw(DomainError("denominator is typemin($T)"))
    return FastRational{T}(num, den)
end

       
       # this constructor is used when it is known that den>0   
    FastRational(numden::Tuple{T, T}) where {T<:SUN} =
        new{T}(numden[1], numden[2])
   

const Rationals = Union{FastRational,Rational}

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

module FasterRationals

export FastRational

import Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow,
    checked_neg, checked_abs, checked_add, checked_sub, checked_mul,
    checked_div, checked_rem, checked_fld, checked_mod, checked_cld

import Base: numerator, denominator, eltype, convert, promote_rule, decompose
    isinteger, typemax, typemin, sign, signbit, copysign, flipsign, abs,
    ==, !=, <, <=, 
    +, -, *, /, ^, div

# traits

"""
    RationalTrait

a trait applicable to Rational values
"""
abstract type RationalTrait end

"""
    IsReduced <: RationalTrait

This trait holds for rational values that are known to have been reduced to lowest terms.
"""
struct IsReduced  <: RationalTrait end

"""
    MayReduce <: RationalTrait

This trait holds for rational values that may or may not be expressed in lowest terms.
"""
struct MayReduce  <: RationalTrait end

struct FasterRational{T<:Signed, H<:RationalTrait} <: Real
    num::T
    den::T
end

numerator(x::FasterRational{T,H}) where {T,H} = x.num
denominator(x::FasterRational{T,H}) where {T,H} = x.den
eltype(x::FasterRational{T,H}) where {T,H} = T

content(x::FasterRational{T,H}) where {T,H} = numerator(x), denominator(x)

trait(x::FasterRational{T,H}) where {T,H} = H
isreduced(x::FasterRational{T,H}) where {T,H} = H === IsReduced
mayreduce(x::FasterRational{T,H}) where {T,H} = H === MayReduce

FasterRational(x::Rational{T}) where {T} = FasterRational{T,IsReduced}(x.num, x.den)
Rational(x::FasterRational{T,IsReduced}) where {T} = Rational{T}(x.num, x.den)
Rational(x::FasterRational{T,MayReduce}) where {T} = Rational(x.num, x.den)

convert(::Type{Rational{T}}, x::FasterRational{T}) where {T} = Rational(x)
convert(::Type{FasterRational{T}}, x::Rational{T}) where {T} = FasterRational(x)

promote_rule(::Type{Rational{T}}, ::Type{FasterRational{T}}) where {T} = FasterRational{T}

# canonical(q) reduces q to lowest terms

canonical(x::FasterRational{T,H}) where {T, H<:IsReduced} = x

function canonical(x::FasterRational{T,H}) where {T,H}
    n, d = canonical(x.num, x.den)
    return FasterRational{T, IsReduced}(n, d)
end

"""
    canonical(numerator::T, denominator::T) where T<:Signed

Rational numbers that are finite and normatively bounded by
the extremal magnitude of an underlying signed type have a
canonical representation.
- numerator and denominator have no common factors
- numerator may be negative, zero or positive
- denominator is strictly positive (d > 0)
""" canonical

function canonical(num::T, den::T) where {T<:Signed}
    num, den = canonical_signed(num, den)
    num, den = canonical_valued(num, den)
    return num, den
end

@inline function canonical_signed(num::T, den::T) where {T<:Signed}
    return flipsign(num, den), abs(den)
end

@inline function canonical_valued(num::T, den::T) where {T<:Signed}
    gcdval = gcd(num, den)
    gcdval === one(T) && return num, den
    num = div(num, gcdval)
    den = div(den, gcdval)
    return num, den
end
    
    
    

sign(x::FasterRational{T,IsReduced}) where {T<:Signed} = FasterRational{T,IsReduced}(sign(x.num), one(T))
sign(x::FasterRational{T,MayReduce}) where {T<:Signed} = FasterRational{T,IsReduced}(sign(x.num)*sign(x.den), one(T))
signbit(x::FasterRational{T,IsReduced}) where {T<:Signed} = signbit(x.num)
signbit(x::FasterRational{T,MayReduce}) where {T<:Signed} = xor(signbit(x.num), signbit(x.den))

sign(x::FasterRational{T,H}) where {T<:Unsigned, H} = FasterRational{T,IsReduced}(one(T), one(T))
signbit(x::FasterRational{T,H}) where {T<:Unsigned} = false


copysign(x::FasterRational, y::Real) = copysign(x.num,y) // x.den
copysign(x::FasterRational, y::FasterRational) = copysign(x.num,y.num) // x.den
copysign(x::FasterRational, y::Rational) = copysign(x.num,y.num) // x.den

abs(x::FasterRational{T,H}) where {T,H} = FasterRational{T,H}(abs(x.num), x.den)

typemin(::Type{FasterRational{T,H}}) where {T<:Signed,H} = FasterRational{T,IsReduced}(typemin(T),one(T))
typemin(::Type{FasterRational{T,H}}) where {T<:Unsigned,H} = FasterRational{T,IsReduced}(zero(T),one(T))
typemax(::Type{FasterRational{T,H}}) where {T<:Integer,H} = FasterRational{T,IsReduced}(typemax(T),one(T))

isinteger(x::FasterRational{T,IsReduced}) where {T} = x.den == 1
isinteger(x::FasterRational{T,MayReduce}) where {T} = canonical(x.num,x.den)[2] == 1

+(x::FasterRational{T}) where {T} = (+x.num) // x.den
-(x::FasterRational{T}) where {T} = (-x.num) // x.den

function -(x::FasterRational{T}) where T<:BitSigned
    x.num == typemin(T) && throw(OverflowError("rational numerator is typemin(T)"))
    (-x.num) // x.den
end
function -(x::FasterRational{T}) where T<:Unsigned
    x.num != zero(T) && throw(OverflowError("cannot negate unsigned number"))
    x
end    
    
    
# core parts of add, sub

@inline function add_with_overflow_for_rational(x, y)
    ovf = false
    numer, ovfl = mul_with_overflow(x, denominator(y)) # here, numer is a temp
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(denominator(x), numerator(y)) # here, denom is a temp
    ovf |= ovfl
    numer, ovfl = add_with_overflow(numer, denom) # numerator of sum
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(denominator(x), denominator(y)) # denominator of sum
    ovf |= ovfl

    return numer, denom, ovf
end

@inline function sub_with_overflow_for_rational(x, y)
    ovf = false
    numer, ovfl = mul_with_overflow(numerator(x), denominator(y)) # here, numer is a temp
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(denominator(x), numerator(y)) # here, denom is a temp
    ovf |= ovfl
    numer, ovfl = sub_with_overflow(numer, denom) # numerator of difference
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(denominator(x), denominator(y)) # denominator of difference
    ovf |= ovfl

    return numer, denom, ovf
end

@inline function mul_with_overflow_for_rational(x, y)
    ovf = false
    numer, ovfl = mul_with_overflow(numerator(x), numerator(y))
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(denominator(x), denominator(y))
    ovf |= ovfl

    return numer, denom, ovf
end

@inline function div_with_overflow_for_rational(x, y)
    ovf = false
    numer, ovfl = mul_with_overflow(numerator(x), denominator(y))
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(denominator(x), numerator(y))
    ovf |= ovfl

    return numer, denom, ovf
end

    

function Base.:(+)(x::TraitedRational{T,H}, y::TraitedRational{T,H}) where {T,H}
    numer, denom, ovf = add_with_overflow_for_rational(x, y)
    ovf && throw(OverflowError("$x + $y overflowed"))
    
    return TraitedRational{T,MayReduce}(numer, denom)
end

function Base.:(-)(x::TraitedRational{T,H}, y::TraitedRational{T,H}) where {T,H}
    numer, denom, ovf = sub_with_overflow_for_rational(x, y)
    ovf && throw(OverflowError("$x - $y overflowed"))
    
    return TraitedRational{T,MayReduce}(numer, denom)
end

function Base.:(*)(x::TraitedRational{T,H}, y::TraitedRational{T,H}) where {T,H}
    numer, denom, ovf = mul_with_overflow_for_rational(x, y)
    ovf && throw(OverflowError("$x + $y overflowed"))
    
    return TraitedRational{T,MayReduce}(numer, denom)
end

function Base.:(/)(x::TraitedRational{T,H}, y::TraitedRational{T,H}) where {T,H}
    numer, denom, ovf = div_with_overflow_for_rational(x, y)
    ovf && throw(OverflowError("$x + $y overflowed"))
    
    return TraitedRational{T,MayReduce}(numer, denom)
end



function Base.:(+)(x::FasterRational{T,H}, y::FasterRational{T,H}) where {T,H}
    numer, denom, ovf = add_with_overflow_for_rational(x, y)
    ovf && throw(OverflowError("$x + $y overflowed"))
    
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(-)(x::FasterRational{T,H}, y::FasterRational{T,H}) where {T,H}
    numer, denom, ovf = sub_with_overflow_for_rational(x, y)
    ovf && throw(OverflowError("$x - $y overflowed"))
    
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(*)(x::FasterRational{T,H}, y::FasterRational{T,H}) where {T,H}
    numer, denom, ovf = mul_with_overflow_for_rational(x, y)
    ovf && throw(OverflowError("$x + $y overflowed"))
    
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(/)(x::FasterRational{T,H}, y::FasterRational{T,H}) where {T,H}
    numer, denom, ovf = div_with_overflow_for_rational(x, y)
    ovf && throw(OverflowError("$x + $y overflowed"))
    
    return FasterRational{T,MayReduce}(numer, denom)
end


function Base.:(+)(x::FasterRational{T,H}, y::FasterRational{T,H}) where {T,H}
    numer, denom, ovf = add_with_overflow_for_rational(x, y)
    ovf && throw(OverflowError("$x + $y overflowed"))
    
    return FasterRational{T,MayReduce}(numer, denom)
end



    

struct ReducedRational{T<:Signed}
    num::T
    den::T
end

struct ReducibleRational{T<:Signed}
    num::T
    den::T
end

struct UnreducedRational{T<:Signed}
    num::T
    den::T
end


       ReduceRawRational

import Base: convert, promote_rule, string, show,
    isfinite, isinteger,
    signbit, flipsign, changesign,
    (+), (-), (*), (//), div, rem, fld, mod, cld,
    (==), (<), (<=), isequal, isless

import Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow

const SignedInt = Union{Int16, Int32, Int64, Int128, BigInt}


include(joinpath(".", "types", "namedtuple", "fast_rational.jl"))
    
include(joinpath(".", "types","shared.jl"))

include(joinpath("types", "namedtuple", "fast_rational.jl"))
include(joinpath("types", "struct",     "fast_rational.jl"))
include(joinpath("types", "mutable",    "fast_rational.jl"))

include(joinpath("int_ops", "namedtuple", "fast_rational.jl"))
include(joinpath("int_ops", "struct",     "fast_rational.jl"))
include(joinpath("int_ops", "mutable",    "fast_rational.jl"))

include(joinpath("types", "namedtuple", "compares.jl"))
include(joinpath("types", "struct",     "compares.jl"))
include(joinpath("types", "mutable",    "compares.jl"))

end # FasterRationals

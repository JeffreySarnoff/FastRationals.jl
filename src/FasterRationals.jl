module FasterRationals

export FastRational

using Base: BitSigned

using Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow,
    checked_neg, checked_abs, checked_add, checked_sub, checked_mul,
    checked_div, checked_rem, checked_fld, checked_mod, checked_cld

import Base: numerator, denominator, eltype, convert, promote_rule, decompose,
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
signbit(x::FasterRational{T,H}) where {T<:Unsigned, H} = false

copysign(x::FasterRational, y::Real) = y >= 0 ? abs(x) : -abs(x)
copysign(x::FasterRational, y::FasterRational) = FasterRational{T,H}(copysign(x.num, y.num), x.den)
copysign(x::FasterRational, y::Rational) = FasterRational{T,H}(copysign(x.num,y.num), x.den)

flipsign(x::FasterRational, y::Real) = FasterRational{T,H}(flipsign(x.num,y), x.den)
flipsign(x::FasterRational, y::FasterRational) = FasterRational{T,H}(flipsign(x.num,y.num), x.den)
flipsign(x::FasterRational, y::Rational) = FasterRational{T,H}(flipsign(x.num,y.num), x.den)

abs(x::FasterRational{T,H}) where {T,H} = FasterRational{T,H}(abs(x.num), x.den)

typemin(::Type{FasterRational{T,H}}) where {T<:Signed,H} = FasterRational{T,IsReduced}(typemin(T),one(T))
typemin(::Type{FasterRational{T,H}}) where {T<:Unsigned,H} = FasterRational{T,IsReduced}(zero(T),one(T))
typemax(::Type{FasterRational{T,H}}) where {T<:Integer,H} = FasterRational{T,IsReduced}(typemax(T),one(T))

isinteger(x::FasterRational{T,IsReduced}) where {T} = x.den == 1
isinteger(x::FasterRational{T,MayReduce}) where {T} = canonical(x.num,x.den)[2] == 1

+(x::FasterRational{T,H}) where {T,H} = FasterRational{T,H}(+x.num, x.den)
-(x::FasterRational{T,H}) where {T,H} = FasterRational{T,H}(-x.num, x.den)

function -(x::FasterRational{T,IsReduced}) where {T<:BitSigned}
    x.num == typemin(T) && throw(OverflowError("rational numerator is typemin(T)"))
    FasterRational{T,IsReduced}(-x.num, x.den)
end
-(x::FasterRational{T,MayReduce}) where {T<:BitSigned} =
    -FasterRational{T,IsReduced}(canonical(x.num, x.den)...,)
    
function -(x::FasterRational{T,H}) where {T<:Unsigned,H}
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


function Base.:(+)(x::FasterRational{T,IsReduced}, y::FasterRational{T,IsReduced}) where {T}
    numer, denom, ovf = add_with_overflow_for_rational(x, y)
    ovf && throw(OverflowError("$x + $y overflowed"))   
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(+)(x::FasterRational{T,MayReduce}, y::FasterRational{T,IsReduced}) where {T}
    numer, denom, ovf = add_with_overflow_for_rational(x, y)
    if ovf
        xnum, xden = canonical(numerator(x), denominator(x))
        return FasterRational{T,IsReduced}(xnum, xden) + y
    end
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(+)(x::FasterRational{T,IsReduced}, y::FasterRational{T,MayReduce}) where {T}
    numer, denom, ovf = add_with_overflow_for_rational(x, y)
    if ovf
        ynum, yden = canonical(numerator(y), denominator(y))
        return x + FasterRational{T, IsReduced}(ynum, yden)
    end
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(+)(x::FasterRational{T,MayReduce}, y::FasterRational{T,MayReduce}) where {T}
    numer, denom, ovf = add_with_overflow_for_rational(x, y)
    if ovf
        xnum, xden = canonical(numerator(x), denominator(x))
        ynum, yden = canonical(numerator(y), denominator(y))
        return FasterRational{T,IsReduced}(xnum, xden) + FasterRational{T, IsReduced}(ynum, yden)
    end
    return FasterRational{T,MayReduce}(numer, denom)
end


function Base.:(-)(x::FasterRational{T,IsReduced}, y::FasterRational{T,IsReduced}) where {T}
    numer, denom, ovf = sub_with_overflow_for_rational(x, y)
    ovf && throw(OverflowError("$x - $y overflowed"))   
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(-)(x::FasterRational{T,MayReduce}, y::FasterRational{T,IsReduced}) where {T}
    numer, denom, ovf = sub_with_overflow_for_rational(x, y)
    if ovf
        xnum, xden = canonical(numerator(x), denominator(x))
        return FasterRational{T,IsReduced}(xnum, xden) - y
    end
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(-)(x::FasterRational{T,IsReduced}, y::FasterRational{T,MayReduce}) where {T}
    numer, denom, ovf = sub_with_overflow_for_rational(x, y)
    if ovf
        ynum, yden = canonical(numerator(y), denominator(y))
        return x - FasterRational{T, IsReduced}(ynum, yden)
    end
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(-)(x::FasterRational{T,MayReduce}, y::FasterRational{T,MayReduce}) where {T}
    numer, denom, ovf = sub_with_overflow_for_rational(x, y)
    if ovf
        xnum, xden = canonical(numerator(x), denominator(x))
        ynum, yden = canonical(numerator(y), denominator(y))
        return FasterRational{T,IsReduced}(xnum, xden) - FasterRational{T, IsReduced}(ynum, yden)
    end
    return FasterRational{T,MayReduce}(numer, denom)
end


function Base.:(*)(x::FasterRational{T,IsReduced}, y::FasterRational{T,IsReduced}) where {T}
    numer, denom, ovf = mul_with_overflow_for_rational(x, y)
    ovf && throw(OverflowError("$x + $y overflowed"))   
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(*)(x::FasterRational{T,MayReduce}, y::FasterRational{T,IsReduced}) where {T}
    numer, denom, ovf = mul_with_overflow_for_rational(x, y)
    if ovf
        xnum, xden = canonical(numerator(x), denominator(x))
        return FasterRational{T,IsReduced}(xnum, xden) * y
    end
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(*)(x::FasterRational{T,IsReduced}, y::FasterRational{T,MayReduce}) where {T}
    numer, denom, ovf = mul_with_overflow_for_rational(x, y)
    if ovf
        ynum, yden = canonical(numerator(y), denominator(y))
        return x * FasterRational{T, IsReduced}(ynum, yden)
    end
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(*)(x::FasterRational{T,MayReduce}, y::FasterRational{T,MayReduce}) where {T}
    numer, denom, ovf = mul_with_overflow_for_rational(x, y)
    if ovf
        xnum, xden = canonical(numerator(x), denominator(x))
        ynum, yden = canonical(numerator(y), denominator(y))
        return FasterRational{T,IsReduced}(xnum, xden) * FasterRational{T, IsReduced}(ynum, yden)
    end
    return FasterRational{T,MayReduce}(numer, denom)
end


function Base.:(/)(x::FasterRational{T,IsReduced}, y::FasterRational{T,IsReduced}) where {T}
    numer, denom, ovf = div_with_overflow_for_rational(x, y)
    ovf && throw(OverflowError("$x / $y overflowed"))   
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(/)(x::FasterRational{T,MayReduce}, y::FasterRational{T,IsReduced}) where {T}
    numer, denom, ovf = div_with_overflow_for_rational(x, y)
    if ovf
        xnum, xden = canonical(numerator(x), denominator(x))
        return FasterRational{T,IsReduced}(xnum, xden) / y
    end
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(/)(x::FasterRational{T,IsReduced}, y::FasterRational{T,MayReduce}) where {T}
    numer, denom, ovf = div_with_overflow_for_rational(x, y)
    if ovf
        ynum, yden = canonical(numerator(y), denominator(y))
        return x / FasterRational{T, IsReduced}(ynum, yden)
    end
    return FasterRational{T,MayReduce}(numer, denom)
end

function Base.:(/)(x::FasterRational{T,MayReduce}, y::FasterRational{T,MayReduce}) where {T}
    numer, denom, ovf = div_with_overflow_for_rational(x, y)
    if ovf
        xnum, xden = canonical(numerator(x), denominator(x))
        ynum, yden = canonical(numerator(y), denominator(y))
        return FasterRational{T,IsReduced}(xnum, xden) / FasterRational{T, IsReduced}(ynum, yden)
    end
    return FasterRational{T,MayReduce}(numer, denom)
end

end # FasterRationals

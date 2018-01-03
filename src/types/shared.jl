@inline numerator(x::T) where {S, T<:FasterRational{S}} = x.num
@inline denominator(x::T) where {S, T<:FasterRational{S}} = x.den
@inline value(x::T) where {S, T<:FasterRational{S}} = (x.num, x.den)
@inline eltype(x::T) where {S, T<:FasterRational{S}} = S


"""
    canonical(numerator::T, denominator::T) where T<:Signed

Rational numbers that are finite and normatively bounded by
the extremal magnitude of an underlying signed type have a
canonical representation.
- numerator and denominator have no common factors
- numerator may be negative, zero or positive
- denominator is strictly positive (d > 0)
"""
function canonical(num::T, den::T) where {T<:SignedInt}
    num, den = canonical_signs(num, den)
    num, den = canonical_values(num, den)
    return num, den
end

@inline function canonical_signs(num::T, den::T) where {T<:SignedInt}
    return flipsign(num, den), abs(den)
end

@inline function canonical_values(num::T, den::T) where {T<:SignedInt}
    gcdval = gcd(num, den)
    gcdval === one(T) && return num, den
    num = div(num, gcdval)
    den = div(den, gcdval)
    return num, den
end

@inline function Canonical(rational::T) where T<:FasterRational
    return T(canonical(numerator(rational), denominator(rational))...,)
end

#=
    arithmetic
=#


@inline function add_with_overflow(x::T, y::T) where T<:FasterRational
    ovf = false
    numer, ovfl = mul_with_overflow(numerator(x), denominator(y)) # here, numer is a temp
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(denominator(x), numerator(y)) # here, denom is a temp
    ovf |= ovfl
    numer, ovfl = add_with_overflow(numer, denom) # numerator of sum
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(denominator(x), denominator(y)) # denominator of sum
    ovf |= ovfl

    return numer, denom, ovf
end

@inline function sub_with_overflow(x::T, y::T) where T<:FasterRational
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

@inline function mul_with_overflow(x::T, y::T) where T<:FasterRational
    ovf = false
    numer, ovfl = mul_with_overflow(numerator(x), numerator(y))
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(denominator(x), denominator(y))
    ovf |= ovfl

    return numer, denom, ovf
end

@inline function div_with_overflow(x::T, y::T) where T<:FasterRational
    ovf = false
    numer, ovfl = mul_with_overflow(numerator(x), denominator(y))
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(denominator(x), numerator(y))
    ovf |= ovfl

    return numer, denom, ovf
end

#=
    inspired by and/or copyied from julia/rational.jl
=#

iszero(x::T) where T<:FasterRational = iszero(numerator(x)) & !iszero(denominator(x))
isone(x::T) where T<:FasterRational = isone(numerator(x)) & isone(denominator(x))
isinteger(x::T) where T<:FasterRational = iszero(rem(numerator(x), denominator(x)))

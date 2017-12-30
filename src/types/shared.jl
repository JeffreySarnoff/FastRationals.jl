
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

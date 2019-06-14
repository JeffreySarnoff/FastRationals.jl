module FastRationals

export FastRational

using Base: BitSigned

using Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow,
    checked_neg, checked_abs, checked_add, checked_sub, checked_mul,
    checked_div, checked_rem, checked_fld, checked_mod, checked_cld

import Base: show, string, numerator, denominator, eltype, convert, promote_rule, decompose,
    isinteger, typemax, typemin, sign, signbit, copysign, flipsign, abs, 
    ==, !=, <, <=, >=, >,
    +, -, *, /, ^, div

"""
    RationalState

a state applicable to Rational values
"""
abstract type RationalState end

"""
    IsReduced <: RationalState

This state holds for rational values that are known to have been reduced to lowest terms.
"""
struct IsReduced  <: RationalState end

"""
    MayReduce <: RationalState

This state holds for rational values that may or may not be expressed in lowest terms.
"""
struct MayReduce  <: RationalState end

struct FastRational{T<:Signed, H<:RationalState} <: Real
    num::T
    den::T
end

numerator(x::FastRational{T,H}) where {T,H} = x.num
denominator(x::FastRational{T,H}) where {T,H} = x.den
eltype(x::FastRational{T,H}) where {T,H} = T

content(x::FastRational{T,H}) where {T,H} = numerator(x), denominator(x)

isreduced(x::FastRational{T,IsReduced}) where {T} = true
isreduced(x::FastRational{T,MayReduce}) where {T} = false
mayreduce(x::FastRational{T,IsReduced}) where {T} = false
mayreduce(x::FastRational{T,MayReduce}) where {T} = true

FastRational(num::T, den::T) where T = FastRational(canonical(num, den))
FastRational(x::NTuple{2,T}) where T = FastRational{T,IsReduced}(x[1], x[2])

FastRational(x::FastRational{T,IsReduced}) where {T} = x
FastRational(x::FastRational{T,MayReduce}) where {T} = FastRational(x.num, x.den)
    
FastRational(x::Rational{T}) where {T} = FastRational{T,IsReduced}(x.num, x.den)
Rational(x::FastRational{T,IsReduced}) where {T} = Rational{T}(x.num, x.den)
Rational(x::FastRational{T,MayReduce}) where {T} = Rational(x.num, x.den)

convert(::Type{Rational{T}}, x::FastRational{T,H}) where {T,H} = Rational(x)
convert(::Type{FastRational{T,H}}, x::Rational{T}) where {T,H} = FastRational(x)
convert(::Type{FastRational{T,H}}, x::T) where {T,H} = FastRational{T,IsReduced}(x, one(T))
convert(::Type{FastRational{T1,H}}, x::T2) where {T1,T2<:Integer,H} = FastRational{T1,IsReduced}(T1(x), one(T1))

promote_rule(::Type{Rational{T}}, ::Type{FastRational{T,IsReduced}}) where {T} = FastRational{T,IsReduced}
promote_rule(::Type{Rational{T}}, ::Type{FastRational{T,MayReduce}}) where {T} = FastRational{T,IsReduced}
promote_rule(::Type{FastRational{T,H}}, ::Type{T}) where {T,H} = FastRational{T,IsReduced}
promote_rule(::Type{FastRational{T1,H}}, ::Type{T2}) where {T1,T2<:Integer,H} = FastRational{T1,IsReduced}


signbit(x::FastRational{T,H}) where {T<:Signed, H} = xor(signbit(x.num), signbit(x.den))
sign(x::FastRational{T,H}) where {T<:Signed, H} = FastRational{T,IsReduced}(signbit(x) ? -one(T) : one(T))
abs(x::FastRational{T,IsReduced}) where {T<:Signed} = FastRational{T,IsReduced}(abs(x.num), x.den)
abs(x::FastRational{T,MayReduce}) where {T<:Signed} = FastRational{T,IsReduced}(abs(x.num), abs(x.den))

signbit(x::FastRational{T,H}) where {T<:Unsigned, H} = false
sign(x::FastRational{T,H}) where {T<:Unsigned, H} = FastRational{T,IsReduced}(one(T), one(T))
abs(x::FastRational{T,H}) where {T<:Unsigned, H} = x

# canonical(q) reduces q to lowest terms

canonical(x::FastRational{T,H}) where {T, H<:IsReduced} = x

function canonical(x::FastRational{T,H}) where {T,H}
    n, d = canonical(x.num, x.den)
    return FastRational{T, IsReduced}(n, d)
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


(==)(x::FastRational{T,IsReduced}, y::FastRational{T,IsReduced}) where {T} =
    x.num === y.num && x.den === y.den
(!=)(x::FastRational{T,IsReduced}, y::FastRational{T,IsReduced}) where {T} =
    x.num !== y.num || x.den !== y.den

for F in (:(==), :(!=), :(<), :(<=), :(>=), :(>))
  @eval $F(x::FastRational{T,H1}, y::FastRational{T,H2}) where {T,H1, H2} =
    $F(x.num * y.den, x.den * y.num)
end

    
negate(x::S) where {S<:Signed} = x !== typemin(S) ? -x : throw(OverflowError("cannot negate typemin($S)"))
negate(x::U) where {U<:Unsigned} = throw(OverflowError("cannot negate $U"))

copysign(x::FastRational, y::Real) = y >= 0 ? abs(x) : negate(abs(x))
copysign(x::FastRational{T,H}, y::FastRational) where {T,H} = FastRational{T,H}(copysign(x.num, y.num), x.den)
copysign(x::FastRational{T,H}, y::Rational) where {T,H} = FastRational{T,H}(copysign(x.num,y.num), x.den)

flipsign(x::FastRational{T,H}, y::Real) where {T,H} = FastRational{T,H}(flipsign(x.num,y), x.den)
flipsign(x::FastRational{T,H}, y::FastRational) where {T,H} = FastRational{T,H}(flipsign(x.num,y.num), x.den)
flipsign(x::FastRational{T,H}, y::Rational) where {T,H} = FastRational{T,H}(flipsign(x.num,y.num), x.den)

abs(x::FastRational{T,H}) where {T,H} = FastRational{T,H}(abs(x.num), x.den)

typemin(::Type{FastRational{T,H}}) where {T<:Signed,H} = FastRational{T,IsReduced}(typemin(T),one(T))
typemin(::Type{FastRational{T,H}}) where {T<:Unsigned,H} = FastRational{T,IsReduced}(zero(T),one(T))
typemax(::Type{FastRational{T,H}}) where {T<:Integer,H} = FastRational{T,IsReduced}(typemax(T),one(T))

isinteger(x::FastRational{T,IsReduced}) where {T} = x.den == 1
isinteger(x::FastRational{T,MayReduce}) where {T} = canonical(x.num,x.den)[2] == 1

+(x::FastRational{T,H}) where {T,H} = FastRational{T,H}(+x.num, x.den)
-(x::FastRational{T,H}) where {T,H} = FastRational{T,H}(-x.num, x.den)

function -(x::FastRational{T,IsReduced}) where {T<:BitSigned}
    x.num == typemin(T) && throw(OverflowError("rational numerator is typemin(T)"))
    FastRational{T,IsReduced}(-x.num, x.den)
end
-(x::FastRational{T,MayReduce}) where {T<:BitSigned} =
    -FastRational{T,IsReduced}(canonical(x.num, x.den)...,)
    
function -(x::FastRational{T,H}) where {T<:Unsigned,H}
    x.num != zero(T) && throw(OverflowError("cannot negate unsigned number"))
    x
end    
    
    
# core parts of add, sub

@inline function addovf(x, y)
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

@inline function subovf(x, y)
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

@inline function mulovf(x, y)
    ovf = false
    numer, ovfl = mul_with_overflow(numerator(x), numerator(y))
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(denominator(x), denominator(y))
    ovf |= ovfl
    return numer, denom, ovf
end

@inline function divovf(x, y)
    ovf = false
    numer, ovfl = mul_with_overflow(numerator(x), denominator(y))
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(denominator(x), numerator(y))
    ovf |= ovfl
    return numer, denom, ovf
end

for (F,G) in ((:(+), :addovf), (:(-), :subovf), (:(*), :mulovf), (:(/), :divovf))
  @eval begin
    function $F(x::FastRational{T,IsReduced}, y::FastRational{T,IsReduced}) where {T}
      num, den, ovf = $G(x, y)
      ovf && throw(OverflowError("$x + $y overflowed"))   
      return FastRational{T,MayReduce}(num, den)
    end
    function $F(x::FastRational{T,IsReduced}, y::FastRational{T,MayReduce}) where {T}
      num, den, ovf = $G(x, y)
      if ovf
         num, den = canonical(y.num, y.den)
         return $F(x, FastRational{T,IsReduced}(num, den))
      end
      return FastRational{T,MayReduce}(num, den)
    end
    function $F(x::FastRational{T,MayReduce}, y::FastRational{T,IsReduced}) where {T}
      num, den, ovf = $G(x, y)
      if ovf
         num, den = canonical(x.num, x.den)
         return $F(FastRational{T,IsReduced}(num, den), y)
      end
      return FastRational{T,MayReduce}(num, den)
    end
    function $F(x::FastRational{T,MayReduce}, y::FastRational{T,MayReduce}) where {T}
      num, den, ovf = $G(x, y)
      if ovf
         xnum, xden = canonical(x.num, x.den)
         ynum, yden = canonical(y.num, y.den)
         return $F(FastRational{T,IsReduced}(xnum, xden), FastRational{T,IsReduced}(ynum, yden))
      end
      return FastRational{T,MayReduce}(num, den)
    end        
  end
end

function string(x::FastRational{T,IsReduced}) where {T}
    return string(x.num,"//",x.den)
end

function string(x::FastRational{T,MayReduce}) where {T}
    num, den = canonical(x.num, x.den)
    return string(num,"//",den)
end

function show(io::IO, x::FastRational{T,H}) where {T,H}
    print(io, string(x))
end

end # FastRationals

#=
    when it is known of num::T, den::T 
    or given by construction that
       den > 0
       use FastRational{T}(num, den)
           - skip checking for zero or negative denominator

    when it is known of num::T, den::T 
    or given by construction that
    or may be the case that
       den < 0 && den != typemin(T)
       use FastRationalChecked(num, den)
           - check for zero or negative denominator
   
    when it is known of num::T, den::T 
    or given by construction that
    or may be the case that
       den == typemin(T)
       use FastRationalGuarded(num, den)
           - check for typemin(T) in denominator
           - check for zero or negative denominator
=#

basetype(::Type{FastRational{T}}) where T = T
basetype(::Type{Rational{T}}) where T = T
basetype(x) = basetype(typeof(x))

typemax(::Type{FastRational{T}}) where T = FastRational(typemax(T))
typemin(::Type{FastRational{T}}) where T = FastRational(typemin(T))

widen(::Type{FastRational{T}}) where T = FastRational{widen(T)}

FastRational{T}(x::Integer) where T = FastRational{T}(T(x), one(T), Val(true))
FastRational{T}(x::FastRational) where T = FastRational{T}(x.num, x.den)
FastRational(x::FastRational{T}) where T = FastRational{T}(x.num, x.den)
FastRational{T}(x::Rational) where T = FastRational{T}(x.num, x.den)
FastRational(x::Rational{T}) where T = FastRational{T}(x.num, x.den)
Rational{T}(x::FastRational) where T = Rational{T}(x.num, x.den)
Rational(x::FastRational{T}) where T = Rational{T}(x.num, x.den)

string(x::FastRational) = string(x.num//x.den)
show(io::IO, x::FastRational) = show(io, x.num//x.den)

zero(::Type{FastRational{T}}) where T = FastRational{T}(zero(T), one(T), Val(true))
one(::Type{FastRational{T}}) where T = FastRational{T}(one(T), one(T), Val(true))

iszero(x::FastRational{T}) where T = iszero(x.num)
isone(x::FastRational) where T = x.num === x.den
isinteger(x::FastRational) = iszero(x.num % x.den)
function iseven(x::FastRational)
    d, r = divrem(x.num, x.den)
    r == 0 && iseven(d)
end
function isodd(x::FastRational{T}) where {T<:SUN}
    d, r = divrem(x.num, x.den)
    r == 0 && isodd(d)
end

isfinite(x::FastRational) = true
isinf(x::FastRational) = false
isnan(x::FastRational) = false


signbit(x::FastRational) = xor(signbit(x.num), signbit(x.den))
sign(x::FastRational) = iszero(x) ? zero(x) : signbit(x) ? oftype(x, -1) : one(x)
abs(x::FastRational) = signbit(x) ? -x : x
abs2(x::FastRational) = x * x
-(x::FastRational{T}) where T = FastRational{T}(-x.num, x.den, Val(true))

function inv(x::FastRational{T}) where T
    den, num = x.num >= 0 ? (x.num, x.den) : (-x.num, -x.den)
    den > 0 || throw(DivideError())
    FastRational{T}(num, den, Val(true))
end

copysign(x::FastRational, y::Real) = signbit(y) ? -abs(x) : abs(x)
flipsign(x::FastRational, y::Real)= signbit(y) ? -x : x

==(x::FastRational, y::FastRational) = widemul(x.num, y.den) == widemul(x.den, y.num)

<=(x::FastRational, y::FastRational) = widemul(x.num, y.den) <= widemul(x.den, y.num)
<(x::FastRational, y::FastRational) = widemul(x.num, y.den) < widemul(x.den, y.num)

cmp(x::FastRational, y::FastRational) = cmp(widemul(x.num, y.den), widemul(x.den, y.num))
    
function +(x::FastRational{T}, y::FastRational{T}) where T
    num, den, ovf = addovf(x, y)
    !ovf && return FastRational{T}(num, den, Val(true))
    numer, denom = addq(widen(x.num), widen(x.den), widen(y.num), widen(y.den))
    numer, denom = canonical(numer, denom)
    return FastRational{T}(T(numer), T(denom), Val(true))
end

function -(x::FastRational{T}, y::FastRational{T}) where T
    num, den, ovf = subovf(x, y)
    !ovf && return FastRational{T}(num, den, Val(true))
    numer, denom = subq(widen(x.num), widen(x.den), widen(y.num), widen(y.den))
    numer, denom = canonical(numer, denom)
    return FastRational{T}(T(numer), T(denom), Val(true))
end

function *(x::FastRational{T}, y::FastRational{T}) where T
    num, den, ovf = mulovf(x, y)
    !ovf && return FastRational{T}(num, den, Val(true))
    numer, denom = mulq(widen(x.num), widen(x.den), widen(y.num), widen(y.den))
    numer, denom = canonical(numer, denom)
    return FastRational{T}(T(numer), T(denom), Val(true))
end

function /(x::FastRational{T}, y::FastRational{T}) where T
    num, den, ovf = divovf(x, y)
    if !ovf
        den > 0 || throw(DivideError())
        return FastRational{T}(num, den, Val(true))
    end
    numer, denom = divq(widen(x.num), widen(x.den), widen(y.num), widen(y.den))
    numer, denom = canonical(numer, denom)
    den = denom%T
    0 < den < typemax(T) || throw(DivideError())
    return FastRational{T}(T(numer), den, Val(true))
end


@inline function addovf(x::FastRational{T}, y::FastRational{T}) where {T<:SUN}
    num1, ovf  = mul_with_overflow(x.num, y.den)
    num2, ovfl = mul_with_overflow(x.den, y.num)
    ovf |= ovfl
    num, ovfl = add_with_overflow(num1, num2)
    ovf |= ovfl
    den, ovfl = mul_with_overflow(x.den, y.den)
    ovf |= ovfl
    return num, den, ovf
end

@inline function subovf(x::FastRational{T}, y::FastRational{T}) where {T<:SUN}
    num1, ovf  = mul_with_overflow(x.num, y.den)
    num2, ovfl = mul_with_overflow(x.den, y.num)
    ovf |= ovfl
    num, ovfl = sub_with_overflow(num1, num2)
    ovf |= ovfl
    den, ovfl = mul_with_overflow(x.den, y.den)
    ovf |= ovfl
    return num, den, ovf
end

@inline function mulovf(x::FastRational{T}, y::FastRational{T}) where {T<:SUN}
    num, ovf  = mul_with_overflow(x.num, y.num)
    den, ovfl = mul_with_overflow(x.den, y.den)
    ovf |= ovfl
    return num, den, ovf
end

@inline function divovf(x::FastRational{T}, y::FastRational{T}) where {T<:SUN}
    num, ovf  = mul_with_overflow(x.num, y.den)
    den, ovfl = mul_with_overflow(x.den, y.num)
    ovf |= ovfl | signbit(den)
    return num, den, ovf
end


@inline function addq(xnum::T, xden::T, ynum::T, yden::T) where {T<:SUN}
    num1 = xnum * yden
    num2 = xden * ynum
    num = num1 + num2
    den = xden * yden
    return num, den
end

@inline function subq(xnum::T, xden::T, ynum::T, yden::T) where {T<:SUN}
    num1 = xnum * yden
    num2 = xden * ynum
    num = num1 - num2
    den = xden * yden
    return num, den
end

@inline function mulq(xnum::T, xden::T, ynum::T, yden::T) where {T<:SUN}
    num = xnum * ynum
    den = xden * yden
    return num, den
end

@inline function divq(xnum::T, xden::T, ynum::T, yden::T) where {T<:SUN}
    num = xnum * yden
    den = xden * ynum
    return num, den
end

import Base.power_by_squaring
function ^(x::FastRational, n::Integer)
    n >= 0 ? power_by_squaring(x,n) : power_by_squaring(inv(x),-n)
end

//(x::FastRational{T}, y::SUN) where {T<:SUN} = x / FastRational{T}(y)
//(x::SUN, y::FastRational{T}) where {T<:SUN} = FastRational{T}(x) / y
//(x::FastRational{T}, y::FastRational{T}) where {T<:SUN} = x / y
//(x::FastRational{T}, y::Rational) where {T<:SUN} = x / FastRational{T}(y)
//(x::Rational, y::FastRational{T}) where {T<:SUN} = FastRational{T}(x) / y

Base.decompose(x::FastRational{T}) where T<:Union{Signed,Unsigned} = Base.decompose(x.num // x.den)

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

typemax(::Type{FastRational{T}}) where {T<:SUN} = FastRational{T}(typemax(T), one(T))
typemin(::Type{FastRational{T}}) where {T<:SUN} = FastRational{T}(typemin(T), one(T))

widen(::Type{FastRational{T}}) where T = FastRational{widen(T)}

FastRational{T}(x::Bool) where {T<:SUN} = x ? one(FastRational{T}) : zero(FastRational{T})
FastRational{T}(x::SUN) where {T<:SUN} = FastRational{T}(T(x), one(T))
Rational(x::FastRational{T}) where {T<:SUN} = Rational{T}(x.num, x.den)
Rational{Q}(x::FastRational{T}) where {Q, T<:SUN} = Rational{Q}(Q(x.num), Q(x.den))

FastQ32(x::Rational{T}) where {T<:Union{Int8, Int16, Int32}} =
    FastQ32(x.num%Int32, x.den%Int32)
FastQ32(x::Rational{T}) where {T<:Union{Int64, Int128}} =
    FastQ32(Int32(x.num), Int32(x.den))
FastQ64(x::Rational{T}) where {T<:Union{Int8, Int16, Int32, Int64}} =
    FastQ64(x.num%Int64, x.den%Int64)
FastQ64(x::Rational{T}) where {T<:Int128} =
    FastQ64(Int64(x.num), Int64(x.den))
FastQ128(x::Rational{T}) where {T<:SUN} =
    FastQ128(Int128(x.num), Int128(x.den))

string(x::FastRational{T}) where {T<:SUN} = string(x.num//x.den)
show(io::IO, x::FastRational{T}) where {T<:SUN} = show(io, x.num//x.den)

zero(::Type{FastRational{T}}) where {T<:SUN} = FastRational{T}(zero(T), one(T))
zero(x::FastRational{T}) where {T<:SUN} = zero(FastRational{T})
one(::Type{FastRational{T}}) where {T<:SUN} = FastRational{T}(one(T), one(T))
one(x::FastRational{T}) where {T<:SUN} = one(FastRational{T})

iszero(x::FastRational{T}) where {T<:SUN} = x.num === zero(T)
isone(x::FastRational{T}) where {T<:SUN} = x.num === x.den
isinteger(x::FastRational{T}) where {T<:SUN} = x.den === one(T) || canonical(x.num, x.den)[2] == one(T)
function iseven(x::FastRational{T}) where {T<:SUN}
    q = x.num//x.den
    return isone(q.den) && iseven(q.num)
end
function isodd(x::FastRational{T}) where {T<:SUN}
    q = x.num//x.den
    return isone(q.den) && isodd(q.num)
end

isfinite(x::FastRational{T}) where T<:SUN = true
isinf(x::FastRational{T}) where T<:SUN = false
isnan(x::FastRational{T}) where T<:SUN = false


signbit(x::FastRational{T}) where {T<:SUN} = xor(signbit(x.num), signbit(x.den))
sign(x::FastRational{T}) where {T<:SUN} = signbit(x) ? FastRational{T}(-one(T), one(T)) : FastRational{T}(one(T), one(T))
abs(x::FastRational{T}) where {T<:SUN} = signbit(x) ? -x : x
abs2(x::FastRational{T}) where {T<:SUN} = x * x
-(x::FastRational{T}) where {T<:SUN} = x.num !== typemin(T) ? FastRational{T}(-x.num, x.den) : FastRational{T}(x.num, -x.den)
inv(x::FastRational{T}) where {T<:SUN} = signbit(x) ? FastRational{T}(-x.den, -x.num) : FastRational{T}(x.den, x.num)

copysign(x::FastRational{T}, y::FastRational{T}) where {T<:SUN} = signbit(y) ? -abs(x) : abs(x)
flipsign(x::FastRational{T}, y::FastRational{T}) where {T<:SUN} = signbit(y) ? -x : x

wider(x::Int8) = x%Int16
wider(x::Int16) = x%Int32
wider(x::Int32) = x%Int64
wider(x::Int64) = x%Int128
wider(x::Int128) = x%BigInt
wider(x::BigInt) = x

==(x::FastRational{BigInt}, y::FastRational{BigInt}) = x.num * y.den == x.den * y.num
!=(x::FastRational{BigInt}, y::FastRational{BigInt}) = x.num * y.den != x.den * y.num

==(x::FastRational{T}, y::FastRational{T}) where {T<:SUN} = wider(x.num) * wider(y.den) === wider(x.den) * wider(y.num)
!=(x::FastRational{T}, y::FastRational{T}) where {T<:SUN} = wider(x.num) * wider(y.den) !== wider(x.den) * wider(y.num)
>=(x::FastRational{T}, y::FastRational{T}) where {T<:SUN} = wider(x.num) * wider(y.den) >= wider(x.den) * wider(y.num)
<=(x::FastRational{T}, y::FastRational{T}) where {T<:SUN} = wider(x.num) * wider(y.den) <= wider(x.den) * wider(y.num)
>(x::FastRational{T}, y::FastRational{T}) where {T<:SUN} = wider(x.num) * wider(y.den) > wider(x.den) * wider(y.num)
<(x::FastRational{T}, y::FastRational{T}) where {T<:SUN} = wider(x.num) * wider(y.den) < wider(x.den) * wider(y.num)

isequal(x::FastRational{T}, y::FastRational{T}) where {T<:SUN} = wider(x.num) * wider(y.den) === wider(x.den) * wider(y.num)
isless(x::FastRational{T}, y::FastRational{T}) where {T<:SUN} = wider(x.num) * wider(y.den) < wider(x.den) * wider(y.num)

cmp(x::FastRational{T}, y::FastRational{T}) where {T<:SUN} = (y<=x) - (x<=y)
    
function +(x::FastRational{T}, y::FastRational{T}) where {T<:SUN}
    num, den, ovf = addovf(x, y)
    !ovf && return FastRational{T}(num, den)
    numer, denom = addq(wider(x.num), wider(x.den), wider(y.num), wider(y.den))
    numer, denom = canonical(numer, denom)
    return FastRational{T}(T(numer), T(denom))
end

function -(x::FastRational{T}, y::FastRational{T}) where {T<:SUN}
    num, den, ovf = subovf(x, y)
    !ovf && return FastRational{T}(num, den)
    numer, denom = subq(wider(x.num), wider(x.den), wider(y.num), wider(y.den))
    numer, denom = canonical(numer, denom)
    return FastRational{T}(T(numer), T(denom))
end

function *(x::FastRational{T}, y::FastRational{T}) where {T<:SUN}
    num, den, ovf = mulovf(x, y)
    !ovf && return FastRational{T}(num, den)
    numer, denom = mulq(wider(x.num), wider(x.den), wider(y.num), wider(y.den))
    numer, denom = canonical(numer, denom)
    return FastRational{T}(T(numer), T(denom))
end

function /(x::FastRational{T}, y::FastRational{T}) where {T<:SUN}
    num, den, ovf = divovf(x, y)
    !ovf && return FastRational{T}(num, den)
    numer, denom = divq(wider(x.num), wider(x.den), wider(y.num), wider(y.den))
    numer, denom = canonical(numer, denom)
    return FastRational{T}(T(numer), T(denom))
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
    ovf |= ovfl
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

function ^(x::FastRational{T}, y::SUN) where {T<:SUN}
    num, den = wider(x.num)^y, wider(x.den)^y
    num, den = canonical(num, den)
    return FastRational{T}(T(num), T(den))
end

//(x::FastRational{T}, y::SUN) where {T<:SUN} = x / FastRational{T}(y)
//(x::SUN, y::FastRational{T}) where {T<:SUN} = FastRational{T}(x) / y
//(x::FastRational{T}, y::FastRational{T}) where {T<:SUN} = x / y
//(x::FastRational{T}, y::Rational) where {T<:SUN} = x / FastRational{T}(y)
//(x::Rational, y::FastRational{T}) where {T<:SUN} = FastRational{T}(x) / y

Base.decompose(x::FastRational{T}) where T<:Union{Signed,Unsigned} = Base.decompose(x.num // x.den)

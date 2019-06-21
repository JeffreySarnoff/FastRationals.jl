module FastRationals

export FastRational

using Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow

import Base: hash, show, repr, string, tryparse,
    zero, one, iszero, isone, isinteger,
    numerator, denominator, eltype, convert, promote_rule, decompose,
    isinteger, typemax, typemin, sign, signbit, copysign, flipsign, abs, float,
    ==, !=, <, <=, >=, >,
    +, -, *, /, ^, //, 
    inv, div, fld, cld, rem, mod, trunc, floor, ceil, round

struct FastRational <: Real
    num::Int32
    den::Int32
end

numerator(x::FastRational) = x.num
denominator(x::FastRational) = x.den

typemax(::Type{FastRational}) = FastRational(typemax(Int32), one(Int32))
typemin(::Type{FastRational}) = FastRational(typemin(Int32), one(Int32))

FastRational(x::Rational{Int32}) = FastRational(x.num, x.den)
FastRational(x::Rational{T}) where {T<:Union{Int8, Int16}} =
    FastRational(x.num%Int32, x.den%Int32)
FastRational(x::Rational{T}) where {T<:Union{Int64, Int128, BigInt}} =
    FastRational(Int32(x.num), Int32(x.den))

FastRational(x::NTuple{2,T}) where {T<:Signed} = FastRational(x[1]//x[2])

FastRational(x::Int32) = FastRational(x.num, one(Int32))
FastRational(x::T) where {T<:Union{Int8, Int16}} =
    FastRational(x%Int32, one(Int32))
FastRational(x::T) where {T<:Union{Int64, Int128, BigInt}} =
    FastRational(Int32(x), one(Int32))
FastRational(x::Bool) = x ? one(FastRational) : zero(FastRational)

Rational(x::FastRational) = x.num//x.den
Rational{Int32}(x::FastRational) = x.num//x.den
Rational{T}(x::FastRational) where {T} = (T)(x.num)//(T)(x.den)

promote_rule(::Type{Rational{T}}, ::Type{FastRational}) where {T} = FastRational
convert(::Type{FastRational}, x::Rational{T}) where {T} = FastRational(x)
promote_rule(::Type{FastRational}, ::Type{Float64}) = Float64
convert(::Type{Float64}, x::FastRational) = x.num / x.den
promote_rule(::Type{FastRational}, ::Type{Float32}) = Float32
convert(::Type{Float32}, x::FastRational) = Float32(x.num / x.den)

show(io::IO, x::FastRational) = show(io, Rational{Int32}(x))
string(x::FastRational) = string(Rational{Int32}(x))

zero(::Type{FastRational}) = FastRational(zero(Int32), one(Int32))
zero(x::FastRational) = zero(FastRational)
one(::Type{FastRational}) = FastRational(one(Int32), one(Int32))
one(x::FastRational) = one(FastRational)

iszero(x::FastRational) = x.num === zero(Int32)
isone(x::FastRational) = x.num === x.den
isinteger(x::FastRational) = x.den == one(Int32) || canonical(x.num, x.den)[2] == one(Int32)

signbit(x::FastRational) = signbit(x.num) !== signbit(x.den)
sign(x::FastRational) = FastRational(ifelse(signbit(x), -one(Int32), one(Int32)), one(Int32))
abs(x::FastRational) = x.den !== typemin(Int32) ? FastRational(abs(x.num), abs(x.den)) :
                                                  throw(ErrorException("abs(x//typemin) is disallowed"))
-(x::FastRational) = x.den !== typemin(Int32) ? FastRational(-x.num, x.den) : throw(ErrorException("-(x//typemin) is disallowed"))

copysign(x::FastRational, y::FastRational) = signbit(x) === signbit(y) ? x : -x
copysign(x::FastRational, y::T) where {T<:Union{Rational,Integer}} = signbit(x) === signbit(y) ? x : -x
flipsign(x::FastRational, y::FastRational) = signbit(y) ? -x : x
flipsign(x::FastRational, y::T) where {T<:Union{Rational,Integer}} = signbit(y) ? -x : x

function inv(x::FastRational)
    num, den = flipsign(x.den, x.num), abs(x.num)
    return FastRational(num, den)
end

(==)(x::FastRational, y::FastRational) =
    x.num%Int64 * y.den%Int64 === x.den%Int64 * y.num%Int64
(!=)(x::FastRational, y::FastRational) =
    x.num%Int64 * y.den%Int64 !== x.den%Int64 * y.num%Int64
(<)(x::FastRational, y::FastRational) =
    x.num%Int64 * y.den%Int64 < x.den%Int64 * y.num%Int64
(<=)(x::FastRational, y::FastRational) =
    x.num%Int64 * y.den%Int64 <= x.den%Int64 * y.num%Int64
(>=)(x::FastRational, y::FastRational) =
    x.num%Int64 * y.den%Int64 >= x.den%Int64 * y.num%Int64
(>)(x::FastRational, y::FastRational) =
    x.num%Int64 * y.den%Int64 > x.den%Int64 * y.num%Int64

# core parts of add, sub, mul, div

@inline function addovf(x::FastRational, y::FastRational)
    ovf = false
    numer, ovfl = mul_with_overflow(x.num, y.den) # here, numer is a temp
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, y.num) # here, denom is a temp
    ovf |= ovfl
    numer, ovfl = add_with_overflow(numer, denom) # numerator of sum
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, y.den) # denominator of sum
    ovf |= ovfl
    return numer, denom, ovf
end

@inline function addq(xnum::Int64, xden::Int64, ynum::Int64, yden::Int64)
    numer = xnum * yden   # here, numer is a temp
    denom = xden * ynum   # here, denom is a temp
    numer = numer + denom # numerator of sum
    denom = xden * yden   # denominator of sum
    return numer, denom
end

@inline function subovf(x::FastRational, y::FastRational)
    ovf = false
    numer, ovfl = mul_with_overflow(x.num, y.den) # here, numer is a temp
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, y.num) # here, denom is a temp
    ovf |= ovfl
    numer, ovfl = sub_with_overflow(numer, denom) # numerator of difference
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, y.den) # denominator of difference
    ovf |= ovfl
    return numer, denom, ovf
end

@inline function subq(xnum::Int64, xden::Int64, ynum::Int64, yden::Int64)
    numer = xnum * yden   # here, numer is a temp
    denom = xden * ynum   # here, denom is a temp
    numer = numer - denom # numerator of difference
    denom = xden * yden   # denominator of difference
    return numer, denom
end


@inline function mulovf(x::FastRational, y::FastRational)
    ovf = false
    numer, ovfl = mul_with_overflow(x.num, y.num)
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, y.den)
    ovf |= ovfl
    return numer, denom, ovf
end

@inline function mulq(xnum::Int64, xden::Int64, ynum::Int64, yden::Int64)
    numer = xnum * ynum
    denom = xden * yden
    return numer, denom
end

@inline function divovf(x::FastRational, y::FastRational)
    ovf = false
    numer, ovfl = mul_with_overflow(x.num, y.den)
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, y.num)
    ovf |= ovfl
    return numer, denom, ovf
end

@inline function divq(xnum::Int64, xden::Int64, ynum::Int64, yden::Int64)
    numer = xnum * yden
    denom = xden * ynum
    return numer, denom
end

function +(x::FastRational, y::FastRational)
    num, den, ovf = addovf(x, y)
    !ovf && return FastRational(num, den)
    num, den = addq(x.num%Int64, x.den%Int64, y.num%Int64, y.den%Int64)
    num, den = canonical(num, den)
    return FastRational(Int32(num), Int32(den))
end

function -(x::FastRational, y::FastRational)
    num, den, ovf = subovf(x, y)
    !ovf && return FastRational(num, den)
    num, den = subq(x.num%Int64, x.den%Int64, y.num%Int64, y.den%Int64)
    num, den = canonical(num, den)
    return FastRational(Int32(num), Int32(den))
end

function *(x::FastRational, y::FastRational)
    num, den, ovf = mulovf(x, y)
    !ovf && return FastRational(num, den)
    num, den = mulq(x.num%Int64, x.den%Int64, y.num%Int64, y.den%Int64)
    num, den = canonical(num, den)
    return FastRational(Int32(num), Int32(den))
end

function /(x::FastRational, y::FastRational)
    num, den, ovf = divovf(x, y)
    !ovf && return FastRational(num, den)
    num, den = divq(x.num%Int64, x.den%Int64, y.num%Int64, y.den%Int64)
    num, den = canonical(num, den)
    return FastRational(Int32(num), Int32(den))
end


//(x::FastRational, y::Integer) = x / FastRational(y)
//(x::Integer, y::FastRational) = FastRational(x) / y
//(x::FastRational, y::FastRational) = x / y
//(x::FastRational, y::Rational) = x / FastRational(y)
//(x::Rational, y::FastRational) = FastRational(x) / y

float(x::FastRational) = x.num / x.den
Base.Float64(x::FastRational)  = float(x)
Base.Float32(x::FastRational)  = Float32(float(x))
Base.Float16(x::FastRational)  = Float16(float(x))
Base.BigFloat(x::FastRational) = BigFloat(x.num) / BigFloat(x.den)
Base.BigInt(x::FastRational)   = BigInt(Rational(x))

function canonical(num::T, den::T) where {T}
    num, den = flipsign(num, den), abs(den)
    gcdval = gcd(num, den)
    gcdval === one(T) && return num, den
    num = div(num, gcdval)
    den = div(den, gcdval)
    return num, den
end

decompose(x::FastRational) = x.num, zero(Int32), x.den

hash(x::FastRational) = xor(hash(x.num+x.den), (hash(x.num-x.den))

end # FastRationals

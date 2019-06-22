struct FastQ64 <: FastRational
    num::Int64
    den::Int64
end

basetype(::Type{FastQ64}) = Int64
basetype(x::FastQ64) = Int64

typemax(::Type{FastQ64}) = FastQ64(typemax(Int64), one(Int64))
typemin(::Type{FastQ64}) = FastQ64(typemin(Int64), one(Int64))

FastQ64(x::Rational{Int64}) = FastQ64(x.num, x.den)
FastQ64(x::Rational{T}) where {T<:Union{Int8, Int16}} =
    FastQ64(x.num%Int64, x.den%Int64)
FastQ64(x::Rational{T}) where {T<:Union{Int128, Int128, BigInt}} =
    FastQ64(Int64(x.num), Int64(x.den))

FastQ64(x::NTuple{2,T}) where {T<:Signed} = FastQ64(x[1]//x[2])

FastQ64(x::Int64) = FastQ64(x.num, one(Int64))
FastQ64(x::T) where {T<:Union{Int8, Int16}} =
    FastQ64(x%Int64, one(Int64))
FastQ64(x::T) where {T<:Union{Int128, Int128, BigInt}} =
    FastQ64(Int64(x), one(Int64))
FastQ64(x::Bool) = x ? one(FastQ64) : zero(FastQ64)

Rational(x::FastQ64) = x.num//x.den
Rational{Int64}(x::FastQ64) = x.num//x.den
Rational{T}(x::FastQ64) where {T} = (T)(x.num)//(T)(x.den)

show(io::IO, x::FastQ64) = show(io, Rational{Int64}(x))
string(x::FastQ64) = string(Rational{Int64}(x))

zero(::Type{FastQ64}) = FastQ64(zero(Int64), one(Int64))
zero(x::FastQ64) = zero(FastQ64)
one(::Type{FastQ64}) = FastQ64(one(Int64), one(Int64))
one(x::FastQ64) = one(FastQ64)

iszero(x::FastQ64) = x.num === zero(Int64)
isone(x::FastQ64) = x.num === x.den
isinteger(x::FastQ64) = x.den == one(Int64) || canonical(x.num, x.den)[2] == one(Int64)

signbit(x::FastQ64) = signbit(x.num) !== signbit(x.den)
sign(x::FastQ64) = FastQ64(ifelse(signbit(x), -one(Int64), one(Int64)), one(Int64))
abs(x::FastQ64) = x.den !== typemin(Int64) ? FastQ64(abs(x.num), abs(x.den)) :
                                                  throw(ErrorException("abs(x//typemin) is disallowed"))
-(x::FastQ64) = x.den !== typemin(Int64) ? FastQ64(-x.num, x.den) : throw(ErrorException("-(x//typemin) is disallowed"))

copysign(x::FastQ64, y::FastQ64) = signbit(x) === signbit(y) ? x : -x
copysign(x::FastQ64, y::T) where {T<:Union{Rational,Integer}} = signbit(x) === signbit(y) ? x : -x
flipsign(x::FastQ64, y::FastQ64) = signbit(y) ? -x : x
flipsign(x::FastQ64, y::T) where {T<:Union{Rational,Integer}} = signbit(y) ? -x : x

function inv(x::FastQ64)
    num, den = flipsign(x.den, x.num), abs(x.num)
    return FastQ64(num, den)
end

(==)(x::FastQ64, y::FastQ64) =
    x.num%Int128 * y.den%Int128 === x.den%Int128 * y.num%Int128
(!=)(x::FastQ64, y::FastQ64) =
    x.num%Int128 * y.den%Int128 !== x.den%Int128 * y.num%Int128
(<)(x::FastQ64, y::FastQ64) =
    x.num%Int128 * y.den%Int128 < x.den%Int128 * y.num%Int128
(<=)(x::FastQ64, y::FastQ64) =
    x.num%Int128 * y.den%Int128 <= x.den%Int128 * y.num%Int128
(>=)(x::FastQ64, y::FastQ64) =
    x.num%Int128 * y.den%Int128 >= x.den%Int128 * y.num%Int128
(>)(x::FastQ64, y::FastQ64) =
    x.num%Int128 * y.den%Int128 > x.den%Int128 * y.num%Int128

# core parts of add, sub, mul, div

@inline function addovf(x::FastQ64, y::FastQ64)
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

@inline function addq(xnum::Int128, xden::Int128, ynum::Int128, yden::Int128)
    numer = xnum * yden   # here, numer is a temp
    denom = xden * ynum   # here, denom is a temp
    numer = numer + denom # numerator of sum
    denom = xden * yden   # denominator of sum
    return numer, denom
end

@inline function subovf(x::FastQ64, y::FastQ64)
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

@inline function subq(xnum::Int128, xden::Int128, ynum::Int128, yden::Int128)
    numer = xnum * yden   # here, numer is a temp
    denom = xden * ynum   # here, denom is a temp
    numer = numer - denom # numerator of difference
    denom = xden * yden   # denominator of difference
    return numer, denom
end


@inline function mulovf(x::FastQ64, y::FastQ64)
    ovf = false
    numer, ovfl = mul_with_overflow(x.num, y.num)
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, y.den)
    ovf |= ovfl
    return numer, denom, ovf
end

@inline function mulq(xnum::Int128, xden::Int128, ynum::Int128, yden::Int128)
    numer = xnum * ynum
    denom = xden * yden
    return numer, denom
end

@inline function divovf(x::FastQ64, y::FastQ64)
    ovf = false
    numer, ovfl = mul_with_overflow(x.num, y.den)
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, y.num)
    ovf |= ovfl
    return numer, denom, ovf
end

@inline function divq(xnum::Int128, xden::Int128, ynum::Int128, yden::Int128)
    numer = xnum * yden
    denom = xden * ynum
    return numer, denom
end

function +(x::FastQ64, y::FastQ64)
    num, den, ovf = addovf(x, y)
    !ovf && return FastQ64(num, den)
    num, den = addq(x.num%Int128, x.den%Int128, y.num%Int128, y.den%Int128)
    num, den = canonical(num, den)
    return FastQ64(Int64(num), Int64(den))
end

function -(x::FastQ64, y::FastQ64)
    num, den, ovf = subovf(x, y)
    !ovf && return FastQ64(num, den)
    num, den = subq(x.num%Int128, x.den%Int128, y.num%Int128, y.den%Int128)
    num, den = canonical(num, den)
    return FastQ64(Int64(num), Int64(den))
end

function *(x::FastQ64, y::FastQ64)
    num, den, ovf = mulovf(x, y)
    !ovf && return FastQ64(num, den)
    num, den = mulq(x.num%Int128, x.den%Int128, y.num%Int128, y.den%Int128)
    num, den = canonical(num, den)
    return FastQ64(Int64(num), Int64(den))
end

function /(x::FastQ64, y::FastQ64)
    num, den, ovf = divovf(x, y)
    !ovf && return FastQ64(num, den)
    num, den = divq(x.num%Int128, x.den%Int128, y.num%Int128, y.den%Int128)
    num, den = canonical(num, den)
    return FastQ64(Int64(num), Int64(den))
end

function ^(x::FastQ64, y::Integer)
    num, den = x.num%Int128^y, x.den%Int128^y
    num, den = canonical(num, den)
    return FastQ64(Int64(num), Int64(den))
end

//(x::FastQ64, y::Integer) = x / FastQ64(y)
//(x::Integer, y::FastQ64) = FastQ64(x) / y
//(x::FastQ64, y::FastQ64) = x / y
//(x::FastQ64, y::Rational) = x / FastQ64(y)
//(x::Rational, y::FastQ64) = FastQ64(x) / y

float(x::FastQ64) = x.num / x.den
Base.Float64(x::FastQ64)  = float(x)
Base.Float32(x::FastQ64)  = Float32(float(x))
Base.Float16(x::FastQ64)  = Float16(float(x))
Base.BigFloat(x::FastQ64) = BigFloat(x.num) / BigFloat(x.den)
Base.BigInt(x::FastQ64)   = BigInt(Rational(x))

decompose(x::FastQ64) = x.num, zero(Int64), x.den

hash(x::FastQ64) = xor(hash(x.num+x.den), (hash(x.num-x.den)))

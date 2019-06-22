basetype(::Type{FastQ32}) = Int32
basetype(x::FastQ32) = Int32

typemax(::Type{FastQ32}) = FastQ32(typemax(Int32), one(Int32))
typemin(::Type{FastQ32}) = FastQ32(typemin(Int32), one(Int32))

FastQ32(x::Rational{Int32}) = FastQ32(x.num, x.den)
FastQ32(x::Rational{T}) where {T<:Union{Int8, Int16}} =
    FastQ32(x.num%Int32, x.den%Int32)
FastQ32(x::Rational{T}) where {T<:Union{Int64, Int128, BigInt}} =
    FastQ32(Int32(x.num), Int32(x.den))

FastQ32(x::NTuple{2,T}) where {T<:Signed} = FastQ32(x[1]//x[2])

FastQ32(x::Int32) = FastQ32(x.num, one(Int32))
FastQ32(x::T) where {T<:Union{Int8, Int16}} =
    FastQ32(x%Int32, one(Int32))
FastQ32(x::T) where {T<:Union{Int64, Int64, BigInt}} =
    FastQ32(Int32(x), one(Int32))
FastQ32(x::Bool) = x ? one(FastQ32) : zero(FastQ32)

Rational(x::FastQ32) = x.num//x.den
Rational{Int32}(x::FastQ32) = x.num//x.den
Rational{T}(x::FastQ32) where {T} = (T)(x.num)//(T)(x.den)

show(io::IO, x::FastQ32) = show(io, Rational{Int32}(x))
string(x::FastQ32) = string(Rational{Int32}(x))

zero(::Type{FastQ32}) = FastQ32(zero(Int32), one(Int32))
zero(x::FastQ32) = zero(FastQ32)
one(::Type{FastQ32}) = FastQ32(one(Int32), one(Int32))
one(x::FastQ32) = one(FastQ32)

iszero(x::FastQ32) = x.num === zero(Int32)
isone(x::FastQ32) = x.num === x.den
isinteger(x::FastQ32) = x.den == one(Int32) || canonical(x.num, x.den)[2] == one(Int32)

signbit(x::FastQ32) = signbit(x.num) !== signbit(x.den)
sign(x::FastQ32) = FastQ32(ifelse(signbit(x), -one(Int32), one(Int32)), one(Int32))
abs(x::FastQ32) = x.den !== typemin(Int32) ? FastQ32(abs(x.num), abs(x.den)) :
                                                  throw(ErrorException("abs(x//typemin) is disallowed"))
-(x::FastQ32) = x.den !== typemin(Int32) ? FastQ32(-x.num, x.den) : throw(ErrorException("-(x//typemin) is disallowed"))

copysign(x::FastQ32, y::FastQ32) = signbit(x) === signbit(y) ? x : -x
copysign(x::FastQ32, y::T) where {T<:Union{Rational,Integer}} = signbit(x) === signbit(y) ? x : -x
flipsign(x::FastQ32, y::FastQ32) = signbit(y) ? -x : x
flipsign(x::FastQ32, y::T) where {T<:Union{Rational,Integer}} = signbit(y) ? -x : x

function inv(x::FastQ32)
    num, den = flipsign(x.den, x.num), abs(x.num)
    return FastQ32(num, den)
end

(==)(x::FastQ32, y::FastQ32) =
    x.num%Int64 * y.den%Int64 === x.den%Int64 * y.num%Int64
(!=)(x::FastQ32, y::FastQ32) =
    x.num%Int64 * y.den%Int64 !== x.den%Int64 * y.num%Int64
(<)(x::FastQ32, y::FastQ32) =
    x.num%Int64 * y.den%Int64 < x.den%Int64 * y.num%Int64
(<=)(x::FastQ32, y::FastQ32) =
    x.num%Int64 * y.den%Int64 <= x.den%Int64 * y.num%Int64
(>=)(x::FastQ32, y::FastQ32) =
    x.num%Int64 * y.den%Int64 >= x.den%Int64 * y.num%Int64
(>)(x::FastQ32, y::FastQ32) =
    x.num%Int64 * y.den%Int64 > x.den%Int64 * y.num%Int64

# core parts of add, sub, mul, div

@inline function addovf(x::FastQ32, y::FastQ32)
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

@inline function subovf(x::FastQ32, y::FastQ32)
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


@inline function mulovf(x::FastQ32, y::FastQ32)
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

@inline function divovf(x::FastQ32, y::FastQ32)
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

function +(x::FastQ32, y::FastQ32)
    num, den, ovf = addovf(x, y)
    !ovf && return FastQ32(num, den)
    num, den = addq(x.num%Int64, x.den%Int64, y.num%Int64, y.den%Int64)
    num, den = canonical(num, den)
    return FastQ32(Int32(num), Int32(den))
end

function -(x::FastQ32, y::FastQ32)
    num, den, ovf = subovf(x, y)
    !ovf && return FastQ32(num, den)
    num, den = subq(x.num%Int64, x.den%Int64, y.num%Int64, y.den%Int64)
    num, den = canonical(num, den)
    return FastQ32(Int32(num), Int32(den))
end

function *(x::FastQ32, y::FastQ32)
    num, den, ovf = mulovf(x, y)
    !ovf && return FastQ32(num, den)
    num, den = mulq(x.num%Int64, x.den%Int64, y.num%Int64, y.den%Int64)
    num, den = canonical(num, den)
    return FastQ32(Int32(num), Int32(den))
end

function /(x::FastQ32, y::FastQ32)
    num, den, ovf = divovf(x, y)
    !ovf && return FastQ32(num, den)
    num, den = divq(x.num%Int64, x.den%Int64, y.num%Int64, y.den%Int64)
    num, den = canonical(num, den)
    return FastQ32(Int32(num), Int32(den))
end

function ^(x::FastQ32, y::Integer)
    num, den = (x.num%Int64)^y, (x.den%Int64)^y
    num, den = canonical(num, den)
    return FastQ32(Int32(num), Int32(den))
end

//(x::FastQ32, y::Integer) = x / FastQ32(y)
//(x::Integer, y::FastQ32) = FastQ32(x) / y
//(x::FastQ32, y::FastQ32) = x / y
//(x::FastQ32, y::Rational) = x / FastQ32(y)
//(x::Rational, y::FastQ32) = FastQ32(x) / y

decompose(x::FastQ32) = x.num, zero(Int32), x.den

hash(x::FastQ32) = xor(hash(x.num+x.den), (hash(x.num-x.den)))

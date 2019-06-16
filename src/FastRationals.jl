module FastRationals

export FastRational

using Base: BitInteger, BitSigned, BitUnsigned

using Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow,
    checked_neg, checked_abs, checked_add, checked_sub, checked_mul,
    checked_div, checked_rem, checked_fld, checked_mod, checked_cld

import Base: hash, show, repr, string, tryparse,
    zero, one, iszero, isone,
    numerator, denominator, eltype, convert, promote_rule, decompose,
    isinteger, typemax, typemin, sign, signbit, copysign, flipsign, abs, float,
    ==, !=, <, <=, >=, >,
    +, -, *, /, ^, //, 
    inv, div, fld, cld, rem, mod, trunc, floor, ceil, round

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

"""
    FastRational <: Real


### fields 

`num`: the rational numerator      (zero and signed integer values)
`den`: the rational denominator    (strictly positive integer values)

"""
struct FastRational{T<:BitInteger, H<:RationalState} <: Real
    num::T
    den::T
end

#=  
    FastRational constructors *never*  process 2Tupled pairs
        `num`, `den` already must be reduced to lowest terms
         ( (num::T, den::T) ) ↦ (num, den)

    FastRational constructors *always* process untupled pairs 
        `num`, `den` may not yet be reduced to lowest terms
         (num, den) ↦ canonical(num, den)  ↦ (num, den)
=#


FastRational(x::NTuple{2,T}) where {T<:BitInteger} = FastRational{T,IsReduced}(x[1], x[2])
FastRational(num::T, den::T) where {T<:BitInteger} = FastRational(canonical(num, den))


numerator(x::FastRational{T,H})   where {T,H} = x.num
denominator(x::FastRational{T,H}) where {T,H} = x.den
numerdenom(x::FastRational{T,H})  where {T,H} = x.num, x.den



basistype(::Type{FastRational{T,IsReduced}}) where T = T
basistype(::Type{FastRational{T,MayReduce}}) where T = T
basistype(::Type{Rational{T}}) where T = T


FastRational(x::FastRational{T,IsReduced}) where {T} = x
FastRational(x::FastRational{T,MayReduce}) where {T} = FastRational(canonical(x.num, x.den))



FastRational(x::Rational{T}) where {T} = FastRational{T,IsReduced}(x.num, x.den)
FastRational(x::T) where {T<:Integer} = FastRational(x, one(T))
FastRational(x::T) where {T<:Rational} = FastRational(x)
FastRational(x::T) where {T<:Real} = FastRational(rationalize(x))
FastRational{T}(x::T) where {T} = FastRational{T,IsReduced}(x)

FastRational{T,IsReduced}(x::Rational{T}) where {T} = FastRational{T,IsReduced}(x.num, x.den)
FastRational{T,MayReduce}(x::Rational{T}) where {T} = FastRational{T,IsReduced}(x.num, x.den)
FastRational{T1,IsReduced}(x::Rational{T2}) where {T1<:BitInteger,T2} = FastRational{T1,IsReduced}(T1(x.num), T1(x.den))
FastRational{T1,MayReduce}(x::Rational{T2}) where {T1<:BitInteger,T2} = FastRational{T1,IsReduced}(T1(x.num), T1(x.den))

FastRational{T,IsReduced}(x::T) where {T<:BitInteger} = FastRational{T,IsReduced}(x, one(T))
FastRational{T,MayReduce}(x::T) where {T<:BitInteger} = FastRational{T,IsReduced}(x, one(T))
FastRational{T1,IsReduced}(x::T2) where {T1<:BitInteger,T2} = FastRational{T1,IsReduced}(T1(x), one(T1))
FastRational{T1,MayReduce}(x::T2) where {T1<:BitInteger,T2} = FastRational{T1,IsReduced}(T1(x), one(T1))

FastRational{T1,IsReduced}(x::FastRational{T2,IsReduced},y::FastRational{T2,IsReduced}) where {T1<:BitInteger,T2} = FastRational{T1,IsReduced}(T1(x.num), T1(x.den))
FastRational{T1,MayReduce}(x::FastRational{T2,IsReduced},y::FastRational{T2,IsReduced}) where {T1<:BitInteger,T2} = FastRational{T1,IsReduced}(T1(x.num), T1(x.den))
FastRational{T1,IsReduced}(x::FastRational{T2,MayReduce},y::FastRational{T2,MayReduce}) where {T1<:BitInteger,T2} = FastRational{T1,IsReduced}(canonical(T1(x.num), T1(x.den)))
FastRational{T1,MayReduce}(x::FastRational{T2,MayReduce},y::FastRational{T2,MayReduce}) where {T1<:BitInteger,T2} = FastRational{T1,IsReduced}(canonical(T1(x.num), T1(x.den)))
FastRational{T1,IsReduced}(x::FastRational{T2,IsReduced},y::FastRational{T2,MayReduce}) where {T1<:BitInteger,T2} = FastRational{T1,IsReduced}(T1(x.num), T1(x.den))
FastRational{T1,MayReduce}(x::FastRational{T2,MayReduce},y::FastRational{T2,IsReduced}) where {T1<:BitInteger,T2} = FastRational{T1,IsReduced}(T1(x.num), T1(x.den))

FastRational{T,H}(x::FastRational{T,IsReduced},y::FastRational{T,MayReduce}) where {T<:BitInteger,H} = FastRational{T,IsReduced}(canonical(T(x.num), T(x.den)))
FastRational{T,H}(x::FastRational{T,MayReduce},y::FastRational{T,IsReduced}) where {T<:BitInteger,H} = FastRational{T,IsReduced}(canonical(T(x.num), T(x.den)))

#=
FastRational{Int64,H}(x::FastRational{Int64,IsReduced}, y::FastRational{Int64,MayReduce}) where {H<:Main.FastRationals.RationalState} =
    x * inv(FastRational(canonical(y)))
FastRational{Int64,H}(x::FastRational{Int64,MayReduce}, y::FastRational{Int64,IsReduced}) where {H<:Main.FastRationals.RationalState} =
    FastRational(canonical(x) * inv(y)
=#
FastRational{T,H}(x::FastRational{T,IsReduced}, y::FastRational{T,MayReduce}) where {T,H<:RationalState} =
    x * inv(FastRational(canonical(y)))
FastRational{T,H}(x::FastRational{T,MayReduce}, y::FastRational{T,IsReduced}) where {T,H<:RationalState} =
    FastRational(canonical(x) * inv(y))

Rational(x::FastRational{T,IsReduced}) where {T} = Rational{T}(x.num, x.den)
Rational(x::FastRational{T,MayReduce}) where {T} = Rational{T}(canonical(x.num, x.den))
Rational{T}(x::FastRational{T,IsReduced}) where {T} = Rational{T}(x.num, x.den)
Rational{T}(x::FastRational{T,MayReduce}) where {T} = Rational{T}(canonical(x.num, x.den))

//(x::FastRational{T,H}, y::Integer) where {T,H} = x / FastRational(y)
//(x::Integer, y::FastRational{T,H}) where {T,H} = FastRational(x) / y
//(x::FastRational, y::FastRational) = x / y
//(x::FastRational{T,H}, y::Rational) where {T,H} = x / FastRational(y)
//(x::Rational, y::FastRational{T,H}) where {T,H} = FastRational(x) / y


float(x::FastRational{T,H}) where {T,H} = float(Rational(x))
Base.Float64(x::FastRational{T,H}) where {T,H} = Float64(Rational(x))
Base.Float32(x::FastRational{T,H}) where {T,H} = Float32(Rational(x))
Base.BigFloat(x::FastRational{T,H}) where {T,H} = BigFloat(Rational(x))
Base.BigInt(x::FastRational{T,H}) where {T,H} = BigInt(Rational(x))

include("canonical.jl")

include("promote_convert.jl")
# ------------- promotion rules and conversion logic above has been reviewed

# convert(::Type{Rational{T}}, x::FastRational{T,H}) where {T,H<:RationalState} = Rational(canonical(x.num, x.den))

convert(::Type{FastRational{T,H}}, x::T) where {T,H} = FastRational{T,IsReduced}(x, one(T))
convert(::Type{FastRational{T1,H}}, x::T2) where {T1,T2<:Integer,H} = FastRational{T1,IsReduced}(T1(x), one(T1))
convert(::Type{FastRational{T1,H}}, x::Rational{T2}) where {T1,T2,H} =
    FastRational{T1,IsReduced}(T1(x.num), T1(x.den))
# disambiguate
convert(::Type{FastRational{T,H}}, x::FastRational{T,H}) where {T,H} = x
convert(::Type{FastRational{T,IsReduced}}, x::FastRational{T,MayReduce}) where {T} = FastRational(x)
convert(::Type{FastRational{T,MayReduce}}, x::FastRational{T,IsReduced}) where {T} = x

convert(::Type{FastRational{T,H}}, x::AbstractFloat) where {T,H} = FastRational(convert(Rational{T}, x))
convert(::Type{F}, x::FastRational{T,H}) where {T,H,F<:AbstractFloat} = F(convert(Rational{T}, x))



zero(::Type{FastRational{T,H}}) where {T,H} = FastRational{T,IsReduced}(zero(T), one(T))
one(::Type{FastRational{T,H}}) where {T,H} = FastRational{T,IsReduced}(one(T), one(T))


signbit(x::FastRational{T,H}) where {T<:Signed, H} = signbit(x.num) !== signbit(x.den)
sign(x::FastRational{T,H}) where {T<:Signed, H} = FastRational{T,IsReduced}(signbit(x) ? -one(T) : one(T))
abs(x::FastRational{T,IsReduced}) where {T<:Signed} = FastRational{T,IsReduced}(abs(x.num), x.den)
abs(x::FastRational{T,MayReduce}) where {T<:Signed} = FastRational{T,IsReduced}(abs(x.num), abs(x.den))

signbit(x::FastRational{T,H}) where {T<:Unsigned, H} = false
sign(x::FastRational{T,H}) where {T<:Unsigned, H} = FastRational{T,IsReduced}(one(T), one(T))
abs(x::FastRational{T,H}) where {T<:Unsigned, H} = x



# optimize for FastRational{Int32} using Int64 cross-multiplication for comparisons
@inline mulwider(x::T, y::T) where {T<:Integer} = widemul(x,y)
    
(==)(x::FastRational{T,IsReduced}, y::FastRational{T,IsReduced}) where {T} =
    x.num === y.num && x.den === y.den
(!=)(x::FastRational{T,IsReduced}, y::FastRational{T,IsReduced}) where {T} =
    x.num !== y.num || x.den !== y.den

for F in (:(==), :(!=), :(<), :(<=), :(>=), :(>))
  @eval $F(x::FastRational{T,H1}, y::FastRational{T,H2}) where {T,H1, H2} =
    $F(mulwider(x.num, y.den), mulwider(x.den, y.num))
end

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

inv(x::FastRational{T,IsReduced}) where {T<:BitInteger} =
   FastRational{T,IsReduced}(x.den, x.num)
inv(x::FastRational{T,MayReduce}) where {T<:BitInteger} =
   FastRational{T,MayReduce}(x.den, x.num)
        
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

const Solidus = "//"
const Solunos = "╱"

function string(x::FastRational{T,IsReduced}) where {T}
    return string(x.num,Solidus,x.den)
end

function string(x::FastRational{T,MayReduce}) where {T}
    num, den = canonical(x.num, x.den)
    return string(num,Solidus,den)
end

function show(io::IO, x::FastRational{T,H}) where {T,H}
    print(io, string(x))
end

function repr(x::FastRational{T,H}) where {T,H}
    return repr(Rational(x))
end

function tryparse(::Type{FastRational{T,H}}, s::String) where {T,H}
    if !occursin(Solunos, s)
        if !occursin(Solidus, s)
            num = tryparse(T, s)
            num = isnothing(num) : one(T) : num
            FastRational{T,IsReduced}(canonical(num, one(T)))
        else
            num, den = String.(split(s,Solidus))
            num = isempty(num) ? zero(T) : parse(T,num)
            den = isempty(den) ? one(T)  : parse(T,den)
            FastRational{T,IsReduced}(canonical(num, den))
        end
    else
        num, den = String.(split(s,Solunos))
        num = isempty(num) ? zero(T) : parse(T,num)
        den = isempty(den) ? one(T)  : parse(T,den)
        FastRational{T,IsReduced}(canonical(num, den))
    end
end

rem(x::FastRational{T,H1}, y::FastRational{T,H2}) where {T,H1,H2} = FastRational{T,IsReduced}(rem(Rational(x), Rational(y)))
mod(x::FastRational{T,H1}, y::FastRational{T,H2}) where {T,H1,H2} = FastRational{T,IsReduced}(mod(Rational(x), Rational(y)))

fld(x::FastRational{T,H1}, y::FastRational{T,H2}) where {T,H1,H2} = fld(Rational(x), Rational(y))
cld(x::FastRational{T,H1}, y::FastRational{T,H2}) where {T,H1,H2} = cld(Rational(x), Rational(y))
trunc(::Type{T}, x::FastRational) where {T} = trunc(Rational(x))
floor(::Type{T}, x::FastRational) where {T} = floor(Rational(x))
ceil(::Type{T}, x::FastRational) where {T} = ceil(Rational(x))
round(::Type{T}, x::FastRational, r::RoundingMode=RoundNearest) where {T} = round(T,Rational(x), r)
round(x::FastRational, r::RoundingMode) = round(Rational(x), r)

decompose(x::FastRational{T,IsReduced}) where {T} = x.num, zero(T), x.den
decompose(x::FastRational{T,MayReduce}) where {T} = decompose(FastRational(x))

end # FastRationals

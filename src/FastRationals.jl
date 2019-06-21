module FastRationals

export FastRational

struct FastRational <: Real
    num::Int32
    den::Int32
end

FastRational(x::Rational{Int32}) = FastRational(x.num, x.den)
FastRational(x::Rational{T}) where {T<:Union{Int8, Int16}} =
    FastRational(x.num%Int32, x.den%Int32)
FastRational(x::Rational{T}) where {T<:Union{Int64, Int128, BigInt}} =
    FastRational(Int32(x.num), Int32(x.den))

FastRational(x:Int32) = FastRational(x.num, one(Int32))
FastRational(x::T) where {T<:Union{Int8, Int16}} =
    FastRational(x%Int32, one(Int32))
FastRational(x::T) where {T<:Union{Int64, Int128, BigInt}} =
    FastRational(Int32(x), one(Int32))

Rational(x::FastRational) = x.num//x.den
Rational{Int32}(x::FastRational) = x.num//x.den
Rational{T}(x::FastRational) where {T} = (T)(x.num)//(T)(x.den)


    

end # FastRationals

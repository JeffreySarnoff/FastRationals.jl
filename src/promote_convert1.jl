FastRational(num::SUN, den::SUN) = FastRational(promote(num,den)...)
FastRational{T}(num::SUN, den::SUN) where T = FastRational{T}(promote(num,den)...)

FastRational{FQ}(x::BQ) where {FQ<:Integer, BQ<:Integer} = FastRational(FQ(x.num), one(FQ))
FastRational{FQ}(x::F; tol=eps(float(x)/2)) where {FQ<:Integer, F<:AbstractFloat} = FastRational(rationalize(x), tol=tol)

FastRational{I1}(numden::Tuple{I2,I2}) where {I1<:Integer, I2<:Integer} = FastRational{I1}(numden[1]//numden[2])

float(x::FastRational) = x.num / x.den

Base.Float64(x::FastRational) = float(x)
Base.Float32(x::FastRational) = Float32(float(x))
Base.Float16(x::FastRational) = Float16(float(x))
Base.BigFloat(x::FastRational) = BigFloat(x.num) / BigFloat(x.den)
function Base.BigInt(x::FastRational)
    num, den = canonical(x.num, x.den)
    den == 1 ? BigInt(num) : throw(InexactError)
end

function FastRational(x::F) where F<:AbstractFloat
    !isfinite(x) && throw(DomainError("finite values only"))
    return FastRational(rationalize(x))
end
function FastRational{T}(x::F) where {T<:SUN, F<:AbstractFloat}
    !isfinite(x) && throw(DomainError("finite values only"))
    return FastRational{T}(rationalize(x))
end

FastQBig(x::Rationals) = FastQBig(x.num, x.den)

FastQ128(x::FastQ64) = FastQ128(Rational{Int128}(x.num//x.den))
FastQ128(x::FastQ32) = FastQ128(Rational{Int128}(x.num//x.den))
FastQ64(x::FastQ32) = FastQ64(Rational{Int64}(x.num//x.den))
FastQ32(x::FastQ64) = FastQ32(Rational{Int32}(x.num//x.den))
FastQ64(x::FastQ128) = FastQ64(Rational{Int64}(x.num//x.den))
FastQ32(x::FastQ128) = FastQ32(Rational{Int32}(x.num//x.den))
FastQ64(x::FastQBig) = FastQ64(Rational{Int64}(x.num//x.den))
FastQ32(x::FastQBig) = FastQ32(Rational{Int32}(x.num//x.den))

promote_rule(::Type{FastQBig}, ::Type{FastQ128}) = FastQBig
promote_rule(::Type{FastQBig}, ::Type{FastQ64}) = FastQBig
promote_rule(::Type{FastQBig}, ::Type{FastQ32}) = FastQBig
promote_rule(::Type{FastQ128}, ::Type{FastQ64}) = FastQ128
promote_rule(::Type{FastQ128}, ::Type{FastQ32}) = FastQ128
promote_rule(::Type{FastQ64}, ::Type{FastQ32}) = FastQ64
convert(::Type{FastQBig}, x::FastQ128) = FastQBig(x)
convert(::Type{FastQBig}, x::FastQ64) = FastQBig(x)
convert(::Type{FastQBig}, x::FastQ32) = FastQBig(x)
convert(::Type{FastQ128}, x::FastQ64) = FastQ128(x)
convert(::Type{FastQ128}, x::FastQ32) = FastQ128(x)
convert(::Type{FastQ64}, x::FastQ32) = FastQ64(x)
convert(::Type{FastQ64}, x::FastQ128) = FastQ64(x)
convert(::Type{FastQ32}, x::FastQ128) = FastQ32(x)
convert(::Type{FastQ32}, x::FastQ64) = FastQ32(x)

for (Q,T) in ((:FastQ32, :Int32), (:FastQ64, :Int64), (:FastQ128, :Int128), (:FastQBig, :BigInt))
  @eval begin
    promote_rule(::Type{Rational{T}}, ::Type{$Q}) where {T} = $Q
    convert(::Type{$Q}, x::Rational{T}) where {T} = $Q($T(x.num), $T(x.den))
    promote_rule(::Type{$Q}, ::Type{F}) where {F<:AbstractFloat} = $Q
    convert(::Type{$Q}, x::F) where {F<:AbstractFloat} = $Q(Rational{$T}(x))
    promote_rule(::Type{I}, ::Type{$Q}) where {I<:Integer} = $Q
    convert(::Type{$Q}, x::I) where {I<:Integer} = $Q($T(x), one($T))
  end
end

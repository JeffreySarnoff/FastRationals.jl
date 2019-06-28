float(x::FastRational{T}) where {T<:Signed} = x.num / x.den

Base.Float64(x::FastRational{T}) where {T<:Signed}  = float(x)
Base.Float32(x::FastRational{T}) where {T<:Signed}  = Float32(float(x))I
Base.Float16(x::FastRational{T}) where {T<:Signed}  = Float16(float(x))
Base.BigFloat(x::FastRational{T}) where {T<:Signed} = BigFloat(x.num) / BigFloat(x.den)
Base.BigInt(x::FastRational{T}) where {T<:Signed}   = isinteger(x) ? BigInt((x.num//x.den).num) :
                                                                         throw(InexactError)

function FastRational{T}(x::F) where {T<:Signed, F<:AbstractFloat}
    !isfinite(x) && throw(DomainError("finite values only"))
    return FastRational{T}(rationalize(x))
end


FastQ128(x::FastQ64) = FastQ128(Rational{Int128}(x.num//x.den))
FastQ128(x::FastQ32) = FastQ128(Rational{Int128}(x.num//x.den))
FastQ64(x::FastQ32) = FastQ64(Rational{Int64}(x.num//x.den))
FastQ32(x::FastQ64) = FastQ32(Rational{Int32}(x.num//x.den))
FastQ64(x::FastQ128) = FastQ64(Rational{Int64}(x.num//x.den))
FastQ32(x::FastQ128) = FastQ32(Rational{Int32}(x.num//x.den))
FastQ64(x::FastQbig) = FastQ64(Rational{Int64}(x.num//x.den))
FastQ32(x::FastQbig) = FastQ32(Rational{Int32}(x.num//x.den))

promote_rule(::Type{FastQbig}, ::Type{FastQ128}) = FastQbig
promote_rule(::Type{FastQbig}, ::Type{FastQ64}) = FastQbig
promote_rule(::Type{FastQbig}, ::Type{FastQ32}) = FastQbig
promote_rule(::Type{FastQ128}, ::Type{FastQ64}) = FastQ128
promote_rule(::Type{FastQ128}, ::Type{FastQ32}) = FastQ128
promote_rule(::Type{FastQ64}, ::Type{FastQ32}) = FastQ64
convert(::Type{FastQbig}, x::FastQ128) = FastQbig(x)
convert(::Type{FastQbig}, x::FastQ64) = FastQbig(x)
convert(::Type{FastQbig}, x::FastQ32) = FastQbig(x)
convert(::Type{FastQ128}, x::FastQ64) = FastQ128(x)
convert(::Type{FastQ128}, x::FastQ32) = FastQ128(x)
convert(::Type{FastQ64}, x::FastQ32) = FastQ64(x)
convert(::Type{FastQ64}, x::FastQ128) = FastQ64(x)
convert(::Type{FastQ32}, x::FastQ128) = FastQ32(x)
convert(::Type{FastQ32}, x::FastQ64) = FastQ32(x)

for (Q,T) in ((:FastQ32, :Int32), (:FastQ64, :Int64), (:FastQ128, :Int128), (:FastQbig, :BigInt))
  @eval begin
    promote_rule(::Type{Rational{T}}, ::Type{$Q}) where {T} = $Q
    convert(::Type{$Q}, x::Rational{T}) where {T} = $Q($T(x.num), $T(x.den))
    promote_rule(::Type{$Q}, ::Type{F}) where {F<:AbstractFloat} = $Q
    convert(::Type{$Q}, x::F) where {F<:AbstractFloat} = $Q(Rational{$T}(x))
    promote_rule(::Type{I}, ::Type{$Q}) where {I<:Integer} = $Q
    convert(::Type{$Q}, x::I) where {I<:Integer} = $Q($T(x), one($T))
  end
end

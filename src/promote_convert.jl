float(x::FastRational{T}) where {T<:FastInt} = x.num / x.den

Base.Float64(x::FastRational{T}) where {T<:FastInt}  = float(x)
Base.Float32(x::FastRational{T}) where {T<:FastInt}  = Float32(float(x))I
Base.Float16(x::FastRational{T}) where {T<:FastInt}  = Float16(float(x))
Base.BigFloat(x::FastRational{T}) where {T<:FastInt} = BigFloat(x.num) / BigFloat(x.den)
Base.BigInt(x::FastRational{T}) where {T<:FastInt}   = isinteger(x) ? BigInt((x.num//x.den).num) :
                                                          throw(InexactError)



# ------------------------- FastQ32



function FastRational{T}(x::F) where {T<:FastInt, F<:AbstractFloat}
    !isfinite(x) && throw(DomainError("finite values only"))
    return FastRational{T}(Rational{T}(x))
end

# ------------------------- FastQ32

promote_rule(::Type{Rational{T}}, ::Type{FastQ32}) where {T} = FastQ32
convert(::Type{FastQ32}, x::Rational{T}) where {T} = FastQ32(Int32(x.num), Int32(x.den))
promote_rule(::Type{FastQ32}, ::Type{Float64}) = FastQ32
convert(::Type{FastQ32}, x::Float64) = FastQ32(Rational{Int32}(x))
promote_rule(::Type{FastQ32}, ::Type{Float32}) = FastQ32
convert(::Type{Float32}, x::FastQ32) = FastQ32(Rational{Int32}(x))
promote_rule(::Type{FastQ32}, ::Type{Float16}) = FastQ32
convert(::Type{Float16}, x::FastQ32) = FastQ32(Rational{Int32}(x))

promote_rule(::Type{I}, ::Type{FastQ32}) where {I<:Integer} = FastQ32
convert(::Type{FastQ32}, x::I) where {I<:Integer} = FastQ32(Int32(x), one(Int32))

# ------------------------- FastQ64


function FastQ64(x::F) where {F<:AbstractFloat}
    !isfinite(x) && throw(DomainError("finite values only"))
    return FastQ64(Rational{Int64}(x))
end

# ------------------------- FastQ64

promote_rule(::Type{Rational{T}}, ::Type{FastQ64}) where {T} = FastQ64
convert(::Type{FastQ64}, x::Rational{T}) where {T} = FastQ64(Int64(x.num), Int64(x.den))
promote_rule(::Type{FastQ64}, ::Type{Float64}) = FastQ64
convert(::Type{FastQ64}, x::Float64) = FastQ64(Rational{Int64}(x))
promote_rule(::Type{FastQ64}, ::Type{Float32}) = FastQ64
convert(::Type{Float32}, x::FastQ64) = FastQ64(Rational{Int64}(x))
promote_rule(::Type{FastQ64}, ::Type{Float16}) = FastQ64
convert(::Type{Float16}, x::FastQ64) = FastQ65(Rational{Int64}(x))

promote_rule(::Type{I}, ::Type{FastQ64}) where {I<:Integer} = FastQ64
convert(::Type{FastQ64}, x::I) where {I<:Integer} = FastQ64(Int64(x), one(Int32))

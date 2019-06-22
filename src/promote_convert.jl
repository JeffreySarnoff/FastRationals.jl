# ------------------------- FastQ32

promote_rule(::Type{Rational{T}}, ::Type{FastQ32}) where {T} = FastQ32
convert(::Type{FastQ32}, x::Rational{T}) where {T} = FastQ32(Int32(x.num), Int32(x.den))
promote_rule(::Type{FastQ32}, ::Type{Float64}) = FastQ32
convert(::Type{FastQ32}, x::Float64) = FastQ32(Rational{Int32}(x))
promote_rule(::Type{FastQ32}, ::Type{Float32}) = FastQ32
convert(::Type{Float32}, x::FastQ32) = FastQ32(Rational{Int32}(x))

promote_rule(::Type{I}, ::Type{FastQ32}) where {I<:Integer} = FastQ32
convert(::Type{FastQ32}, x::I) where {I<:Integer} = FastQ32(Int32(x), one(Int32))

# ------------------------- FastQ64

promote_rule(::Type{Rational{T}}, ::Type{FastQ64}) where {T} = FastQ64
convert(::Type{FastQ64}, x::Rational{T}) where {T} = FastQ64(Int64(x.num), Int64(x.den))
promote_rule(::Type{FastQ64}, ::Type{Float64}) = FastQ64
convert(::Type{FastQ64}, x::Float64) = FastQ32(Rational{Int64}(x))
promote_rule(::Type{FastQ64}, ::Type{Float32}) = FastQ64
convert(::Type{Float32}, x::FastQ64) = FastQ32(Rational{Int64}(x))

promote_rule(::Type{I}, ::Type{FastQ64}) where {I<:Integer} = FastQ64
convert(::Type{FastQ64}, x::I) where {I<:Integer} = FastQ64(Int64(x), one(Int32))

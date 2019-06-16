promote_rule(::Type{FastRational{T,IsReduced}}, ::Type{T}) where {T<:BitInteger} = FastRational{T,IsReduced}
promote_rule(::Type{FastRational{T,MayReduce}}, ::Type{T}) where {T<:BitInteger} = FastRational{T,IsReduced}
promote_rule(::Type{FastRational{T,IsReduced}}, ::Type{Rational{T}}) where {T<:BitInteger} = FastRational{T,IsReduced}
promote_rule(::Type{FastRational{T,MayReduce}}, ::Type{Rational{T}}) where {T<:BitInteger} = FastRational{T,IsReduced}

promote_rule(::Type{FastRational{T,IsReduced}}, ::Type{A}) where {T,A} = FastRational{T,IsReduced}
promote_rule(::Type{FastRational{T,MayReduce}}, ::Type{A}) where {T,A} = FastRational{T,IsReduced}

convert(::Type{FastRational{T,IsReduced}}, x::Rational{T}) where {T} = FastRational{T,IsReduced}(x.num, x.den)
convert(::Type{FastRational{T,MayReduce}}, x::Rational{T}) where {T} = FastRational{T,IsReduced}(x.num, x.den)
convert(::Type{Rational{T}}, x::FastRational{T,MayReduce}) where {T} = Rational{T}(canonical(x.num, x.den))
convert(::Type{Rational{T}}, x::FastRational{T,IsReduced}) where {T} = Rational{T}(x.num, x.den)

convert(::Type{FastRational{T,IsReduced}}, x::T) where {T} = FastRational{T,IsReduced}(x, one(T))
convert(::Type{FastRational{T,MayReduce}}, x::T) where {T} = FastRational{T,IsReduced}(x, one(T))

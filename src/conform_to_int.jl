ceil(x::FastRational{T}) where {I<:Integer, T<:FastInt} = FastRational{T}(numerator(ceil(T, x.num//x.den)), one(T))
floor(x::FastRational{T}) where {I<:Integer, T<:FastInt} = FastRational{T}(numerator(floor(T, x.num//x.den)), one(T))
trunc(x::FastRational{T}) where {I<:Integer, T<:FastInt} = FastRational{T}(numerator(trunc(T, x.num//x.den)), one(T))
round(x::FastRational{T}) where {I<:Integer, T<:FastInt} = FastRational{T}(numerator(round(T, x.num//x.den)), one(T))

ceil(::Type{I}, x::FastRational{T}) where {I<:Integer, T<:FastInt} = ceil(I, x.num//x.den)
floor(::Type{I}, x::FastRational{T}) where {I<:Integer, T<:FastInt} = floor(I, x.num//x.den)
trunc(::Type{I}, x::FastRational{T}) where {I<:Integer, T<:FastInt} = trunc(I, x.num//x.den)
round(::Type{I}, x::FastRational{T}) where {I<:Integer, T<:FastInt} = round(I, x.num//x.den)

ceil(::Type{Integer}, x::FastRational{T}) where {T<:FastInt} = ceil(Integer, x.num//x.den)
floor(::Type{Integer}, x::FastRational{T}) where {T<:FastInt} = floor(Integer, x.num//x.den)
trunc(::Type{Integer}, x::FastRational{T}) where {T<:FastInt} = trunc(Integer, x.num//x.den)
round(::Type{Integer}, x::FastRational{T}) where {T<:FastInt} = round(Integer, x.num//x.den)


round(x::FastRational{T}, ::RoundingMode{:ToZero}) where {T<:FastInt} = signbit(x) ? ceil(x) : floor(x)
round(x::FastRational{T}, ::RoundingMode{:FromZero}) where {T<:FastInt} = signbit(x) ? floor(x) : ceil(x)
round(x::FastRational{T}, ::RoundingMode{:Up}) where { T<:FastInt} = FastRational{T}(ceil(T, x.num//x.den), one(T))
round(x::FastRational{T}, ::RoundingMode{:Down}) where {T<:FastInt} = FastRational{T}(floor(T, x.num//x.den), one(T))
round(x::FastRational{T}, ::RoundingMode{:Nearest}) where {T<:FastInt} = FastRational{T}(round(T, x.num//x.den), one(T))
  
round(::Type{I}, x::FastRational{T}, ::RoundingMode{:ToZero}) where {I<:Integer, T<:FastInt} = signbit(x) ? ceil(I,x) : floor(I,x)
round(::Type{I}, x::FastRational{T}, ::RoundingMode{:FromZero}) where {I<:Integer, T<:FastInt} = signbit(x) ? floor(I,x) : ceil(I,x)
round(::Type{I}, x::FastRational{T}, ::RoundingMode{:Up}) where {I<:Integer, T<:FastInt} = ceil(I, x.num//x.den)
round(::Type{I}, x::FastRational{T}, ::RoundingMode{:Down}) where {I<:Integer, T<:FastInt} = floor(I, x.num//x.den)
round(::Type{I}, x::FastRational{T}, ::RoundingMode{:Nearest}) where {I<:Integer, T<:FastInt} = round(I, x.num//x.den)

round(::Type{Integer}, x::FastRational{T}, ::RoundingMode{:ToZero}) where {I<:Integer, T<:FastInt} = signbit(x) ? ceil(T,x) : floor(T,mx)
round(::Type{Integer}, x::FastRational{T}, ::RoundingMode{:FromZero}) where {I<:Integer, T<:FastInt} = signbit(x) ? floor(T,x) : ceil(T,x)
round(::Type{Integer}, x::FastRational{T}, ::RoundingMode{:Up}) where {I<:Integer, T<:FastInt} = ceil(T, x.num//x.den)
round(::Type{Integer}, x::FastRational{T}, ::RoundingMode{:Down}) where {I<:Integer, T<:FastInt} = floor(T, x.num//x.den)
round(::Type{Integer}, x::FastRational{T}, ::RoundingMode{:Nearest}) where {I<:Integer, T<:FastInt} = round(T, x.num//x.den)

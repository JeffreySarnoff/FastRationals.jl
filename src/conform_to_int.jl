round(::Type{Integer}, x::T) where {T<:FastRational} = round(Integer, x.num//x.den)
round(::Type{I}, x::T) where {I<:Integer, T<:FastRational} = round(I, x.num//x.den)
ceil(::Type{Integer}, x::T) where {T<:FastRational} = ceil(Integer, x.num//x.den)
ceil(::Type{I}, x::T) where {I<:Integer, T<:FastRational} = ceil(I, x.num//x.den)
floor(::Type{Integer}, x::T) where {T<:FastRational} = floor(Integer, x.num//x.den)
floor(::Type{I}, x::T) where {I<:Integer, T<:FastRational} = floor(I, x.num//x.den)
trunc(::Type{Integer}, x::T) where {T<:FastRational} = trunc(Integer, x.num//x.den)
trunc(::Type{I}, x::T) where {I<:Integer, T<:FastRational} = trunc(I, x.num//x.den)

round(::Type{Integer}, x::T, ::RoundingMode{:ToZero}) where {T<:Rational} = trunc(Integer, x.num//x.den)
round(::Type{I}, x::T, ::RoundingMode{:ToZero}) where {I<:Integer, T<:FastRational} = trunc(I, x.num//x.den)
round(::Type{Integer}, x::T, ::RoundingMode{:FromZero}) where {T<:Rational} = -trunc(Integer, -x.num//x.den)
round(::Type{I}, x::T, ::RoundingMode{:FromZero}) where {I<:Integer, T<:FastRational} = -trunc(I, -x.num//x.den)
round(::Type{Integer}, x::T, ::RoundingMode{:RoundUp}) where {T<:Rational} = ceil(Integer, x.num//x.den)
round(::Type{I}, x::T, ::RoundingMode{:RoundUp}) where {I<:Integer, T<:FastRational} = ceil(I, x.num//x.den)
round(::Type{Integer}, x::T, ::RoundingMode{:RoundDown}) where {T<:Rational} = floor(Integer, x.num//x.den)
round(::Type{I}, x::T, ::RoundingMode{:RoundDown}) where {I<:Integer, T<:FastRational} = floor(I, x.num//x.den)
round(::Type{Integer}, x::T, ::RoundingMode{:RoundNearest}) where {T<:Rational} = round(Integer, x.num//x.den)
round(::Type{I}, x::T, ::RoundingMode{:RoundNearest}) where {I<:Integer, T<:FastRational} = round(I, x.num//x.den)

round(x::FastRational{T}, ::RoundingMode{:ToZero}) where {T<:Integer} = trunc(T, x)
round(x::FastRational{T}, ::RoundingMode{:FromZero}) where {T<:Integer} = -trunc(T, -x)
round(x::FastRational{T}, ::RoundingMode{:RoundUp}) where {T<:Integer} = ceil(T, x)
round(x::FastRational{T}, ::RoundingMode{:RoundDown}) where {T<:Integer} = floor(T, x)
round(x::FastRational{T}, ::RoundingMode{:RoundNearest}) where {T<:Integer} = round(T, x, RoundNearest)

#=
this is adapted directly from base -- there are "what error gets thrown" testing conflicts

trunc(::Type{I}, x::FastRational{T}) where {I<:Integer, T<:FastInt} = convert(T, div(x.num,x.den))
floor(::Type{I}, x::FastRational{T}) where {I<:Integer, T<:FastInt} = convert(T, fld(x.num,x.den))
ceil(::Type{I},  x::FastRational{T}) where {I<:Integer, T<:FastInt} = convert(T, cld(x.num,x.den))

trunc(::Type{Integer}, x::FastRational{T}) where {T<:FastInt} = trunc(T, x)
floor(::Type{Integer}, x::FastRational{T}) where {T<:FastInt} = floor(T, x)
ceil(::Type{Integer},  x::FastRational{T}) where {T<:FastInt} = ceil(T, x)

trunc(x::FastRational{T}) where {T<:FastInt} = trunc(T, x)
floor(x::FastRational{T}) where {T<:FastInt} = floor(T, x)
ceil(x::FastRational{T}) where {T<:FastInt} = ceil(T, x)

round(x::FastRational{T}, ::RoundingMode{:ToZero}) where {T<:FastInt} = trunc(T, x)
round(x::FastRational{T}, ::RoundingMode{:FromZero}) where {T<:FastInt} = -trunc(T, -x)
round(x::FastRational{T}, ::RoundingMode{:Up}) where {T<:FastInt} = ceil(T, x)
round(x::FastRational{T}, ::RoundingMode{:Down}) where {T<:FastInt} = floor(T, x)
round(x::FastRational{T}, ::RoundingMode{:Nearest}) where {T<:FastInt} = round(T, x.num/x.den, RoundNearest)
round(x::FastRational{T}) where {T<:FastInt} = round(x, RoundNearest)

round(::Type{I}, x::FastRational{T}, ::RoundingMode{:ToZero}) where {I<:Integer, T<:FastInt} = I(numerator(round(x, RoundToZero)))
round(::Type{I}, x::FastRational{T}, ::RoundingMode{:FromZero}) where {I<:Integer, T<:FastInt} = I(numerator(round(x, RoundFromZero)))
round(::Type{I}, x::FastRational{T}, ::RoundingMode{:Up}) where {I<:Integer, T<:FastInt} = I(numerator(round(x, RoundUp)))
round(::Type{I}, x::FastRational{T}, ::RoundingMode{:Down}) where {I<:Integer, T<:FastInt} = I(numerator(round(x, RoundDown)))
round(::Type{I}, x::FastRational{T}, ::RoundingMode{:Nearest}) where {I<:Integer, T<:FastInt} = I(numerator(round(x, RoundNearest)))
round(::Type{I}, x::FastRational{T}) where {I<:Integer, T<:FastInt} = round(I, x, RoundNearest)

round(::Type{Integer}, x::FastRational{T}, ::RoundingMode{:ToZero}) where {T<:FastInt} = round(T, x, RoundToZero)
round(::Type{Integer}, x::FastRational{T}, ::RoundingMode{:FromZero}) where {T<:FastInt} = round(T, x, RoundFromZero)
round(::Type{Integer}, x::FastRational{T}, ::RoundingMode{:Up}) where {T<:FastInt} = round(T, x, RoundUp)
round(::Type{Integer}, x::FastRational{T}, ::RoundingMode{:Down}) where {T<:FastInt} = round(T, x, RoundDown)
round(::Type{Integer}, x::FastRational{T}, ::RoundingMode{:Nearest}) where {T<:FastInt} = round(T, x, RoundNearest)
round(::Type{Integer}, x::FastRational{T}) where {T<:FastInt} = round(T, x, RoundNearest)
=#

#=
    As yet unused:
=#

isreduced(x::FastRational{T,IsReduced}) where {T} = true
isreduced(x::FastRational{T,MayReduce}) where {T} = false

mayreduce(x::FastRational{T,IsReduced}) where {T} = false
mayreduce(x::FastRational{T,MayReduce}) where {T} = true

# denominator is strictly positive
# numerator   is negative, zero, or positve

iszero(x::FastRational{T,IsReduced}) where {T} = iszero(x.num)
isone(x::FastRational{T,IsReduced})  where {T} = x.num === x.den

isinteger(x::FastRational{T,IsReduced}) where {T} = x.den == 1
isinteger(x::FastRational{T,MayReduce}) where {T} = canonical(x.num,x.den)[2] == 1

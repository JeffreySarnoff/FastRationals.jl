#=
    As yet unused:
=#

isreduced(x::FastRational{T,IsReduced}) where {T} = true
isreduced(x::FastRational{T,MayReduce}) where {T} = false

mayreduce(x::FastRational{T,IsReduced}) where {T} = false
mayreduce(x::FastRational{T,MayReduce}) where {T} = true

# denominator is strictly positive
# numerator   is negative, zero, or positve

zero(::Type{FastRational{T,IsReduced}}) where {T,H} = FastRational{T,IsReduced}(zero(T), one(T))
one(::Type{FastRational{T,IsReduced}})  where {T,H} = FastRational{T,IsReduced}(one(T),  one(T))

iszero(x::FastRational{T,IsReduced}) where {T} = iszero(x.num)
isone(x::FastRational{T,IsReduced})  where {T} = x.num === x.den

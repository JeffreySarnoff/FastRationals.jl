#=

    As yet unused:

- predicates for internal use aor export

isreduced(x::FastRational{T,IsReduced}) where {T} = true
isreduced(x::FastRational{T,MayReduce}) where {T} = false

mayreduce(x::FastRational{T,IsReduced}) where {T} = false
mayreduce(x::FastRational{T,MayReduce}) where {T} = true

=#

using FasterRationals
using BenchmarkTools

""
    hilbert_matrix(::AkoRational, ::AkoInt, n_of_nxn)

#Example

julia> hilbert_matrix(Rational, Int16, 2)
2×2 Array{Rational{Int16},2}:
 1//1  1//2
 1//2  1//3

"""
function hilbert_matrix(::Type{Q}, ::Type{S}, isqrt_nxn::I) where {I, Q, S}
    return[Q{S}(1,((i)+j-1)) for i in 1:isqrt_nxn, j in 1:isqrt_nxn]
end



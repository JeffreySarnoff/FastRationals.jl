using FasterRationals

using BenchmarkTools
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 5.0;
BenchmarkTools.DEFAULT_PARAMETERS.time_tolerance = 0.02;
BenchmarkTools.estimate_overhead();
BenchmarkTools.DEFAULT_PARAMETERS.overhead = BenchmarkTools.estimate_overhead();

"""
    hilbert_matrix(::AkoRational, ::AkoInt, n_of_nxn)

#Example

julia> n = 16; 
julia> @assert n <= 32 # otherwise overflows Int2128
julia> amat = hilbert_matrix(Rational, Int128, n);
julia> amat_factors = lufact(amat).factors;

"""
function hilbert_matrix(::Type{Q}, ::Type{S}, isqrt_nxn::I) where {I, Q, S}
    return[Q{S}(1,((i)+j-1)) for i in 1:isqrt_nxn, j in 1:isqrt_nxn]
end



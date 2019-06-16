#=
   Much of the activity bound to rational numbers and their arithmetic is tethered to integer multiplication.
   Rationals are a projectively exact representation within their computationally bounded domain.
   The ratio held as numerator and denominator is an exact representation of the rational value it projects.
   When applied to solve dynamical problems or to resolve the computational tractable in another manner,
   the coarse gapping that is given across steps of discrete rational availability is where approximation
   enters. This duality is the origin of their effectiveness.  We may play the representational equivalence
   off of the metrical coarseness and so apply this tool where it best shine.
=#

"""
    propinquity(x::T, y::T)

x * y, without possiblity of overflow
where T is a very fast system integer

When necessary, to preclude overflow, the product
is returned using the associated widened type.
Given `Int32` arguments, the result must be
either an `Int32` or it is an `Int64`.

The widest types accepted are `[U]Int64`,
so the widest result type is `[U]Int128`.
"""
propinquity(x::T, y::T) where {T<:FastInteger} =
    usewidemul(x,y) ? widemul(x,y) : x*y

#=
    
=#
@inline function usewidemul(x::T, y::T) where {T<:FastSigned}
    iszero( (leading_zeros(abs(x)) + leading_zeros(abs(y))) >> sizeof(T) )
end

@inline function usewidemul(x::T, y::T) where {T<:FastUnsigned}
    iszero( (leading_zeros(x) + leading_zeros(t)) >> sizeof(T) )
end

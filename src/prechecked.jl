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
    propinquity(x::T, y::T)::Union{T, widen(T)}

x * y, without possiblity of overflow, T is a very fast system integer


Implict provision of the return type selects either the args' shared type or the nearest larger type.
Using `Int16` args allows their product to be computed either as an `Int16` or as an `Int32`.



A wider type is used when necessary to preclude overflow, which itself protects the computation from
that sort of error.  When the originating type properly holds the product, the same type is used.
"""
propinquity(x::T, y::T) where {T<:FastInteger} =
    usewidemul(x,y) ? widemul(x,y) : x*y

"""
    Rapid determination of the working Type

We are given two range-limited integers of the same
performant system type, either signed or unsigned.
We are asked : "Do you assert that this type would
hold their product precisly, with full accuracy?"

`true` means
   It is certain that their product is within the standard discrete domain of the given type.

`false` means
   No assertion is made regarding the whether the given type would hold their product properly.
   It is asserted that at least of (a) or (b) hold.
     (a) It is known that use of with the given type nay promulage inaccuracies.
     (b) It is not known whether the precision of the given type covers this product.
""" usewidemul

@inline function usewidemul(x::T, y::T) where {T<:FastSigned}
    iszero( (leading_zeros(abs(x)) + leading_zeros(abs(y))) >> sizeof(T) )
end

@inline function usewidemul(x::T, y::T) where {T<:FastUnsigned}
    iszero( (leading_zeros(x) + leading_zeros(t)) >> sizeof(T) )
end

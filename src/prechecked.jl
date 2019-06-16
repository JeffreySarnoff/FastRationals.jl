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

The product is returned using the type
provided. Provision of the return type
is explict when specified explicitly;
__note well__: explicit typing is an
unsafe act, where internal logic is 
applied presumptively, absent checks,
tests and precondition enforcement.

Implict provision of the return type
selects either the type of the args
or selects the next larger like it.
Given `Int32` arguments, the product
is delivered as `Int32` or as `Int64`.

A wider type is used when necessary
to preclude overflow, and prevent
the attendant incorrect values from
being introduced to the computation.
When the originating type holds
the product properly, it is used.
"""
propinquity(x::T, y::T) where {T<:FastInteger} =
    usewidemul(x,y) ? widemul(x,y) : x*y

#=
    Rapid determination of the working Type

We are given two range-limited integers of the same
performant system type, either signed or unsigned.
We are asked : "Do you assert that this type would
hold their product precisly, with full accuracy?"

Responding `true` means
- it is certain that their product is within the standard discrete domain of the given type.
Responding `false` means
- no assertion is made regarding the whether the given type would hold their product properly.


nknown whether their product
it is either known to uncertain or 
of these two integers 

precisely. given
=#
@inline function usewidemul(x::T, y::T) where {T<:FastSigned}
    iszero( (leading_zeros(abs(x)) + leading_zeros(abs(y))) >> sizeof(T) )
end

@inline function usewidemul(x::T, y::T) where {T<:FastUnsigned}
    iszero( (leading_zeros(x) + leading_zeros(t)) >> sizeof(T) )
end

#=
     canonical(n, d)    n, d   two integers
     canonical(n__d)    n//d   one rational
     
     Map an ordered pair of integers in their given ratio
     to an ordered pair of integers, preserving their ratio
     while proportional reduction finds the ordered pair of
     integers with the given ratio and of least magnitude.
=#     
  
#=   
    System Rationals are maintained in lowest terms, no additional work needed
    FastRational{T,IsReduced} is already in lowest terms, no additional work needed
    FastRational{T,MayReduce} may or may not be in lowest terms, must apply work
=#

@inline canonical(q::Rational{T}) where{T} = q
@inline canonical(q::FastRational{T,IsReduced}) where{T} = q
@inline canonical(q::FastRational{T,MayReduce}) where{T} = canonical(q.num, q.den)

"""
    canonical(num::T, den::T) where T<:Union{Signed, Unsigned}

presumes
  num, den are "normative": den != 0, both are finite
  num, den share an integer type, Signed or Unsigned

provides
  num, den where either
      1 == |num| == |den|
  or  
           |num| != |den|
      and
           either both are odd or
           one is odd, one even
  
assures
  num, den have no common factors
  den is strictly positive
  num is negative onlyif num/den < 0
 
invariant
  The integer type given num, den is carried in this 
  functional action and is carried out unchanged.
""" canonical

function canonical(num::T, den::T) where {T<:Unsigned}
    num, den = canonical_valued(num, den)
    return num, den
end

function canonical(num::T, den::T) where {T<:Signed}
    num, den = canonical_signed(num, den)
    num, den = canonical_valued(num, den)
    return num, den
end

@inline function canonical_signed(num::T, den::T) where {T<:Signed}
    return flipsign(num, den), abs(den)
end

@inline function canonical_valued(num::T, den::T) where {T<:Signed}
    gcdval = gcd(num, den)
    gcdval === one(T) && return num, den
    num = div(num, gcdval)
    den = div(den, gcdval)
    return num, den
end 

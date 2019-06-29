const FieldQ = Union{Rational{T}, FastRational{T}} where {T}
const FieldQBig = Union{Rational{BigInt}, Rational{Int128}, FastRational{BigInt}, FastRational{Int128}}

function compactify_rational(midpoint::Q, radius::R) where {Q<:FieldQ, R<:FieldQ} 
    lo = float(midpoint - radius)
    hi = float(midpoint + radius)
    flnum, flden = compactify_rational(lo, hi)
    num, den = trunc(Int64,flnum), trunc(Int64,flden)
    return Q(num, den)
end

function compactify_rational(midpoint::Q, radius::R) where {Q<:FieldQBig, R<:FieldQ} 
    lo = Float64(BigFloat(midpoint - radius))
    hi = Float64(BigFloat(midpoint + radius))
    flnum, flden = compact_rational(lo, hi)
    num, den = trunc(Int64,flnum), trunc(Int64,flden)
    return Q(num, den)
end


#=
    The algorithm for `compact_rational` is from Hiroshi Murakami's paper
    Calculation of rational numbers in an interval whose denominator is the smallest
    ACM Communications in Computer Algebra, Vol 48, No. 3, Issue 189, September 2014
    
    Hiroshi Murakami, Department of Mathematics and Information Sciences,
    Tokyo Metropolitan University, Tokyo, 192-0397, Japan
    mrkmhrsh@tmu.ac.jp, https://www.rs.tus.ac.jp/hide-murakami/index.html
=#

function compact_rational(lo::T, hi::T) where {T<:Real}
    lo, hi = compact_rational_constraints(lo, hi)
    
	if ceil(lo) <= floor(hi) 	                     # [lo,hi] contains some integer
	  num, den = ceil(lo), one(T)                    # the CF expansion terminates here.
    else                                             # [lo,hi] contains no integer 
	  m = floor(lo)                                  #
	  lo, hi = inv(hi-m), inv(lo-m)                  # the CF expansion continues. 
	  num, den = compact_rational_unchecked(lo, hi)  # Recursive call is made here.
	  num, den = num*m + den, num 
    end

    return num, den
end

function compact_rational_unchecked(lo::T, hi::T) where {T<:Real}    
	if ceil(lo) <= floor(hi) 	                     # [lo,hi] contains some integer
	  num, den = ceil(lo), one(T)                    # the CF expansion terminates here.
    else                                             # [lo,hi] contains no integer 
	  m = floor(lo)                                  #
	  lo, hi = inv(hi-m), inv(lo-m)                  # the CF expansion continues. 
	  num, den = compact_rational_unchecked(lo, hi)  # Recursive call is made here.
	  num, den = num*m + den, num 
    end
    return num, den
end


#=
from the paper (section 1)

For a given positive real interval I = [α,β] (0 < α < β), 
    we ﬁnd a rational number P/Q in I
        whose positive denominator Q is the smallest.

We may change the problem to: 
    “For the interval I, ﬁnd (all) rational numbers in I whose positive denominator is the smallest”.
We may also change the problem to: 
    “For the interval I, from all rational numbers in I whose positive denominator is the smallest,
        ﬁnd the one whose numerator is the smallest”,

        because when we ﬁnd Q the smallest positive denominator,
        the numerator P of the original problem is any integer in
        ceil(Qα),···,ﬂoor(Qβ) contained in [Qα, Qβ]. 

The rational number P/Q is uniquely determined from the real positive closed interval I [α,β] (0<α<β)
   can be found by the CF expansion method[1]. This algorithm is an analogy of the 
   regular continued fraction expansion of a real number, and gives a solution very quickly
   even when the denominator of the solution is a huge integer. The count of arithmetic operations
   is linear to the bit length of the denominator of the solution.
=#

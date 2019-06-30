"""
    compactify_rational(rational_to_compactify, radius_of_indifference)

From all of the rational values that exist within ±_`radius_of_indifference`_
of the _`rational_to_compactify`_ this function obtains this uniquely determined
rational: the denominator is that of least magnitude and the numerator is either
uniquely given or, of those given, that of least magnitude.

We are indifferent to the two rational values, source and result, as magnitudes.
We prefer to use the compactified value in calculations, as with it, overflow
is less likely, probably, with the next arithmetic operation.
""" compactify_rational

for Q in (:Rational, :FastRational)
  @eval begin

    function compactify_rational(midpoint::$Q{T}, radius::$Q{T}) where {T<:BitInteger}
        numlo, denlo, ovflo = subovf(midpoint, radius)
        numhi, denhi, ovfhi = addovf(midpoint, radius)
        if ovfhi || ovflo
            mid = BigInt(midpoint.num)//BigInt(midpoint.den)
            rad = BigInt(radius.num)//BigInt(radius.den)
            qlo = mid - rad
            qhi = mid + rad
        else
            qlo = Rational(numlo, denlo)
            qhi = Rational(numhi, denhi)
        end

        lo  = qlo.num / qlo.den
        hi  = qhi.num / qhi.den
            
        num, den = T.(compact_rational(lo, hi))
        return $Q(num, den)
    end
        
    function compactify_rational(midpoint::$Q{BigInt}, radius::$Q{BigInt})
        qlo = midpoint - radius
        qhi = midpoint + radius
        lo  = qlo.num / qlo.den
        hi  = qhi.num / qhi.den

        num, den = BigInt.(compact_rational(lo, hi))
        return $Q(num, den)
    end

   function compactify_rational(midpoint::$Q{T}, radius::F) where {T<:BitInteger, F<:AbstractFloat}
        rradius = rationalize(radius)
        qradius = Rational(T(rradius.num), T(rradius.den))
        return compactify_rational(midpoint, qradius)
    end
        
    function compactify_rational(midpoint::$Q{BigInt}, radius::F) where {F<:AbstractFloat}
        rradius = rationalize(radius)
        qradius = Rational(BigInt(rradius.num), BigInt(rradius.den))
        return compactify_rational(midpoint, qradius)
    end
        
  end
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
    
    if ceil(lo) <= floor(hi)                           # [lo,hi] contains some integer
        num, den = ceil(lo), one(T)                    # the CF expansion terminates here.
        else                                           # [lo,hi] contains no integer 
        m = floor(lo)                                  #
        lo, hi = inv(hi-m), inv(lo-m)                  # the CF expansion continues. 
        num, den = compact_rational_unchecked(lo, hi)  # Recursive call is made here.
        num, den = num*m + den, num 
    end
    return num, den
end

function compact_rational_unchecked(lo::T, hi::T) where {T<:Real}    
    if ceil(lo) <= floor(hi)                           # [lo,hi] contains some integer
        num, den = ceil(lo), one(T)                    # the CF expansion terminates here.
        else                                           # [lo,hi] contains no integer 
        m = floor(lo)                                  #
        lo, hi = inv(hi-m), inv(lo-m)                  # the CF expansion continues. 
        num, den = compact_rational_unchecked(lo, hi)  # Recursive call is made here.
        num, den = num*m + den, num 
    end
    return num, den
end

function compact_rational_constraints(lo::T, hi::T) where {T<:Real}
    lo, hi = abs(lo), abs(hi)
    lo, hi = lo < hi ? (lo, hi) : (hi, lo)
    !iszero(lo) || throw(ErrorException("lo == 0"))
    if T<:Rational
        flo = lo.num / lo.den
        fhi = hi.num / hi.den
    else
        flo, fhi = lo, hi
    end
    return flo, fhi
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

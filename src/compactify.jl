"""
    compactify(rational_to_compactify, radius_of_indifference)
    compactify(low=one_inteval_bound, high=other_interval_bound)

From all of the rational values that exist within ±`radius_of_indifference`
of the `rational_to_compactify` respectively the interval 
this function obtains this uniquely determined
rational: the denominator is that of least magnitude and the numerator is either
uniquely given or, of those given, that of least magnitude.
The first form suffers from inaccuracies due to rounding errors.

We are indifferent to the two rational values, source and result, as magnitudes.
We prefer to use the compactified value in calculations, as with it, overflow
is less likely, probably, with the next arithmetic operation.
"""
function compactify(;low::Q, high::Q) where Q<:RationalUnion
    if low < high <= 0 || 0 <= high < low
        low, high = high, low
    end
    lon, lod, hin, hid = low.num, low.den, high.num, high.den
    if lon == 0 || hin == 0 || lon < 0 == hin > 0
        return Q(0)
    end
    sig = signbit(lon)
    if sig
        lon, hin = -lon, -hin
    end
    num, den = compact_integer(lon, lod, hin, hid)
    return Q(sig ? -num : num, den)
end

# compute Q(midpoint - rad) and Q(midpoint + rad) approximately
# preserving integer type
function compact_reduce(m::Q, r::Q) where Q<:RationalUnion
    a, b = m.num, m.den
    c, d = r.num, r.den
    u = tm ÷ max(b, a)
    au = a * u
    bu = b * u
    v = (bu ÷ d) * c
    lo3 = compact_integer(au - v, bu, au - v + 1, bu)
    hi3 = compact_integer(au + v - 1, bu, au + v, bu)
    tuple(lo3..., hi3...)
end

for (Q1, Q2) in ((:FastRational, :FastRational), (:FastRational, :Rational), (:Rational, :Rational))
  @eval begin
    function compactify(midpoint::$Q1{T}, radius::$Q2{T}) where {T<:Integer}
        mid, rad = float(midpoint), float(abs(radius))
        lo, hi = mid-rad, mid+rad
        lo, hi = compact_rational_constraints(mid, rad, lo, hi)
        num, den = T.(compact_rational(lo, hi))
        return $Q1{T}(num, den)
    end
  end
end

for Q in (:FastRational, :Rational)
  @eval begin
    function compactify(midpoint::$Q{T}, radius::F) where {T<:Integer, F<:Union{Float32, Float64}}
        mid = F(midpoint)
        lo, hi = mid-radius, mid+radius
        lo, hi = compact_rational_constraints(mid, radius, lo, hi)
        num, den = T.(compact_rational(lo, hi))
        return $Q{T}(num, den)
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
    if ceil(lo) <= floor(hi)                           # [lo,hi] contains some integer
        num, den = ceil(lo), one(T)                    # the CF expansion terminates here.
    else                                               # [lo,hi] contains no integer 
        m = floor(lo)                                  #
        lo, hi = inv(hi-m), inv(lo-m)                  # the CF expansion continues. 
        num, den = compact_rational(lo, hi)  # Recursive call is made here.
        num, den = num*m + den, num 
    end
    return num, den
end

# implementation of previous algotrithm using integer arithmetic
function compact_integer(a::T, b::T, c::T, d::T) where T<:Integer
    m, r = divrem(a, b)
    if r == 0
        m, T(1)
    else
        s = c - d * m
        if s >= d
            m+1, T(1)
        else
            num, den = compact_integer(d, s, b, r)
            num * m + den, num
        end
    end
end

function compact_rational(x::R, y::R) where R<:RationalUnion
   compact_integer(x.num, x.den, y.num, y.den)
end

# convert input arguments to float and check for argument errors
function compact_rational_constraints(mid::T, rad::T, lo::T, hi::T) where {T<:Real}
    rad < eps(mid) && throw(ArgumentError("radius is less than eps(float(midpoint)))"))
    lo, hi = abs(lo), abs(hi)
    lo, hi = lo < hi ? (lo, hi) : (hi, lo)
    !iszero(lo) || throw(ArgumentError("lo == 0"))
    flo, fhi = float(lo), float(hi)
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

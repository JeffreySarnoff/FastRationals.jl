const FieldQ = Union{Rational{T}, FastRational{T}} where {T}
const FieldQBig = Union{Rational{BigInt}, Rational{Int128}, FastRational{BigInt}, FastRational{Int128}}

function more_compact_rational(midpoint::Q, radius::R) where {Q<:FieldQ, R<:FieldQ} 
    lo = float(midpoint - radius)
    hi = float(midpoint + radius)
    flnum, flden = compact_rational(lo, hi)
    num, den = trunc(Int64,flnum), trunc(Int64,flden)
    return Q(num, den)
end

function more_compact_rational(midpoint::Q, radius::R) where {Q<:FieldQBig, R<:FieldQ} 
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

bitsof(::Type{T}) where {T} = sizeof(T) * 8
bitsof(x::T) where {T} = sizeof(T) * 8

#=
    maxmag(q) whichever is the larger, abs(numerator) or abs(denominator)
    leading_zeros_maxmag(q) count of leading 0bits in maxmag(q)

    msbitidx(q) 1-based bit index of the most significant bit in maxmag(q)
                zero iff iszero(maxmag(q))
=#
maxmag(q::Rational{T}) where {T<:Integer} = max(abs(q.num), abs(q.den))  
leading_zeros_maxmag(q::Rational{T}) where {T<:Integer} = leading_zeros(maxmag(q))

msbitidx(q::Rational{T}) where {T<:Integer} = bitsof(T) - leading_zeros_maxmag(q)
msbitidx(q1::Rational{T}, q2::Rational{T}) where {T<:Integer} = msbitidx(q1) + msbitidx(q2)

maxmag(q::FastRational{T}) where {T<:FastInt} = max(abs(q.num), abs(q.den))  # q.den != typemin(T)
leading_zeros_maxmag(q::FastRational{T}) where {T<:FastInt} = leading_zeros(maxmag(q))

msbitidx(q::FastRational{T}) where {T<:FastInt} = bitsof(T) - leading_zeros(maxmag(q))
msbitidx(q1::FastRational{T}, q2::FastRational{T}) where {T<:FastInt} = msbitidx(q1) + msbitidx(q2)

#=
msbitidx(q1::T) + msbitidx(q2::T) 
    =  (bitsof(T) - leading_zeros(maxmag(q1))) + (bitsof(T) - leading_zeros(maxmag(q2)))
    =  (bitsof(T) + bitsof(T)) - (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2)))
    =  2*bitsof(T) - (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2)))
=#

mayoverflow(q1::T, q2::T) where {T} = bitsof(T) <= msbitidx(q1, q2)
#=
   = bitsof(T) <= 2*bitsof(T) - (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2)))
   = (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2))) <= 2*bitsof(T) - bitsof(T)
   = (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2))) <= bitsof(T)
=#

mayoverflow(i1::T, i2::T) where {T<:Integer} =
    (leading_zeros(i1) + leading_zeros(i2)) <= bitsof(T)

#=
   this was used in deriving the faster version immediately below

   mayoverflow(q1::Rational{T}, q2::Rational{T}) where {T<:Integer} =
        bitsof(T) >= leading_zeros_maxmag(q1) + leading_zeros_maxmag(q2)
=#

mayoverflow(q1::Rational{T}, q2::Rational{T}) where {T<:Integer} =
    (bitsof(T)<<1) >= leading_zeros(q1.num) + leading_zeros(q1.den) +
                      leading_zeros(q2.num) + leading_zeros(q2.den)

mayoverflow(q1::FastRational{T}, q2::FastRational{T}) where {T<:FastInt} =
    (bitsof(T)<<1) >= leading_zeros(q1.num) + leading_zeros(q1.den) +
                      leading_zeros(q2.num) + leading_zeros(q2.den)


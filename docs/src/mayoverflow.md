
### deriving the expresssion for `mayoverflow`:

```
bitsof(::Type{T}) where {T} = sizeof(T) * 8

maxmag(q::Rational{T}) where {T} = max(abs(q.num), abs(q.den))  # q.den != typemin(T)
magzeros(q::Rational{T}) where {T} = leading_zeros(maxmag(q))

maxbits(q::Rational{T}) where {T} = bitsof(T) - leading_zeros(maxmag(q))
maxbits(q1::Rational{T}, q2::Rational{T}) where {T} = maxbits(q1) + maxbits(q2)

#=
maxbits(q1::T) + maxbits(q2::T) 
    =  (bitsof(T) - leading_zeros(maxmag(q1))) + (bitsof(T) - leading_zeros(maxmag(q2)))
    =  (bitsof(T) + bitsof(T)) - (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2)))
    =  2*bitsof(T) - (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2)))
=#

mayoverflow(q1::T, q2::T) where {T} = bitsof(T) <= maxbits(q1, q2)
#=
   = bitsof(T) <= 2*bitsof(T) - (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2)))
   = (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2))) <= 2*bitsof(T) - bitsof(T)
   = (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2))) <= bitsof(T)
=#

mayoverflow(q1::T, q2::T) where {T} =
    (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2))) <= bitsof(T)

mayoverflow(q1::Rational{T}, q2::Rational{T}) where {T} = bitsof(T) >= magzeros(q1) + magzeros(q2)
```

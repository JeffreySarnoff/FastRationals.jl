# Arithmetic Overflow

## 

#### multiplying two n-bit system integers, both nonnegative

```
function mult_overflows(x::T, y::T) where {T<:Signed}
    @assert x > 0 && y > 0
    leadzeros = leading_zeros(x) + leading_zeros(y)
    leadzeros < bitsof(T)
end

function mult_cannot_overflow(x::T, y::T) where {T<:Signed}
    @assert x > 0 && y > 0
    leadzeros = leading_zeros(x) + leading_zeros(y)
    leadzeros > bitsof(T)
end
```

When `leading_zeros(x) + leading_zeros(y) == bitsof(T)`,
the state of the sign bit in the product determines
overflow _has_ occured. Negative values overflowed.

#### multiplying two n-bit system integers, both negative

```
function mult_overflows(x::T, y::T) where {T<:Signed}
    @assert x < 0 && y < 0
    leadzeros = leading_zeros(x) + leading_zeros(y)
    leadzeros < bitsof(T) - 1
end

function mult_cannot_overflow(x::T, y::T) where {T<:Signed}
    @assert x < 0 && y < 0
    leadzeros = leading_zeros(x) + leading_zeros(y)
    leadzeros > bitsof(T) + 1
end
```

When `leading_zeros(x) + leading_zeros(y) == bitsof(T)`,
the state of the sign bit in the product determines
overflow _has_ occured. Negative values overflowed.

#### multiplying two n-bit system integers, mixed sign

```
function mult_overflows(x::T, y::T) where {T<:Signed}
    @assert x < 0 && y >= 0
    leadbits = leading_ones(x) + leading_zeros(y)
    leadbits < bitsof(T) - 1
end

function mult_cannot_overflow(x::T, y::T) where {T<:Signed}
    @assert x < 0 && y >= 0
    leadbits = leading_ones(x) + leading_zeros(y)
    leadbits > bitsof(T) + 1
end
```


    

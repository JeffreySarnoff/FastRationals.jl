safemul(x::T, y::T) where {T<:FastInteger} =
    usewidemul(x,y) ? widemul(x,y) : x*y

@inline function usewidemul(x::T, y::T) where {T<:FastSigned}
    iszero( (leading_zeros(abs(x)) + leading_zeros(abs(y))) >> sizeof(T) )
end

@inline function usewidemul(x::T, y::T) where {T<:FastUnsigned}
    iszero( (leading_zeros(x) + leading_zeros(t)) >> sizeof(T) )
end

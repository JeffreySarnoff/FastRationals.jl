@inline mulwider(x::T, y::T) where {T<:Integer} = usewidemul(x,y) ? widemul(x,y) : x*y

@inline usewidemul(x::T, y::T) where {T<:Integer} =
    (leading_zeros(abs(x)) + leading_zeros(abs(y))) < 8*sizeof(T)



function usewidemul(x::T, y::T) where {T<:Base.BitInteger}
     lead0s = leading_zeros(abs(x)) + leading_zeros(abs(y))
     return iszero(lead0s >> sizeof(T)*3)
end

    
    

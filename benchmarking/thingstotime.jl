function sums_toward_half(::Type{T}, n; details::Bool=falsee) where {T}
    one_third = onethird(T)
    one_ninth = one_third * one_third 
    s = one_third + one_ninth
    t = one_third * one_ninth
    
    n = abs(n)
    while n>1
     n -= 1
     s += t
     t *= one_third
    end
    
    return !details ? s : (t, s) # debugging info 
end


function onethird(::Type{Q}) where Q
    T = basistype(Q)
    return Q(one(T), one(T)+one(T)+one(T))
end


slow17 = sums_toward_half(Rational{Int64},17)
# (1743392200//3486784401, 1//3486784401)

fast17 = sums_toward_half(FastRational{Int64, IsReduced},17)
# (1743392200//3486784401, 1//3486784401)

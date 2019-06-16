

function sums_toward_half(::Type{T}, n) where {T}
    athird = onethird(T)
    a2 = athird * athird 
    s = athird + a2
    t = athird * a2;
    while n>0
     s = s + t
     n = n - 1
     t = t * athird
    end
    return s, t
end

function onethird(::Type{Q}) where Q
    T = basistype(Q)
    return Q(one(T), one(T)+one(T)+one(T))
end


slow17 = sums_toward_half(Rational{Int64},17)
# (1743392200//3486784401, 1//3486784401)

fast17 = sums_toward_half(FastRational{Int64, IsReduced},17)
# (1743392200//3486784401, 1//3486784401)

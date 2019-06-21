function adds(x,y,z)
    a = x + y
    b = a + z
    c = b + a
    d = c + x
    return d
end

function muls(x,y,z)
    a = x * y
    b = a * z
    c = z * x
    d = a * b
    return d
end

function sums_toward_half(::Type{T}, n; details::Bool=false) where {T}
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
    return Q(one(Int32), 3*one(Int32))
end


slow17 = sums_toward_half(Rational{Int32},17)
# 193710244//387420489

fast17 = sums_toward_half(FastRational,17)
# 193710244//387420489


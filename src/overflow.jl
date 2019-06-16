# core parts of add, sub, mul, div

@inline function addovf(x, y)
    ovf = false
    numer, ovfl = mul_with_overflow(x.num, x.den) # here, numer is a temp
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, x.num) # here, denom is a temp
    ovf |= ovfl
    numer, ovfl = add_with_overflow(numer, denom) # numerator of sum
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, y.den) # denominator of sum
    ovf |= ovfl
    return numer, denom, ovf
end

@inline function subovf(x, y)
    ovf = false
    numer, ovfl = mul_with_overflow(x.num, x.den) # here, numer is a temp
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, y.num) # here, denom is a temp
    ovf |= ovfl
    numer, ovfl = sub_with_overflow(numer, denom) # numerator of difference
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, y.den) # denominator of difference
    ovf |= ovfl
    return numer, denom, ovf
end

@inline function mulovf(x, y)
    ovf = false
    numer, ovfl = mul_with_overflow(x.num, y.num)
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, y.den)
    ovf |= ovfl
    return numer, denom, ovf
end

@inline function divovf(x, y)
    ovf = false
    numer, ovfl = mul_with_overflow(x.num, y.den)
    ovf |= ovfl
    denom, ovfl = mul_with_overflow(x.den, y.num)
    ovf |= ovfl
    return numer, denom, ovf
end

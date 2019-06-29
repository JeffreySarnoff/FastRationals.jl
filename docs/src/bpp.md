# Using the BBP formula

The Bailey–Borwein–Plouffe formula (BBP formula) is a formula for π

```
const big1 = BigInt(1)
const big2 = BigInt(2)
const big4 = BigInt(4)
const big5 = BigInt(5)
const big6 = BigInt(6)
const big8 = BigInt(8)
const big16 = BigInt(16)

function bpp(::Type{T}, n) where {T}
    result = zero(T)
    for k = 0:n
       eightk = big8 * k
       cur = T(big4,eightk+1) -
             T(big2,eightk+4) -
             T(big1,eightk+5) -
             T(big1,eightk+6)
       cur = T(big1, big16^k) * cur
       result = result + cur
    end
    return result
end

# err ~1e-28, 403 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},20);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},20);
julia> floor(Int,systemqtime/fastqtime)
3.9

# err ~1e-54, 1_328 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},40);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},40);
julia> floor(Int,systemqtime/fastqtime)
4.5

# err ~1e-102, 4_671 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},80);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},80);
julia> round(systemqtime/fastqtime, digits=2)
4.8

# err ~1e247, 26_431 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},200);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},200);
julia> floor(Int,systemqtime/fastqtime)
2.5

# err ~1e368, 57_914 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},300);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},300);
julia> floor(Int,systemqtime/fastqtime)
1.25

# err ~1e402, 68_889 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},328);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},328);
julia> floor(Int,systemqtime/fastqtime)
0.99

# err ~1e610, 157_166 digits in num, den
julia> systemqtime = @belapsed bpp(Rational{BigInt},500);
julia> fastqtime = @belapsed bpp(FastRational{BigInt},500);
julia> floor(Int,systemqtime/fastqtime)
0.5
```

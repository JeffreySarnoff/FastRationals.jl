# Using the BBP formula
#
# The Bailey–Borwein–Plouffe formula (BBP formula) is a formula for π

using FastRationals
using BenchmarkTools
using BenchmarkTools

const BT=BenchmarkTools.DEFAULT_PARAMETERS;
BT.overhead=BenchmarkTools.estimate_overhead();
BT.evals=1; ; BT.time_tolerance = 5.0e-7; BT.samples = 15;



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


# err ~1e-54, 1_328 digits in num, den
systemqtime = @belapsed bpp(Rational{BigInt},   10);
fastqtime = @belapsed bpp(FastRational{BigInt}, 10);
bpp10 = round(systemqtime/fastqtime, digits=1)

# err ~1e-102, 4_671 digits in num, den
systemqtime = @belapsed bpp(Rational{BigInt},   25);
fastqtime = @belapsed bpp(FastRational{BigInt}, 25);
bpp25 = round(systemqtime/fastqtime, digits=1)

# err ~1e247, 26_431 digits in num, den
systemqtime = @belapsed bpp(Rational{BigInt},   50);
fastqtime = @belapsed bpp(FastRational{BigInt}, 50);
bpp50 = round(systemqtime/fastqtime, digits=1)

# err ~1e368, 57_914 digits in num, den
systemqtime = @belapsed bpp(Rational{BigInt},   100);
fastqtime = @belapsed bpp(FastRational{BigInt}, 100);
bpp100 = round(systemqtime/fastqtime, digits=1)

# relspeeds meet at n=328

# err ~1e368, 57_914 digits in num, den
systemqtime = @belapsed bpp(Rational{BigInt},   150);
fastqtime = @belapsed bpp(FastRational{BigInt}, 150);
bpp150 = round(systemqtime/fastqtime, digits=1)

# err ~1e368, 57_914 digits in num, den
systemqtime = @belapsed bpp(Rational{BigInt},   200);
fastqtime = @belapsed bpp(FastRational{BigInt}, 200);
bpp200 = round(systemqtime/fastqtime, digits=1)


relspeed = (bpp10=bpp10, bpp25=bpp25, bpp50=bpp50, bpp100=bpp100, bpp150=bpp150, bpp200=bpp200)

# Using the BBP formula
#
# The Bailey–Borwein–Plouffe formula (BBP formula) is a formula for π


#=
Computing Bailey–Borwein–Plouffe formula for Pi
to ascertain the performance of FastRational{BigInt}
relative to Rational{BigInt} by BPP iterations

FastRational{BigInt}s perform better below n=328
Rational{BigInt}s     perform better above n=330

As BPP iterations increase, numerator and denominator grow.
After some digit count in numerator aor denominator, ~10_000,
The extra time spent in divgcd reductions becomes less than
the time spent performing arithmetic on very large integers;
so reducing the numerator and denominator begins to win.
=#

using FastRationals
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


systemqtime = @belapsed bpp(Rational{BigInt},   15);
fastqtime = @belapsed bpp(FastRational{BigInt}, 15);
bpp15 = round(systemqtime/fastqtime, digits=1)

systemqtime = @belapsed bpp(Rational{BigInt},   125);
fastqtime = @belapsed bpp(FastRational{BigInt}, 125);
bpp125 = round(systemqtime/fastqtime, digits=1)

systemqtime = @belapsed bpp(Rational{BigInt},   250);
fastqtime = @belapsed bpp(FastRational{BigInt}, 250);
bpp250 = round(systemqtime/fastqtime, digits=1)

# relspeeds meet at n=328

systemqtime = @belapsed bpp(Rational{BigInt},   500);
fastqtime = @belapsed bpp(FastRational{BigInt}, 500);
bpp500 = round(systemqtime/fastqtime, digits=1)

systemqtime = @belapsed bpp(Rational{BigInt},   1000);
fastqtime = @belapsed bpp(FastRational{BigInt}, 1000);
bpp1000 = round(systemqtime/fastqtime, digits=1)

systemqtime = @belapsed bpp(Rational{BigInt},   2000);
fastqtime = @belapsed bpp(FastRational{BigInt}, 2000);
bpp2000 = round(systemqtime/fastqtime, digits=1)

systemqtime = @belapsed bpp(Rational{BigInt},   3000);
fastqtime = @belapsed bpp(FastRational{BigInt}, 3000);
bpp3000 = round(systemqtime/fastqtime, digits=1)



relspeeds = (bpp15=bpp15, bpp125=bpp125, bpp250=bpp250, 
             bpp500=bpp500, bpp1000=bpp1000, bpp2000=bpp2000,
             bpp3000=bpp3000)

relspeeds = (bpp15 = 0.3, bpp125 = 0.3, bpp250 = 0.7, bpp500 = 2.4, bpp1000 = 8.1, bpp2000 = 20.9, bpp3000 = 36.0)

xs = [15,125,250,500,1000,2000,3000];
ys = [relspeeds...,];

using GR
plot(xs, ys, size=(500,500))

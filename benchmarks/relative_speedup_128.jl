using FastRationals
using Polynomials, LinearAlgebra, BenchmarkTools, MacroTools

BenchmarkTools.DEFAULT_PARAMETERS.evals = 1;
BenchmarkTools.DEFAULT_PARAMETERS.samples = 300;
BenchmarkTools.DEFAULT_PARAMETERS.time_tolerance = 2.0e-9;
BenchmarkTools.DEFAULT_PARAMETERS.overhead = BenchmarkTools.estimate_overhead();

walk(x, inner, outer) = outer(x)
walk(x::Expr, inner, outer) = outer(Expr(x.head, map(inner, x.args)...))
postwalk(f, x) = walk(x, x -> postwalk(f, x), f)

function referred(expr::Expr)
    if expr.head == :$
        :($(Expr(:$, :(Ref($(expr.args...)))))[])
    else
        expr
    end
end
referred(x)  = x

"""
    @noelide _bmacro_ expression
where _bmacro_ is one of @btime, @belapsed, @benchmark
Wraps all interpolated code in _expression_ in a __Ref()__ to
stop the compiler from cheating at simple benchmarks. Works
with any macro that accepts interpolation
#Example
    julia> @btime \$a + \$b
      0.024 ns (0 allocations: 0 bytes)
    3
    julia> @noelide @btime \$a + \$b
      1.277 ns (0 allocations: 0 bytes)
    3
"""
macro noelide(expr)
    out = postwalk(referred, expr) |> esc
end



function testadd(x,y,z)
   a = x + y
   b = a + z
   c = b + a
   d = c + x
   return d
end

function testmul(x,y,z)
   a = x * y
   b = a * z
   c = z * x
   d = a * b
   return d
end

function testarith(x,y,z)
   a = x + y
   b = x * y
   c = z - b
   d = a / c
   return d
end


w32,x32,y32,z32 = Rational{Int32}.([1//12, -2//77, 3//54, -4//17]); q32 = Int32(1)//Int32(7);
u32,v32 = w32+z32, w32-z32

w64,x64,y64,z64 = Rational{Int64}.([1//12, -2//77, 3//54, -4//17]); q64 = Int64(1)//Int64(7);
u64,v64 = w64+z64, w64-z64

w128,x128,y128,z128 = Rational{Int128}.([1//12, -2//77, 3//54, -4//17]); q128 = Int128(1)//Int128(7);
u128,v128 = w128+z128, w128-z128

ply32 = Poly([w32, x32, y32, z32]);
ply64 = Poly([w64, x64, y64, z64]);
ply64w = Poly([u64, v64, w64, x64, y64, z64]);
ply128 = Poly([w128, x128, y128, z128]);
ply128w = Poly([u128, v128, w128, x128, y128, z128, u128, v128, w128, x128, y128, z128, w128]);

a32,b32,c32,d32,e32,f32 = FastQ32.((w32,x32,y32,z32,u32,v32)); fastq32 = FastQ32(q32);
fastply32=Poly([a32,b32,c32,d32]);

a64,b64,c64,d64,e64,f64 = FastQ64.((w64,x64,y64,z64,u64,v64)); fastq64 = FastQ64(q64);
fastply64=Poly([a64,b64,c64,d64]);
fastply64w=Poly([a64,b64,c64,d64,e64,f64]);

a128,b128,c128,d128,e128,f128 = FastQ128.((w128,x128,y128,z128,u128,v128)); fastq128 = FastQ128(q64);
fastply128=Poly([a128,b128,c128,d128]);
fastply128w = Poly(FastRational{Int128}.([u128, v128, w128, x128, y128, z128, u128, v128, w128, x128, y128, z128, w128]));


m = [1//1 1//5 1//9 1//13; 1//2 1//6 1//10 1//14; 1//3 1//7 1//11 1//15; 1//4 1//8 1//12 1//16];
m32 = Rational{Int32}.(m);
m64 = Rational{Int64}.(m);
m128 = Rational{Int128}.(m);
mfast32 = FastQ32.(m);
mfast64 = FastQ64.(m);
mfast128 = FastQ128.(m);

relspeed_arith32 =
    round( (@noelide @belapsed testarith($x32,$y32,$z32)) /
           (@noelide @belapsed testarith($a32,$b32,$c32)), digits=1);
relspeed_arith64 =
   round( (@noelide @belapsed testarith($x64,$y64,$z64)) /
          (@noelide @belapsed testarith($a64,$b64,$c64)), digits=1);
relspeed_arith128 =
   round( (@noelide @belapsed testarith($x128,$y128,$z128)) /
          (@noelide @belapsed testarith($a128,$b128,$c128)), digits=1);

relspeed_add32 =
  round( (@noelide @belapsed testadd($x32,$y32,$z32)) /
         (@noelide @belapsed testadd($a32,$b32,$c32)), digits=1);
relspeed_add64 =
 round( (@noelide @belapsed testadd($x64,$y64,$z64)) /
        (@noelide @belapsed testadd($a64,$b64,$c64)), digits=1);
relspeed_add128 =
   round( (@noelide @belapsed testadd($x128,$y128,$z128)) /
          (@noelide @belapsed testadd($a128,$b128,$c128)), digits=1);

relspeed_mul32 =
 round( (@noelide @belapsed testmul($x32,$y32,$z32)) /
        (@noelide @belapsed testmul($a32,$b32,$c32)), digits=1);
relspeed_mul64 =
 round( (@noelide @belapsed testmul($x64,$y64,$z64)) /
        (@noelide @belapsed testmul($a64,$b64,$c64)), digits=1);
relspeed_mul128 =
   round( (@noelide @belapsed testmul($x128,$y128,$z128)) /
          (@noelide @belapsed testmul($a128,$b128,$c128)), digits=1);

relspeed_ply32 =
 round( (@noelide @belapsed polyval($ply32, $q32)) /
        (@noelide @belapsed polyval($fastply32, $fastq32)), digits=1);
relspeed_ply64 =
 round( (@noelide @belapsed polyval($ply64, $q64)) /
        (@noelide @belapsed polyval($fastply64, $fastq64)), digits=1);
relspeed_ply64w =
 round( (@noelide @belapsed polyval($ply64w, $q64)) /
        (@noelide @belapsed polyval($fastply64w, $fastq64)), digits=1);
relspeed_ply128 =
 round( (@noelide @belapsed polyval($ply128, $q128)) /
        (@noelide @belapsed polyval($fastply128, $fastq128)), digits=1);
relspeed_ply128w =
 round( (@noelide @belapsed polyval($ply128w, $q128)) /
        (@noelide @belapsed polyval($fastply128w, $fastq128)), digits=1);


relspeed_matmul32 =
  round( (@noelide @belapsed $m32*$m32) /
         (@noelide @belapsed $mfast32*$mfast32), digits=1);
relspeed_matmul64 =
  round( (@noelide @belapsed $m64*$m64) /
         (@noelide @belapsed $mfast64*$mfast64), digits=1);
relspeed_matmul128 =
  round( (@noelide @belapsed $m128*$m128) /
         (@noelide @belapsed $mfast128*$mfast128), digits=1);

relspeed_matlu32 =
  round( (@noelide @belapsed lu($m32)) /
         (@noelide @belapsed lu($mfast32)), digits=1);
relspeed_matlu64 =
  round( (@noelide @belapsed lu($m64)) /
         (@noelide @belapsed lu($mfast64)), digits=1);
relspeed_matlu128 =
  round( (@noelide @belapsed lu($m128)) /
         (@noelide @belapsed lu($mfast128)), digits=1);

relspeed_matinv32 =
  round( (@noelide @belapsed inv($m32)) /
         (@noelide @belapsed inv($mfast32)), digits=1);
relspeed_matinv64 =
  round( (@noelide @belapsed inv($m64)) /
         (@noelide @belapsed inv($mfast64)), digits=1);
relspeed_matinv128 =
  round( (@noelide @belapsed inv($m128)) /
         (@noelide @belapsed inv($mfast128)), digits=1);

relspeeds = string(
"\n\n\trelative speeds",
"\n\t (32)\t (64) \t (128)\n\n",
"mul:   \t $relspeed_mul32 \t $relspeed_mul64  \t $relspeed_mul128 \n",
"muladd:\t $relspeed_arith32 \t $relspeed_arith64 \t $relspeed_arith128 \n",
"add:   \t $relspeed_add32 \t $relspeed_add64 \t $relspeed_add128 \n",
"poly:  \t $relspeed_ply32 \t $relspeed_ply64w \t $relspeed_ply128w \n",
"matmul:\t $relspeed_matmul32 \t $relspeed_matmul64 \t $relspeed_matmul128 \n",
"matlu: \t $relspeed_matlu32 \t $relspeed_matlu64 \t $relspeed_matlu128 \n",
"matinv:\t $relspeed_matinv32 \t $relspeed_matinv64 \t $relspeed_matinv128 \n",
);

println(relspeeds);
;

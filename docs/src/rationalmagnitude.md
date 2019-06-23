# rational magnitude in action

This page delves deeper into the operational character of this current implementation for FastRationals.

We use the leading terms of this series as an investigative tool, a metaphorical flashlight that works.

|      the series formulation         |                                                              |
|:-----------------------------------:|:-------------------------------------------------------------|
| ![e_series](assets/e_series.PNG)    |     nterms = 21;
|                                     |     factorialseq64 = [1//factorial(i) for i=0:nterms-1]      |
|                                     |     factorialseq32 = Rational{Int32}.(factorialseq64)        |
|                                     |     factorialseq64fast = FastQ64.(factorialseq64)            |
|                                     |     factorialseq32fast = FastQ32.(factorialseq32)            |

```
using FastRationals, BenchmarkTools, MacroTools, UnicodePlots

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

BenchmarkTools.DEFAULT_PARAMETERS.evals = 1;
BenchmarkTools.DEFAULT_PARAMETERS.overhead = BenchmarkTools.estimate_overhead();
BenchmarkTools.DEFAULT_PARAMETERS.time_tolerance = 2.0e-6;
BenchmarkTools.DEFAULT_PARAMETERS.samples = 200;
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 3;

nterms = 20;     # first 2 terms are (1//1), add one at the end 
rational_terms = [1//factorial(i) for i=1:nterms]; 
fastq64_terms  = FastRational{Int64}.(rational_terms);

# we want successively longer sequences so we can chart computational behavior
rational_seqs = []
fastq64_seqs  = []
for i in 1:nterms
     global rational_terms, fastq64terms, rational_seqs, fastq64_seqs
     push!(rational_seqs, rational_terms[1:nterms])
     push!(fastq64_seqs, fastq64_terms[1:nterms])
end;

# we time the summations so we can chart relative performance
rational_times = []
fastq64_times  = []
for i in 1:nterms
     global rational_seqs, fastq64_seqs, rational_times, fastq64_times
     rseq = rational_seqs[i]
     fseq = fastq64_seqs[i]
     rationaltime = @belapsed sum($rseq)
     fastq64time  = @belapsed sum($fseq)
     push!(rational_times, rationaltime)
     push!(fastq64_times, fastq64time)
end;

rational_to_fast64 = Float32.(rational_times ./ fastq64_times);

using FastRationals, BenchmarkTools

BenchmarkTools.DEFAULT_PARAMETERS.evals = 1;
BenchmarkTools.DEFAULT_PARAMETERS.samples = 50;
BenchmarkTools.DEFAULT_PARAMETERS.time_tolerance = 1.0e-7;
BenchmarkTools.DEFAULT_PARAMETERS.overhead = BenchmarkTools.estimate_overhead();

function Base.rand(::Type{Rational{I}}, n::Int=1) where {I<:Base.BitInteger}
    n = max(1, n)
    numers = rand(I, n)
    denoms = map(x->max(1,x), abs.(rand(I, n)))
    return numers .// denoms
end

function Base.rand(::Type{Rational{BigInt}}, n::Int=1)
    n = max(1, n)
    qs = rand(Rational{Int128}, n)
    return Rational{BigInt}.(qs)
end

q200 = rand(Rational{BigInt}, 200);
fq200 = FastRational{BigInt}.(q200);

q500 = rand(Rational{BigInt}, 500);
fq500 = FastRational{BigInt}.(q500);

q200sum = @belapsed sum($q200)
fq200sum = @belapsed sum($fq200)
q200prod = @belapsed prod($q200)
fq200prod = @belapsed prod($fq200)

q500sum = @belapsed sum($q500)
fq500sum = @belapsed sum($fq500)
q500prod = @belapsed prod($q500)
fq500prod = @belapsed prod($fq500)

println(string("sum 200 Rational, reltime = $(round(q200sum/fq200sum))"))
println(string("sum 500 Rational, reltime = $(round(q500sum/fq500sum))"))
println("")
println(string("prod 200 Rational, reltime = $(round(q200prod/fq200prod))"))
println(string("prod 500 Rational, reltime = $(round(q500prod/fq500prod))"))

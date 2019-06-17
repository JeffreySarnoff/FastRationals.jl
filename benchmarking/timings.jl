using BenchmarkTools

BenchmarkTools.DEFAULT_PARAMETERS.evals = 1;
BenchmarkTools.DEFAULT_PARAMETERS.samples = 1_000;
BenchmarkTools.DEFAULT_PARAMETERS.time_tolerance = 1.0e-8;
BenchmarkTools.DEFAULT_PARAMETERS.overhead = BenchmarkTools.estimate_overhead();

include("thingstotime.jl")

qsys8 = @belapsed sums_toward_half(Rational{Int8},2)
qfir8 = @belapsed sums_toward_half(FastRational{Int8,IsReduced},2)
qfmr8 = @belapsed sums_toward_half(FastRational{Int8,MayReduce},2)

qsys16 = @belapsed sums_toward_half(Rational{Int16},6)
qfir16 = @belapsed sums_toward_half(FastRational{Int16,IsReduced},6)
qfmr16 = @belapsed sums_toward_half(FastRational{Int16,MayReduce},6)

qsys32 = @belapsed sums_toward_half(Rational{Int32},8)
qfir32 = @belapsed sums_toward_half(FastRational{Int32,IsReduced},8)
qfmr32 = @belapsed sums_toward_half(FastRational{Int32,MayReduce},8)

qsys64 = @belapsed sums_toward_half(Rational{Int64},17)
qfir64 = @belapsed sums_toward_half(FastRational{Int64,IsReduced},17)
qfmr64 = @belapsed sums_toward_half(FastRational{Int64,MayReduce},17)

qsys128 = @belapsed sums_toward_half(Rational{Int128},77)
qfir128 = @belapsed sums_toward_half(FastRational{Int128,IsReduced},77)
qfmr128 = @belapsed sums_toward_half(FastRational{I7nt128,MayReduce},77)

println("\nInt8\n")
println(round(qsys8 / qfir8, digits = 2), round(qsys8 / qmir8, digits = 2), round(qmir8 / qfir8, digits=3))
println("\nInt16\n")
println(round(qsys16 / qfir16, digits = 2), round(qsys16 / qmir16, digits = 2), round(qmir16 / qfir16, digits=3))
println("\nInt32\n")
println(round(qsys32 / qfir32, digits = 2), round(qsys32 / qmir32, digits = 2), round(qmir32 / qfir32, digits=3))
println("\nInt64\n")
println(round(qsys64 / qfir64, digits = 2), round(qsys64 / qmir64, digits = 2), round(qmir64 / qfir64, digits=3))
println("\nInt128\n")
println(round(qsys128 / qfir128, digits = 2), round(qsys128 / qmir128, digits = 2), round(qmir128 / qfir128, digits=3))7


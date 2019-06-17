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
qfmr128 = @belapsed sums_toward_half(FastRational{Int128,MayReduce},77)


function reltimes(withtype, sys2fir, sys2fmr, fmr2fir)
  print("\n\n$withtype:\t")
  sysfir,sysfmr,fmrfir = round(qsys8 / qfir8, digits = 2), round(qsys8 / qfmr8, digits = 2), round(qfmr8 / qfir8, digits=3);
  print("sys/fir: $sysfir\t sys/fmr: $sysfmr\t fmr/fir: $fmrfir\n\n")
end  

reltimes(Int8, round(qsys16 / qfir16, digits = 2), round(qsys16 / qfmr16, digits = 2), round(qfmr16 / qfir16, digits=3))
reltimes(round(qsys32 / qfir32, digits = 2), round(qsys32 / qfmr32, digits = 2), round(qfmr32 / qfir32, digits=3))
reltimes(round(qsys64 / qfir64, digits = 2), round(qsys64 / qfmr64, digits = 2), round(qfmr64 / qfir64, digits=3))
reltimes(round(qsys128 / qfir128, digits = 2), round(qsys128 / qfmr128, digits = 2), round(qfmr128 / qfir128, digits=3))


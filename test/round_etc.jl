@testset "round_etc" begin
  for I in (UInt8, UInt16, UInt32, UInt64, UInt128, 
            Int8, Int16, Int32, Int64, Int128, BigInt)
    @eval begin
      sq = Rational{$I}(33, 32)
      fq = FastRational{$I}(33, 32)
      @test floor($I, sq) == floor($I, fq)
      @test ceil($I, sq) == ceil($I, fq)
      @test trunc($I, sq) == trunc($I, fq)
      @test round($I, sq) == round($I, fq)
    end
  end
end

@testset "enhanced rounding" begin
  for I in (UInt8, UInt16, UInt32, UInt64, UInt128, 
            Int8, Int16, Int32, Int64, Int128, BigInt)
    @eval begin
      fq = FastRational{$I}(33, 32)
      fqf = float(fq)
      @test round($I, fq, RoundUp) == round($I, fqf, RoundUp)
      @test round($I, fq, RoundDown) == round($I, fqf, RoundDown)
      @test round($I, fq, RoundToZero) == round($I, fqf, RoundToZero)
      @test round($I, fq, RoundNearest) == round($I, fqf, RoundNearest)
    end
  end
  fq = FastRational{Int64}(33, 32)
  fqf = float(fq)
  @test round(Integer, fq, RoundUp) == round(Integer, fqf, RoundUp)
  @test round(Integer, fq, RoundDown) == round(Integer, fqf, RoundDown)
  @test round(Integer, fq, RoundToZero) == round(Integer, fqf, RoundToZero)
  @test round(Integer, fq, RoundNearest) == round(Integer, fqf, RoundNearest)
end
  

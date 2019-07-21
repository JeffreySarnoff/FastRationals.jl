@testset "ceil_floor_trunc" begin
  for I in (UInt8, UInt16, UInt32, UInt64, UInt128, 
            Int8, Int16, Int32, Int64, Int128, BigInt)
    @eval begin
      sq = Rational{$I}(33, 32)
      fq = FastRational{$I}(33, 32)
      @test floor($I, sq) == floor($I, fq)
      @test ceil($I, sq) == ceil($I, fq)
      @test trunc($I, sq) == trunc($I, fq)
    end
  end
end

@testset "round" begin
  for I in (UInt8, UInt16, UInt32, UInt64, UInt128, 
            Int8, Int16, Int32, Int64, Int128, BigInt)
    @eval begin
      sq = Rational{$I}(33, 32)
      fq = FastRational{$I}(33, 32)
      @test round($I, sq) == round($I, fq)
      @test round($I, sq, RoundUp) == round($I, fq, RoundUp)
      @test round($I, sq, RoundDown) == round($I, fq, RoundDown)
      @test round($I, sq, RoundToZero) == round($I, fq, RoundToZero)
      @test round($I, sq, RoundNearest) == round($I, fq, RoundNearest)      
    end
  end
end


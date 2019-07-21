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

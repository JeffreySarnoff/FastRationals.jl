
@testset "avoid overflow during add/subtract" begin
    x = 2*10^11
    @test FastRational(1, 2x) + FastRational(1, 3x) == FastRational(5, 6x)
    @test FastRational(1, 2x) - FastRational(1, 3x) == FastRational(1, 6x)
end

@testset "constructors1" begin
    @test FastRational(2,4).num == 1
    @test FastRational(2,4).den == 2
    @test FastRational((2,4)).num == 2
    @test FastRational((2,4)).den == 4
end

@testset "convert from Rational" begin
    @test FastRational(1//2) == FastRational(1, 2)
    @test FastRational(2, 4) == FastRational(1, 2)
end

@testset "conversion type" begin
    @test typeof(convert(FastRational{Int64,FastRationals.MayReduce}, FastRational(1,2))) ==
    FastRational{Int64,FastRationals.MayReduce}
end

@testset "inverse matrix" begin
    B = FastRational.([(1,2) (1,3); (1,3) (1,4)])
    @test inv(B) == FastRational.([(18,1) (-24,1); (-24,1) (36,1)])
end

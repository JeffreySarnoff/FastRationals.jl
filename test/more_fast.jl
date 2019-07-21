@testset "more $N" for (N, FR, Ti) = (("FastQ32", FastQ32, Int32), ("FastQ64", FastQ64, Int64))

    @testset "constructors $N" begin
        @test_throws DivideError FR(1, 0)
        @test_throws DomainError FR(Ti(1), typemin(Ti))
        @test_throws DomainError FR(1, typemin(Ti))
        mx = FR(typemin(Ti))
        @test_throws DivideError inv(mx)
        @test FR(typemin(Ti) + 10000) - FR(10000) == mx
        my = FR(typemin(Ti) + 10000) - FR(10000)
        @test_throws DivideError Ti(1) / my
    end

    @testset "avoid overflow during add/subtract $N" begin
        x =  div(typemax(Ti),6)
        @test FR(17, 2x) + FR(17, 3x) == FR(85, 6x)
        @test FR(17, 2x) - FR(17, 3x) == FR(17, 6x)
    end

    @testset "constructors1 $N" begin
        @test FastRational{Ti}(Ti(2),Ti(4),Val(true)).num == 2
        @test FastRational{Ti}(Ti(2),Ti(4),Val(true)).den == 4
        @test FastRational{Ti}(2,4).num == 1
        @test FastRational{Ti}(2,4).den == 2
        @test FR((2,4)).num == 1
        @test FR((2,4)).den == 2
    end

    @testset "convert from Rational $N" begin
        @test FR(1//2) == FR(1, 2)
        @test FR((2, 4)) == FR(1, 2)
    end

    @testset "inverse matrix $N" begin
        B = FR.([(1,2) (1,3); (1,3) (1,4)])
        @test inv(B) == FR.([(18,1) (-24,1); (-24,1) (36,1)])
    end

end

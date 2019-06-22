FR = FastQ32

@testset "FastQ32" begin
    @test FR(1//1) == 1
    @test FR(2//2) == 1
    @test FR(1//1) == 1//1
    @test FR(2//2) == 1//1
    @test FR(2//4) == FR(8//16)
    @test FR(1//2) + FR(1//2) == 1
    @test FR((-1)//3) == FR(-(1//3)) == -(1//3)
    @test FR(1//2) + FR(3//4) == FR(5//4) == 5//4
    @test FR(1//3) * FR(3//4) == FR(1//4) == 1//4
    @test FR(1//2) / FR(3//4) == FR(2//3)

    @test_throws OverflowError -FR(0x01//0x0f)
    @test_throws OverflowError -FR(typemin(Int)//1)
    @test_throws OverflowError FR(typemax(Int)//3) + 1
    @test_throws OverflowError FR(typemax(Int)//3) * 2
    @test FR(typemax(Int)//1) * FR(1//typemax(Int)) == 1
    @test FR(typemax(Int)//1) / FR(typemax(Int)//1) == 1
    @test FR(1//typemax(Int)) / FR(1//typemax(Int)) == 1
    @test_throws OverflowError FR(1//2)^63

    for a = -5:5, b = -5:5
        if a == b == 0; continue; end
        if ispow2(b)
            @test FR(a//b) == FR(a/b)
            @test convert(FastRational,a/b) == FR(a//b) 
        end
        # @test rationalize(a/b) == a//b
        @test FR(a//b) == FR(a//b)
        if b == 0
            @test_throws DivideError round(Integer,FR(a//b)) == round(Integer,a/b)
        else
            @test round(Integer,FR(a//b)) == round(Integer,a/b)
        end
        for c = -5:5
            @test (FR(a//b) == c) == (a/b == c)
            @test (FR(a//b) != c) == (a/b != c)
            @test (FR(a//b) <= c) == (a/b <= c)
            @test (FR(a//b) <  c) == (a/b <  c)
            @test (FR(a//b) >= c) == (a/b >= c)
            @test (FR(a//b) >  c) == (a/b >  c)
            for d = -5:5
                if b == d == 0; continue; end
                if c == d == 0; continue; end
                @test (FR(a//b) == FR(c//d)) == (a/b == c/d)
                @test (FR(a//b) != FR(c//d)) == (a/b != c/d)
                @test (FR(a//b) <= FR(c//d)) == (a/b <= c/d)
                @test (FR(a//b) <  FR(c//d)) == (a/b <  c/d)
                @test (FR(a//b) >= FR(c//d)) == (a/b >= c/d)
                @test (FR(a//b) >  FR(c//d)) == (a/b >  c/d)
            end
        end
    end

    @test 0.5 == FR(1//2)
    @test 0.1 != FR(1//10)
    @test 1/3 < FR(1//3)
    @test !(FR(1//3) < 1/3)
    @test -1/3 < FR(1//3)
    @test -1/3 > FR(-1//3)
    @test 1/3 > FR(-1//3)
    @test 1/5 > FR(1//5)

    # PR 29561
    @test abs(one(FastRational{UInt,IsReduced})) === one(FastRational{UInt,IsReduced})
    @test abs(one(FastRational{Int,IsReduced})) === one(FastRational{Int,IsReduced})
    @test abs(-one(FastRational{Int,MayReduce})) === one(FastRational{Int,MayReduce})
end

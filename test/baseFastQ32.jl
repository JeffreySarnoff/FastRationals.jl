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

    #=
    @test_throws OverflowError -FR(typemin(Int32)//1)
    @test_throws OverflowError FR(typemax(Int32)//3) + 1
    @test_throws OverflowError FR(typemax(Int32)//3) * 2
    @test_throws OverflowError FR(1//2)^63
    =#
    #>>>FIXME @test_throws InexactError -FR(typemin(Int32)//1)
    @test_throws InexactError FR(typemax(Int32)//3) + 1
    @test_throws InexactError FR(typemax(Int32)//3) * 2
    @test_throws InexactError FR(1//2)^63
    
    # FIXME!!!
    # @test FR(typemax(Int32)//one(Int32)) * FR(one(Int32)//typemax(Int32)) == 1
    # @test FR(typemax(Int32)//one(Int32)) / FR(typemax(Int32)//one(Int32)) == 1
    # @test FR(one(Int32)//typemax(Int32)) / FR(one(Int32)//typemax(Int32)) == 1

    for a = -5:5, b = -5:5
        if a == b == 0; continue; end
        if ispow2(b)
            @test FR(a//b) == FR(a/b)
            @test convert(FastQ32,a/b) == FR(a//b) 
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
    @test 0.1 == FR(1//10)
    @test 1/3 == FR(1//3)
    @test !(FR(1//3) < 1/3)
    @test -1/3 < FR(1//3)
    @test -1/3 == FR(-1//3)
    @test 1/3 > FR(-1//3)
    @test 1/5 == FR(1//5)

    # PR 29561
    @test abs(one(FastQ32)) === one(FastQ32)
    @test abs(-one(FastQ32)) === one(FastQ32)
end

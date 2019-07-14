@testset "compactify $Q" for Q in (Rational, FastRational)
    mid = Q(100, 111)
    tol = Q(1, 11)
    res = Q(5, 6)
    @test compactify(low=mid - tol, high=mid + tol) == res
    @test compactify(mid, tol) == res
    @test compactify(mid, eps()) == mid
    @test_throws ArgumentError compactify(mid, eps()/3)
    tm = typemax(Int64)>>12
    low = Q(tm, tm-1)
    high = Q(tm+1, tm-1)
    mid = Q(2tm+1, 2tm-2)
    tol = Q(1, 2tm-2)
    @test compactify(mid, tol) == Q(tm>>1+2, tm>>1+1) # rounding error effect?
    @test compactify(low=low, high=high) == Q(tm>>1+1, tm>>1) # better result
    #                                                                          >>>> !!FIXME!! throws MethodError
    # @test_throws ArgumentError compactify(mid, Q(0))
    @test compactify(low=high, high=high) == high
end

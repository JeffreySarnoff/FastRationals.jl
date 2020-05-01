module FastRationals

export FastRational, FastQ32, FastQ64, FastQ128, FastQBig,
       compactify, basetype

using Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow

import Base: BitInteger, BitSigned, hash, show, repr, string, tryparse,
    zero, one, iszero, isone, isinteger, iseven, isodd, isfinite, issubnormal, isinf, isnan,
    numerator, denominator, eltype, convert, promote_rule, decompose,
    isinteger, typemax, typemin, sign, signbit, copysign, flipsign, abs, abs2, float,
    ==, !=, <, <=, >=, >, cmp, isequal, isless,
    +, -, *, /, ^, //,
    inv, div, fld, cld, rem, mod, trunc, floor, ceil, round, widen

const StdInteger = Union{Signed, Unsigned}
const FastInteger = Core.Compiler.typesubtract(Base.BitInteger, Union{Int128,UInt128})

const Reduced   = true
const Unchanged = false

@inline function setsigns(num::T, den::T) where {T<:StdInteger}
    den = -den
    signbit(den) && __throw_rational_argerror_typemin(T)
    num = -num
    return num, den
end  

@inline function reduceterms(num::T, den::T) where {T<:StdInteger}
    g = gcd(num, den)
    num = div(x, g)
    den = div(y, g)
    return num, den
end

struct FastRational{T<:StdInteger} <: Real
    num::T
    den::T
    
    function FastRational{T}(num::T, den::T, reduce::Bool) where {T<:StdInteger}
        if iszero(den)
           iszero(num) && __throw_rational_argerror_zero(T)
           num = copysign(one(T), num)
           reduce = false          
        else
           num, den = setsigns(num, den)
        end             
        if reduce
            num, den = reduceterms(num, den)
        end              
        return new{T}(num,den)
    end
       
    function FastRational{T}(num::T, den::T) where {T<:BigInt}
        if iszero(den)
            iszero(num) && __throw_rational_argerror_zero(T)
            num = copysign(one(T), num)
        end
        if signbit(den) # reduce every other op
            num, den = reduceterms(num, den)
        end
        num, den = -num, -den # if den >= 0 then it is reduced
        return new{T}(num, den)              
    end
    FastRational{T}(num::T, den::T, reduce::Bool) where {T<:BigInt} = FastRational{T}(num, den)
end

numerator(x::FastRational) = x.num
denominator(x::FastRational) = x.den

FastRational{T}(x::FastRational{T}) where {T<:StdInteger} = x
FastRational(x::FastRational{T}) where {T<:StdInteger} = x
FastRational{T1}(x::FastRational{T2}) where {T1<:StdInteger, T2<:StdInteger} = FastRational(T1(x.num), T1(x.den))

FastRational{T}(num::T, den::T) where {T<:StdInteger} = FastRational{T}(num, den, Reduced)
FastRational(num::T, den::T) where {T<:StdInteger} = FastRational{T}(num, den, Reduced)
FastRational{T}(num::StdInteger, den::StdInteger) where {T<:StdInteger} = FastRational{T}(T(num), T(den), Reduced)
FastRational(num::StdInteger, den::StdInteger) = FastRational(promote(num, den)...)


#=




    # this constructor is used when den might be <= 0
    # the constructor of x assures, that
    # x.den > 0 and gcd(x.den, x.num) == 1
    # If due to internal knowledge it is known, that den > 0, the
    # unchecked constructor below may be used for performance.
    function FastRational{T}(num::Integer, den::Integer) where T
        iszero(den) && throw(DivideError())
        num, den = canonical(T(num), T(den))
        signbit(den) && throw(DomainError("denominator is typemin($T)"))
        return new{T}(T(num), T(den))
    end
     
    # this constructor is used when it is known that den > 0   
    # no canonicalization and other checks are performed
    FastRational{T}(num::T, den::T, ::Val{true}) where T =
        new{T}(num, den)
end
function FastRational(num::S, den::T) where {S,T}
    FastRational{promote_type(S,T)}(promote(num, den)...)
end
const Rationals = Union{FastRational,Rational}



# the names `FastQ*` are convencience constructors, not type names.
for (C, T) in ((:FastQ32, Int32), (:FastQ64, Int64), (:FastQ128, Int128), (:FastQBig, BigInt))
    
    @eval begin
        $C(num, den) = FastRational{$T}(num, den)
        $C(num) = FastRational{$T}(num)
        $C(x::Rationals) = FastRational{$T}(x.num, x.den)
        $C(x::Tuple{<:Integer,<:Integer}) = FastRational{$T}(x[1]//x[2])
        $C(x::AbstractFloat; tol::Real=eps(x)) = FastRational{$T}(x, tol=tol)
    end
end

function canonical(num::T, den::T) where {T<:Signed}
    num, den = flipsign(num, den), abs(den)
    gcdval = Base.gcd(num, den)
    gcdval === one(T) && return num, den
    num = div(num, gcdval)
    den = div(den, gcdval)
    return num, den
end

canonical(num::T, den::T) where {T<:Integer} = Base.divgcd(num,den)

include("generic.jl")
include("promote_convert.jl")
include("conform_to_int.jl")
include("compactify.jl")

end # FastRationals

=#

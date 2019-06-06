module FasterRationals

export FastRational

# traits

"""
    RationalTrait

a trait applicable to Rational values
"""
abstract type RationalTrait end

"""
    IsReduced <: RationalTrait

This trait holds for rational values that are known to have been reduced to lowest terms.
"""
struct IsReduced  <: RationalTrait end
const QIsReduced = IsReduced()

"""
    Reduceable <: RationalTrait

This trait holds for rational values that are known not to be expressed in lowest terms.
"""
struct Reduceable <: RationalTrait end
const QReduceable = Reduceable()

"""
    MayReduced <: RationalTrait

This trait holds for rational values that may or may not be expressed in lowest terms.
"""
struct MayReduce  <: RationalTrait end
const QMayReduce = MayReduce()

struct TraitedRational{T, H<:RationalTrait}
    num::T
    den::T
    trait::H
end

eltype(x::TraitedRational{T,H}) = T
trait(x::TraitedRational{T,H}) = t.trait

TraitedRational(x::Rational{T}) where {T} = TraitedRational(x.num, x.den, QIsReduced)


struct FasterRational{T, H<:RationalTrait}
    num::T
    den::T
end

eltype(x::FasterRational{T,H}) = T
trait(x::FasterRational{T,H}) = H

FasterRational(x::Rational{T}) where {T} = FasterRational{T,IsReduced}(x.num, x.den)






struct ReducedRational{T<:Signed}
    num::T
    den::T
end

struct ReducibleRational{T<:Signed}
    num::T
    den::T
end

struct UnreducedRational{T<:Signed}
    num::T
    den::T
end


       ReduceRawRational

import Base: convert, promote_rule, string, show,
    isfinite, isinteger,
    signbit, flipsign, changesign,
    (+), (-), (*), (//), div, rem, fld, mod, cld,
    (==), (<), (<=), isequal, isless

import Base.Checked: add_with_overflow, sub_with_overflow, mul_with_overflow

const SignedInt = Union{Int16, Int32, Int64, Int128, BigInt}


include(joinpath(".", "types", "namedtuple", "fast_rational.jl"))
    
include(joinpath(".", "types","shared.jl"))

include(joinpath("types", "namedtuple", "fast_rational.jl"))
include(joinpath("types", "struct",     "fast_rational.jl"))
include(joinpath("types", "mutable",    "fast_rational.jl"))

include(joinpath("int_ops", "namedtuple", "fast_rational.jl"))
include(joinpath("int_ops", "struct",     "fast_rational.jl"))
include(joinpath("int_ops", "mutable",    "fast_rational.jl"))

include(joinpath("types", "namedtuple", "compares.jl"))
include(joinpath("types", "struct",     "compares.jl"))
include(joinpath("types", "mutable",    "compares.jl"))

end # FasterRationals

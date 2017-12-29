module FasterRationals

export FastRational,
    Q, Q2, QT

import Base: convert, promote_rule, string, show,
    isfinite, isinteger,
    signbit, flipsign, changesign,
    (+), (-), (*), (//), div, rem, fld, mod, cld,
    (==), (<), (<=), isequal, isless

#include(joinpath("types/struct","fast_rational.jl")
#include(joinpath("types/mutablfeast_rational.jl")
#include(joinpath("types/namedtuple/fast_rational.jl")

#include(joinpath("types/namedtuple", "compares.jl"))
#include(joinpath("types/struct", "compares.jl"))
#include(joinpath("types/mutable","compares.jl"))

end # FasterRationals

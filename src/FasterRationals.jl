module FasterRationals

export FastRational,
    Q, Q2, QT

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

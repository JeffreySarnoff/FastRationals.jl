module FasterRationals

export FastRational

import Base: convert, promote_rule, string, show,
    isfinite, isinteger,
    signbit, flipsign, changesign,
    (+), (-), (*), (//), div, rem, fld, mod, cld,
    (==), (<), (<=), isequal, isless

#include("")
#include("")
#include("")
#include("")
#include("")
#include("")

end # FasterRationals

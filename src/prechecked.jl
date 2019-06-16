const FastSigned   = Union{Int8, Int16, Int32, Int64}
const FastUnsigned = Union{UInt8, UInt16, UInt32, UInt64}
const FastInteger  = Union{FastSigned, FastUnsigned}

safemul(x::T, y::T) where {T<:FastInteger} =
    usewidemul(x,y) ? widemul(x,y) : x*y

@inline function usewidemul(x::T, y::T) where {T<:FastSigned}
    iszero( (leading_zeros(abs(x)) + leading_zeros(abs(y))) >> sizeof(T) )
end

@inline function usewidemul(x::T, y::T) where {T<:FastUnsigned}
    iszero( (leading_zeros(x) + leading_zeros(t)) >> sizeof(T) )
end

safemul(x::T, y::T) where {T<:Signed} =

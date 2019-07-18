FastRational{I1}(numden::Tuple{I2,I2}) where {I1<:Integer, I2<:Integer} = FastRational{I1}(numden[1]//numden[2])
Base.float(x::FastRational) = x.num / x.den

Base.Float64(x::FastRational) = float(x)
Base.Float32(x::FastRational) = Float32(float(x))
Base.Float16(x::FastRational) = Float16(float(x))
Base.BigFloat(x::FastRational) = BigFloat(x.num) / BigFloat(x.den)
Base.BigInt(x::FastRational) = isinteger(x) ? BigInt(x.num) ÷ BigInt(x.den) : throw(InexactError())

function FastRational(x::F; tol::Real=eps(x)) where F<:AbstractFloat
    !isfinite(x) && throw(DomainError("finite values only"))
    return FastRational(rationalize(x), tol=tol)
end
function FastRational{T}(x::F; tol::Real=eps(x)) where {T, F<:AbstractFloat}
    !isfinite(x) && throw(DomainError("finite values only"))
    return FastRational{T}(rationalize(T, x, tol=tol))
end

promote_rule(::Type{FastRational{S}}, ::Type{FastRational{T}}) where {T,S} = FastRational{promote_type(S,T)}
promote_rule(::Type{FastRational{S}}, ::Type{T}) where {T<:SUN,S} = FastRational{promote_type(S,T)}
promote_rule(::Type{FastRational{S}}, ::Type{T}) where {T,S} = promote_type(S,T)
promote_rule(::Type{FastRational{S}}, ::Type{Rational{T}}) where {T,S} = FastRational{promote_type(S,T)}


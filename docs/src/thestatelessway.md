# Notes:  The Stateless Way

The initial implementation of `FastRationals` for release uses one kind of type and makes this type available with two field sizes; they correspond to Julia's built-in `Rational{Int32}` and `Rational{Int64}` computational rational number types.

```julia
struct FastRational{T} <: Real
  num::T
  den::T
end
```
`T` is either `Int32` or it is `Int64`.<sup>[𝓪](#Int16)</sup>

Succesful use of ths type for `FastRational` requires finding some manner of effectiveness without the benefit of any reflective modality.  We have no state, flag, parameter or concommitant indication of whether or not the `num` and `den` as given have any common factors.  That is, there is no information about whether a given occurance of this type is already reduced, and so given in canonical form.  The other ways of realizing `FastRationals` each provides informed guidance as to the status, the reductive modality, of the value represented. 
> insert page links to each of the other approaches <



----

<sup><a name="Int16">[𝓪](#annotation)</a></sup> While support for `Int16` would be easy to add, our guidelines suggest its range be  ±1//16..±16//1. We have postponed its inclusion.


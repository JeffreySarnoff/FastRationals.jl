# Notes:  The Stateless Way

The initial implementation of `FastRationals` for release uses one kind of type and makes this type available with two field sizes; they correspond to Julia's built-in `Rational{Int32}` and `Rational{Int64}` computational rational number types.

```julia
struct FastRational{T} <: Real
  num::T
  den::T
end
```
`T` is either `Int32` or it is `Int64`.

Succesful use of ths type for `FastRational` requires finding some manner of effectiveness without the benefit of any reflective modality.  We have no state, flag, parameter or concommitant indication of whether or not the `num` and `den` as given have any common factors.  That is, there is no information about whether a given occurance of this type is already reduced, and so given in canonical form.  The other ways of realizing `FastRationals` each provides informed guidance as to the status, the reductive modality, of the value represented. 
    - insert page links to each of the other approaches <

## making something of use

To allow computational advantage -- to procure performance that is absent from the system rationals -- we elevate a smaller range of magnitudes as preferred. With that, we presuppose and presume that this set of numerators aor denominators is that which pervades the rational values that are used within a computation.  This is not to require that all calculations resolve values that belong to this intially distinguished range.  This does strongly encourage most calculations to so resolve .. or not to stray too far away therefrom.  The entirety of this "stateless way" is given therewith. We may proceed with any calculation in this rational arithmetic by applying compensatory logic advantageously; we harvest the predeliction for, and liklihood of working with smaller rational values.

### when overflow is less likely

Managing the resolution of overflow is an expensive incursion into the overall performance of the computational flow.  To the exent that we may proceed secure in the fact that our next calculation cannot overflow, we have at hand the opportunity to accelerate throughput.  By preferring a more coarse rational map, we lessen encounters with overflow and so augment performant paths.  In general terms, this is the technology that provides the greatly enhanced performance of this `FastRational`.


### quantifying the desireable

  ###     ________  FastQ32  ______________________________  FastQ64  __________
  |  range      | refinement  |                | range           | refinement     |
  |:-----------:|:-----------:|:--------------:|:---------------:|:--------------:|
  |             |             |                |                 |                |
  |    ±215//1  |  ±1//215    |    sweet spot  |     ±55_108//1  |  ±1//55_108    |
  |             |             |                |                 |                |
  |    ±255//1  |  ±1//255    |    preferable  |     ±65_535//1  |  ±1//65_535    |
  |             |             |                |                 |                |
  |  ±1_023//1  |  ±1//1_023  |    workable    |   ±262_143//1   |  ±1//262_143   |
  |             |             |                |                 |                |
  | ±4_095//1   |  ±1//4_095  |    admissible  |  ±1_048_575//1  | ±1//1_048_575  |
  |             |             |                |                 |                |


- The `sweet_spot` mag allows `mag^4 + 5*mag` without overflow.
- The `preferable` mag is `nextpow2(sweet_spot) - 1`.
- The `workable` mag is `prevpow2(mag) - 1` where `mag^3 + 4*mag`, no overflow.
- The `admissible` mag is `4*(workable+1) - 1`






----


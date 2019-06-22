# The Rational Range

----


## the rational milieu

A rational value has two integer-valued components, the numerator and the denominator. Usually, arithmetic with rational values is applied with two values.  Sometimes, as with `muladd`, calculation proceeds with three rational values.  Here are `*`, `+` and `muladd` for rationals.

```
(a/b * c/d) == (a * c) / (b * d)

(a/b + c/d) == ((a * d) + (b * c)) / (b * d)

(a/b * c/d) + s/t == ((a * c * t) + (b * d * s)) / (b * d * t)
```

-----

|      the series formulation         |
|:-----------------------------------:|
| ![e_series](assets/e_series.PNG)    |

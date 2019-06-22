# The Rational Range

----


## the rational milieu

A rational value has two integer-valued components, the numerator and the denominator. Usually, rational arithmetic is applied to two values at a time.  `muladd` is applied to three rational values.  Here are `*`, `+` and `muladd` for rationals.

```
(a/b * c/d) == (a * c) / (b * d)

(a/b + c/d) == ((a * d) + (b * c)) / (b * d)

(a/b * c/d) + s/t == ((a * c * t) + (b * d * s)) / (b * d * t)
```

-----

|      the series formulation         |
|:-----------------------------------:|
| ![e_series](assets/e_series.PNG)    |

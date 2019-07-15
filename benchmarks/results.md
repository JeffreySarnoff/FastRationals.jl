(Intel Xeon, 6 cores, 1 thread; Julia v1.2.0-rc2) 2019-07-15


```
FastRational{BigInt} speedup relative to Rational{BigInt} 

        relative speeds                   relative speeds
         (200)   (500)                    (8x8)   (15x15)

sum:     105.5   210.8           matmul:  18.2     22.7   
prod:    191.2   376.4           mat tr:  10.9     16.8


FastRational{T} speedups relative to Rational{T}
   
         Int32   Int64  Int128   == {T}

mul:     23.1    20.3    2.3
muladd:  21.9    18.1    1.8
add:     18.7    15.6    1.6
poly:    8.2     21.8    2.3

matmul:  11.5    13.8    1.9
matlu:   4.2     5.2     1.8
matinv:  3.5     2.7     1.1

```



``` 
older results, the revisions benchmarked above
speedup FastQ4 and slowdown sum, prod
on a relative usability basis the revisions are accepted


|         | FastQ32 | FastQ64 |
|:--------|:-------:|:-------:|
|mul      | 24.0    | 15.2    |
|add,mul  | 21.7    | 15.3    |
|add      | 18.7    | 13.2    |
|polyval  | 7.9     | 20.8    |
|mat mul  | 11.7    | 14.0    |
|mat lu   | 3.7     | 5.4     |
|mat inv  | 3.3     | 2.8     |
=#


|               |                  |
|---------------|------------------|
| contributor   | Jeffrey Sarnoff  |
| platform      | Intel Xeon CPU, 6 Core(s) |
| threads       | 1                |
| os            | Windows 10       |
| Julia         | v1.1.1           |
| FastRationals | prerelease       |
```
        relative speeds
         (32)    (64)

mul:     24.0    15.2
muladd:  21.7    15.3
add:     18.7    13.2
poly:    7.9     20.8
matmul:  11.7    14.0
matlu:   3.7     5.4
matinv:  3.3     2.8
```

|     calculation        |  Relative Speedup |
|:-----------------------|:-----------------:|
|      mul/div           |       20          |
|      polyval           |       18          |
|      add/sub           |       15          |
|                        |                   |
|      mat mul           |       10          |
|      mat lu            |        5          |
|      mat inv           |        3          |

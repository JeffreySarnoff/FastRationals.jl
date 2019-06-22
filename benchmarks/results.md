from: Jeffrey Sarnoff
platform: Intel Xeon CPU, 6 Core(s)
os: Windows 10
Julia: v1.1.1
FastRationals: prerelease 

|  _small rationals_      |  Relative Speedup |
|:------------------------|:-----------------:|
|      mul/div            |       20          |
|      polyval            |       18          |
|      add/sub            |       15          |
|      4x4 matrix         |                   |
|      mul                |       10          |
|      lu                 |        5          |
|      inv                |        3          |

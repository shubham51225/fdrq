* Example 1
version 16.0
sysuse auto, clear

fdrq: regress (price mpg headroom) foreign weight length, coefficients(foreign weight)
frame fdrq_results: list

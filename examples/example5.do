* Example 5
version 16.0
sysuse auto, clear

* Adjust the two foreign-car coefficients together.
fdrq: regress (price mpg) foreign weight if rep78 < ., vce(robust) ///
    coefficients(foreign) frame(car_results)
frame car_results: list

* Fit different specifications and adjust each test in its own family.
fdrq: regress (price) foreign weight length, vce(robust) ///
    coefficients(foreign) frame(price_results)
fdrq: regress (mpg) foreign weight turn, vce(robust) ///
    coefficients(foreign) frame(mpg_results)

* Copy selected variables to a separate frame.
fdrq: regress (price mpg) foreign weight if rep78 < ., vce(robust) ///
    coefficients(foreign) frame(car_tests) keep(make price mpg foreign rep78) ///
    dataframe(car_data)
frame car_data: list in 1/5

* Fit an IV model for each outcome.
fdrq: ivregress 2sls (price mpg) foreign (weight = length), ///
    coefficients(foreign) frame(car_iv)

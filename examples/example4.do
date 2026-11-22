* Example 4
version 16.0

capture which ftools
if _rc ssc install ftools

capture which reghdfe
if _rc ssc install reghdfe

sysuse nlsw88, clear

* Adjust the two union tests together.
fdrq: reghdfe (wage hours) union grade ttl_exp, ///
    absorb(industry occupation) vce(robust) ///
    coefficients(union) frame(wage_hours_fe)

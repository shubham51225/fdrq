* Example 2
version 16.0
sysuse nlsw88, clear

generate byte manufacturing = (industry == 4) if !missing(industry)
generate byte professional = (occupation == 1) if !missing(occupation)

* Adjust the six tests of the average marginal effects together.
fdrq: logit (union manufacturing professional) grade i.married age ttl_exp, ///
    vce(robust) margins(dydx(grade married)) ///
    coefficients(grade 1.married) q(qval_sharpened) frame(marginal_effects)
frame marginal_effects: list outcome coefficient b pval qval_sharpened, noobs

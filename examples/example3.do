* Example 3
version 16.0
sysuse nlsw88, clear

* Use the same sample for both outcomes. Adjust the two union tests together.
fdrq: regress (wage hours) union grade ttl_exp ///
    if !missing(wage, hours, union, grade, ttl_exp), vce(robust) ///
    coefficients(union) frame(wage_hours) store(fdrq_ols) table tableopts(stats(N r2)) ///
    keep(wage hours union grade ttl_exp) dataframe(wage_data)

frame wage_hours: list outcome coefficient pval qval qval_sharpened, noobs
frame wage_data: list in 1/5

* Export the table to LaTeX.
esttab fdrq_ols1 fdrq_ols2 using "fdrq_nlsw88.tex", replace tex ///
    keep(union) mtitles("Hourly wage" "Weekly hours") nostar ///
    cells("b(fmt(3)) se(par fmt(3)) p(fmt(3)) qval(fmt(3)) qval_sharpened(fmt(3))") ///
    addnotes("Each model reports the coefficient, standard error, p-value, BH q-value and sharpened BKY q-value.")

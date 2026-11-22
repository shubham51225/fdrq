# fdrq — False discovery rate q-values for Stata

`fdrq` runs the same model for a list of outcomes in Stata 16 or later.
It adjusts the p-values for the coefficients or marginal effects you
select as one family of tests. It reports ordinary Benjamini–Hochberg
(BH) and sharpened Benjamini–Krieger–Yekutieli (BKY) q-values and saves
the results in a separate Stata frame. It restores the active data and
previously active estimates when it finishes.

## Installation

Install from GitHub in Stata.

```stata
net install fdrq, from("https://raw.githubusercontent.com/shubham51225/fdrq/main/") replace
```

## Syntax

```text
fdrq: estimator (outcomes) [regressors] [if] [in] [weight], coefficients(list) [estimator_options] [fdrq_options]
```

Keep the parentheses around the outcome list, even for a single outcome.
Use one invocation per hypothesis family. Type `help fdrq` for the full
documentation and clickable examples.

| Option | Description |
|---|---|
| `coefficients(list)` | Required. Selects the terms to test across all outcomes. Use their names in `e(b)`. |
| `q(method)` | Use `qval` for BH, `qval_sharpened` for sharpened BKY or `both` for both adjustments (the default). |
| `margins(options)` | Runs `margins` after each fit and adjusts the p-values for the selected terms in its posted results. |
| `frame(name)` | Names the results frame. The default is `fdrq_results`. |
| `keep(varlist)` | Copies selected variables and all their observations to a separate frame. |
| `dataframe(name)` | Names the frame created by `keep()`. The default is the results frame name with `_data` appended. |
| `replace` | Replaces existing output frames. |
| `store(prefix)` | Saves the estimates as `prefix1`, `prefix2` and so on, in outcome order. |
| `estadd` | Attaches the requested q-values to stored estimates. Requires `store()`. |
| `table` | Includes `estadd` and displays an `esttab` table. Requires `store()`. |
| `tableopts(options)` | Passes additional options to `esttab`. Requires `table`. |
| *estimator_options* | Options accepted by the estimator, such as `vce(robust)` or `vce(cluster id)`. |

## Examples

### 1. Linear regression across outcomes

Fit three regressions and adjust the six tests of `foreign` and `weight`
together.

```stata
sysuse auto, clear
fdrq: regress (price mpg headroom) foreign weight length, ///
    coefficients(foreign weight) vce(robust)
frame fdrq_results: list
```

### 2. Average marginal effects after logit

Compute sharpened q-values for the average marginal effects of schooling
and marriage on the predicted probability of union membership.

```stata
sysuse nlsw88, clear
fdrq: logit (union) grade i.married age ttl_exp, vce(robust) ///
    margins(dydx(grade married)) coefficients(grade 1.married) ///
    q(qval_sharpened) frame(marginal_effects)
```

### 3. Display and export a regression table

Store the fits as `m_1` and `m_2`, attach both sets of q-values and display
the table with sample sizes and R-squared. `fdrq` installs `estout` from
SSC if needed.

```stata
sysuse auto, clear
fdrq: regress (price mpg) foreign weight, coefficients(foreign) ///
    frame(table_results) store(m_) table tableopts(stats(N r2))
```

Export the stored results to LaTeX.

```stata
esttab m_1 m_2 using "fdrq_results.tex", replace tex keep(foreign) ///
    cells("b(fmt(3)) se(par fmt(3)) p(fmt(3)) qval(fmt(3)) qval_sharpened(fmt(3))")
```

For example do-files, see the [examples directory](examples/).

## References and acknowledgements

- Benjamini, Y. and Y. Hochberg (1995). “Controlling the False Discovery Rate: A Practical and Powerful Approach to Multiple Testing.” *Journal of the Royal Statistical Society: Series B (Methodological)*, 57(1), 289–300. [DOI](https://doi.org/10.1111/j.2517-6161.1995.tb02031.x)
- Benjamini, Y., A. M. Krieger and D. Yekutieli (2006). “Adaptive linear step-up procedures that control the false discovery rate.” *Biometrika*, 93(3), 491–507. [DOI](https://doi.org/10.1093/biomet/93.3.491)
- Anderson, M. L. (2008). “Multiple Inference and Gender Differences in the Effects of Early Intervention: A Reevaluation of the Abecedarian, Perry Preschool, and Early Training Projects.” *Journal of the American Statistical Association*, 103(484), 1481–1495. [Paper](https://doi.org/10.1198/016214508000000841) · [Stata code](https://anderson.are.berkeley.edu/Research.html)
- Jann, B. (2005). “Making regression tables from stored estimates.” *The Stata Journal*, 5(3), 288–308. [DOI](https://doi.org/10.1177/1536867X0500500302)

`fdrq` wraps Michael L. Anderson's Stata code for the q-value calculations.
Table output uses `estadd` and `esttab` from Ben Jann's [estout package](https://github.com/benjann/estout).

## Author

**Shubham Singh**

For bug reports or feature requests, open an issue in the GitHub repository.

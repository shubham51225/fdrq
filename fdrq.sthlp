{smcl}
{* *! version 0.6.0  22nov2026}{...}
{vieweralsosee "[R] regress" "help regress"}{...}
{vieweralsosee "[R] test" "help test"}{...}
{vieweralsosee "[R] margins" "help margins"}{...}
{vieweralsosee "[R] estimates" "help estimates"}{...}
{vieweralsosee "[D] frames" "help frames"}{...}
{vieweralsosee "estout" "help estout"}{...}
{viewerjumpto "Syntax" "fdrq##syntax"}{...}
{viewerjumpto "Description" "fdrq##description"}{...}
{viewerjumpto "Options" "fdrq##options"}{...}
{viewerjumpto "Examples" "fdrq##examples"}{...}
{viewerjumpto "Stored results" "fdrq##results"}{...}
{viewerjumpto "References" "fdrq##references"}{...}
{viewerjumpto "Author" "fdrq##author"}{...}

{p2colset 1 13 15 2}{...}
{p2col:{bf:fdrq} {hline 2}}False discovery rate q-values for multiple outcomes{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:fdrq:} {it:estimator} {cmd:(}{it:outcome_varlist}{cmd:)}
[{it:regressors}] {ifin} {weight}{cmd:,}
{opt coef:ficients(list)} [{it:estimator_options} {it:fdrq_options}]{p_end}

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Tests and adjustment}
{synopt:{opt coef:ficients(list)}}terms to test, required{p_end}
{synopt:{opt q(method)}}choose the FDR adjustment{p_end}
{synopt:{opt margins(options)}}test estimates posted by {cmd:margins}{p_end}

{syntab:Results frames}
{synopt:{opt frame(name)}}name the results frame{p_end}
{synopt:{opt keep(varlist)}}copy selected source variables{p_end}
{synopt:{opt dataframe(name)}}name the copied data frame{p_end}
{synopt:{opt replace}}replace existing output frames{p_end}

{syntab:Stored estimates and tables}
{synopt:{opt store(prefix)}}store estimates in outcome order{p_end}
{synopt:{opt estadd}}attach q-values to estimates{p_end}
{synopt:{opt table}}display table with q-values{p_end}
{synopt:{opt tableopts(options)}}pass options to {cmd:esttab}{p_end}

{syntab:Estimator}
{synopt:{it:estimator_options}}pass options to the estimator{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
Requires Stata 16 or later.{p_end}
{p 4 6 2}
The estimator determines which weights, factor variables and time-series
operators are allowed for regressors. Put {cmd:if}, {cmd:in} and weights
after the model variables.{p_end}
{p 4 6 2}
For separate groups, run {cmd:fdrq} with an {cmd:if} restriction for
each group.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:fdrq} fits one model per outcome using a common specification. It
collects the p-values for the terms in {opt coefficients()} and
adjusts those tests as one family. For example, two coefficients across
four outcomes give eight tests. Run {cmd:fdrq} separately for each
family you want to adjust on its own. A family can include up to
32,740 tests. If a family needs different regressors for different
outcomes, fit those models separately and adjust their p-values
together.{p_end}

{pstd}
Put the numeric outcomes in parentheses where the dependent variable
normally goes, even for one outcome. Estimation samples may differ
across outcomes because each model uses the estimator's sample rules
and any {cmd:if} or {cmd:in} restrictions. The estimator must post
{cmd:e(b)}, {cmd:e(V)} and {cmd:e(N)} and support {helpb test}.{p_end}

{pstd}
The false discovery rate (FDR) is the expected proportion of false
rejections among all rejections, with the proportion set to zero if
there are no rejections. Both procedures use valid p-values. Ordinary
Benjamini-Hochberg (BH) controls the FDR under independence and under
certain forms of positive dependence. The two-stage
Benjamini-Krieger-Yekutieli (BKY) guarantee applies under independence.
See the {help fdrq##references:references}.{p_end}

{pstd}
{cmd:fdrq} reads each p-value at full precision from {cmd:r(p)} after
{helpb test}. The adjustment evaluates FDR levels in steps of 0.001.
Each q-value is the lowest level on that grid at which the test is
rejected. The initial q-value of 1 is retained if the test is never
rejected on the grid.{p_end}

{pstd}
By default, {cmd:fdrq} reports both q-values and displays a summary.
It restores the original data and previously active estimates when it
finishes. The {opt estadd} and {opt table} options use Ben Jann's
{cmd:estout} package, which {cmd:fdrq} installs from SSC if needed.{p_end}

{dlgtab:Results frame}

{pstd}
The results frame has one row per test. Rows follow the outcome list
and then the order in {opt coefficients()}.{p_end}

{synoptset 23 tabbed}{...}
{synopt:{cmd:outcome}, {cmd:coefficient}}outcome and term tested{p_end}
{synopt:{cmd:b}, {cmd:se}}estimate and standard error{p_end}
{synopt:{cmd:statistic}}estimate divided by its standard error{p_end}
{synopt:{cmd:N}, {cmd:df_r}}sample size and residual degrees of freedom, when available{p_end}
{synopt:{cmd:pval}}unadjusted p-value from {cmd:test}{p_end}
{synopt:{cmd:qval}}ordinary BH q-value{p_end}
{synopt:{cmd:qval_sharpened}}sharpened BKY q-value{p_end}
{synopt:{cmd:modelid}, {cmd:hypothesisid}}model and test indices{p_end}
{synopt:{cmd:coefficient_column}}position in {cmd:e(b)}{p_end}
{synopt:{cmd:estimate}}stored estimate name, if requested{p_end}
{synopt:{cmd:command}}fitted estimation command{p_end}
{p2colreset}{...}

{pstd}
When one adjustment is requested, the other q-value column contains
missing values. With {opt margins()}, estimates and standard errors
come from the posted margins results. The frame characteristics
{cmd:_dta[fdrq_command]}, {cmd:_dta[fdrq_q]} and {cmd:_dta[fdrq_family]}
record the full command, adjustment and definition of the family.{p_end}

{marker options}{...}
{title:Options}

{dlgtab:Tests and adjustment}

{phang}
{opt coef:ficients(list)} is required. List the terms to test against
zero using their names in {cmd:e(b)}, such as {cmd:union} or
{cmd:1.married}. Use {it:equation}{cmd::}{it:name} to identify a term
that appears in more than one equation. Each term must be estimable
for every outcome. List each term once.{p_end}

{phang}
{opt q(method)} selects the adjustment. The default is {cmd:q(both)}.{p_end}
{pmore}{cmd:qval} reports the ordinary BH q-value.{p_end}
{pmore}{cmd:qval_sharpened} reports the sharpened BKY q-value.{p_end}
{pmore}{cmd:both} reports both q-values.{p_end}
{pmore}{cmd:bh} is an alias for {cmd:qval}. {cmd:bky} and {cmd:sharpened}
are aliases for {cmd:qval_sharpened}.{p_end}

{phang}
{opt margins(options)} runs {helpb margins} after fitting each model.
Supply the options that follow the comma in {cmd:margins}, such as
{cmd:margins(dydx(grade married))}. {cmd:fdrq} adds {cmd:post} and tests
the terms selected by {cmd:coefficients()} in the posted results.
By default, {cmd:fdrq} tests the fitted model coefficients.{p_end}

{dlgtab:Results frames}

{phang}
{opt frame(name)} names the results frame. The default is
{cmd:fdrq_results}. Use {cmd:frame} {it:name}{cmd:: list} to inspect
it from the current frame.{p_end}

{phang}
{opt keep(varlist)} copies selected variables to a separate frame.
The copy includes all observations in their original order. By
default, {cmd:fdrq} creates only the results frame.{p_end}

{phang}
{opt dataframe(name)} names the frame created by {cmd:keep()}.
The default is the results frame name with {cmd:_data} appended.
Requires {cmd:keep()}.{p_end}

{phang}
{opt replace} allows {cmd:fdrq} to overwrite existing output frames.
By default, existing frames are preserved. Choose output frame names
distinct from each other and from the current frame.{p_end}

{dlgtab:Stored estimates and tables}

{phang}
{opt store(prefix)} saves the estimates as {it:prefix}{cmd:1},
{it:prefix}{cmd:2} and so on, in outcome order. Choose a prefix that
gives unused names. With {cmd:margins()}, it saves the posted margins
results. By default, the fits are temporary. Refit the model for
postestimation that needs the original estimation sample.{p_end}

{phang}
{opt estadd} attaches {cmd:e(qval)} and {cmd:e(qval_sharpened)} for the
requested adjustments. The matrices follow the columns of {cmd:e(b)}.
Entries for untested terms are missing. Requires {cmd:store()}.
With {cmd:store()} alone the model's usual results are saved.{p_end}

{phang}
{opt table} includes {cmd:estadd} and displays an {cmd:esttab} table for
the terms in {cmd:coefficients()}. Requires {cmd:store()}. When you
request {cmd:estadd} or {cmd:table}, {cmd:fdrq} installs Ben Jann's
{cmd:estout} package if needed. The default display is the results
summary.{p_end}

{phang}
{opt tableopts(options)} passes additional options to {cmd:esttab}.
Requires {cmd:table}. The default table gives estimates, standard
errors, unadjusted p-values and the requested q-values. For example,
{cmd:tableopts(stats(N r2))} adds sample size and R-squared. For your
own {cmd:keep()} or {cmd:cells()} settings, use {cmd:store()} and
{cmd:estadd}, then run {cmd:esttab} separately.{p_end}

{dlgtab:Estimator}

{phang}
{it:estimator_options} are passed to each model. Use options supported
by your estimator, such as {cmd:vce(cluster id)} or {cmd:absorb()}.
If omitted, each model uses the estimator's defaults.{p_end}

{marker examples}{...}
{title:Examples}

{pstd}In the Viewer, click the commands in order within each example.{p_end}

{dlgtab:Example 1}

{pstd}Load the automobile data.{p_end}
{phang2}{cmd:. }{stata "sysuse auto, clear"}{p_end}

{pstd}Fit three regressions and adjust the six tests of {cmd:foreign} and {cmd:weight} together.{p_end}
{phang2}{cmd:. }{stata "fdrq: regress (price mpg headroom) foreign weight length, coefficients(foreign weight)"}{p_end}

{pstd}List the results in the default frame.{p_end}
{phang2}{cmd:. }{stata "frame fdrq_results: list"}{p_end}

{dlgtab:Example 2}

{pstd}Load the data and create indicators for manufacturing and professional occupations.{p_end}
{phang2}{cmd:. }{stata "sysuse nlsw88, clear"}{p_end}
{phang2}{cmd:. }{stata "generate byte manufacturing = (industry == 4) if !missing(industry)"}{p_end}
{phang2}{cmd:. }{stata "generate byte professional = (occupation == 1) if !missing(occupation)"}{p_end}

{pstd}Fit three logit models with robust standard errors. Adjust the six tests of average marginal effects for schooling and marriage using the sharpened q-value.{p_end}
{phang2}{cmd:. }{stata "fdrq: logit (union manufacturing professional) grade i.married age ttl_exp, vce(robust) margins(dydx(grade married)) coefficients(grade 1.married) q(qval_sharpened) frame(marginal_effects)"}{p_end}

{pstd}List the estimates, p-values and sharpened q-values.{p_end}
{phang2}{cmd:. }{stata "frame marginal_effects: list outcome coefficient b pval qval_sharpened, noobs"}{p_end}

{dlgtab:Example 3}

{pstd}Load the wage and hours data.{p_end}
{phang2}{cmd:. }{stata "sysuse nlsw88, clear"}{p_end}

{pstd}Fit both models on the same sample. Store the estimates, display a table with sample size and R-squared and copy the model variables to a separate frame.{p_end}
{phang2}{cmd:. }{stata "fdrq: regress (wage hours) union grade ttl_exp if !missing(wage, hours, union, grade, ttl_exp), vce(robust) coefficients(union) frame(wage_hours) store(fdrq_ols) table tableopts(stats(N r2)) keep(wage hours union grade ttl_exp) dataframe(wage_data)"}{p_end}

{pstd}List the test results and the first five rows of the copied data.{p_end}
{phang2}{cmd:. }{stata "frame wage_hours: list outcome coefficient pval qval qval_sharpened, noobs"}{p_end}
{phang2}{cmd:. }{stata "frame wage_data: list in 1/5"}{p_end}

{dlgtab:Example 4}

{pstd}Load the wage and hours data.{p_end}
{phang2}{cmd:. }{stata "sysuse nlsw88, clear"}{p_end}

{pstd}Fit both models with industry and occupation fixed effects. Adjust the two union-coefficient tests together.{p_end}
{phang2}{cmd:. }{stata "fdrq: reghdfe (wage hours) union grade ttl_exp, absorb(industry occupation) vce(robust) coefficients(union) frame(wage_hours_fe)"}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:fdrq} returns scalars and macros in {cmd:r()}. With {cmd:estadd}
or {cmd:table}, it also adds matrices to {cmd:e()} in each estimate
saved by {opt store()}.{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N_tests)}}number of tests{p_end}
{synopt:{cmd:r(N_models)}}number of fitted models{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(frame)}}name of the results frame{p_end}
{synopt:{cmd:r(dataframe)}}name of the source-variable frame, if requested{p_end}
{synopt:{cmd:r(kept)}}names of the source variables copied{p_end}
{synopt:{cmd:r(q)}}{cmd:qval}, {cmd:qval_sharpened} or {cmd:both}{p_end}
{synopt:{cmd:r(outcomes)}}outcomes in model order{p_end}
{synopt:{cmd:r(coefficients)}}terms tested{p_end}
{synopt:{cmd:r(models)}}stored estimate names, if requested{p_end}
{synopt:{cmd:r(cmdline)}}full command line{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(qval)}}ordinary BH q-values, if attached{p_end}
{synopt:{cmd:e(qval_sharpened)}}sharpened BKY q-values, if attached{p_end}
{p2colreset}{...}

{marker references}{...}
{title:References}

{phang}
Benjamini, Y. and Y. Hochberg. 1995. Controlling the false discovery rate:
A practical and powerful approach to multiple testing.
{it:Journal of the Royal Statistical Society: Series B (Methodological)}
57(1), 289-300. {browse "https://doi.org/10.1111/j.2517-6161.1995.tb02031.x":DOI}.{p_end}

{phang}
Benjamini, Y., A. M. Krieger and D. Yekutieli. 2006. Adaptive linear step-up
procedures that control the false discovery rate.
{it:Biometrika} 93(3), 491-507.
{browse "https://doi.org/10.1093/biomet/93.3.491":DOI}.{p_end}

{phang}
Anderson, M. L. 2008. Multiple inference and gender differences in the
effects of early intervention: A reevaluation of the Abecedarian, Perry
Preschool, and Early Training Projects.
{it:Journal of the American Statistical Association} 103(484), 1481-1495.
({browse "https://doi.org/10.1198/016214508000000841":DOI},
{browse "https://anderson.are.berkeley.edu/pdf/Anderson%202008a.pdf":Paper}).{p_end}

{phang}
Benjamini, Y. and D. Yekutieli. 2001. The control of the false discovery
rate in multiple testing under dependency.
{it:The Annals of Statistics} 29(4), 1165-1188.
{browse "https://doi.org/10.1214/aos/1013699998":DOI}.{p_end}

{phang}
Jann, B. 2005. Making regression tables from stored estimates.
{it:The Stata Journal} 5(3), 288-308.
{browse "https://doi.org/10.1177/1536867X0500500302":DOI}.{p_end}

{pstd}
The q-value calculations use Stata code provided by Michael L. Anderson.
See his {browse "https://anderson.are.berkeley.edu/Research.html":research page}.
Table output uses {cmd:estadd} and {cmd:esttab} from Ben Jann's
{browse "https://github.com/benjann/estout":estout package}.{p_end}

{marker author}{...}
{title:Author}

{pstd}Shubham Singh{p_end}

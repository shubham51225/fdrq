*! fdrq 18nov2026 shubham singh

program define fdrq, rclass
    version 16.0
    local invocation `"fdrq `0'"'
    local usage "syntax: fdrq: estimator (outcomes) regressors, coefficients(...)"
    capture noisily _on_colon_parse `0'
    local rc = _rc
    if `rc' {
        display as error "`usage'"
        exit `rc'
    }
    local before `"`s(before)'"'
    local command `"`s(after)'"'
    if strtrim(`"`before'"')!="" | strtrim(`"`command'"')=="" {
        display as error "`usage'"
        exit 198
    }
    capture noisily {
        _parse comma specification 0 : command
        syntax, COEFficients(string) ///
            [Q(string) FRAME(name) MARGINS(string asis) ///
             KEEP(string) DATAFRAME(name) STORE(name) ESTADD TABLE ///
             TABLEOPTS(string asis) REPLACE *]
    }
    local rc = _rc
    if `rc' {
        display as error "fdrq: check the options after the comma. See help fdrq."
        exit `rc'
    }
    local modeloptions `"`options'"'

    * The first parenthesised group gives the outcome variables.
    local opening=strpos(`"`specification'"',"(")
    if `opening'<=1 {
        display as error "Outcomes: put the outcome list in parentheses after the estimator."
        exit 198
    }
    local lead=strtrim(substr(`"`specification'"',1,`opening'-1))
    local tail=substr(`"`specification'"',`opening',.)
    capture gettoken outcome_spec suffix : tail, match(group)
    if _rc | "`group'"!="(" | strtrim(`"`outcome_spec'"')=="" {
        display as error "Outcomes: put at least one outcome inside matching parentheses."
        exit 198
    }
    foreach token of local lead {
        if inlist("`token'","by","bys","byso","bysor","bysort") {
            display as error "by prefix: run fdrq separately with an if restriction for each group."
            exit 198
        }
        if inlist("`token'","if","in") {
            display as error "Outcomes: put the outcome list before if or in."
            exit 198
        }
    }
    capture noisily {
        unab outcome : `outcome_spec'
        confirm numeric variable `outcome'
    }
    local rc = _rc
    if `rc' {
        display as error "Outcomes: specify numeric variables from the current data."
        exit `rc'
    }
    if `"`keep'"'!="" {
        capture noisily unab keep_vars : `keep'
        local rc = _rc
        if `rc' {
            display as error "keep(): specify variables from the current data."
            exit `rc'
        }
        local keep `keep_vars'
    }

    if "`frame'"=="" local frame fdrq_results
    if "`frame'"=="`c(frame)'" {
        display as error "frame(): choose a name other than the current frame (`c(frame)')."
        exit 198
    }
    capture frame `frame': count
    local exists=(_rc==0)
    if `exists' & "`replace'"=="" {
        display as error "frame(): `frame' already exists. Use a different name or specify replace."
        exit 110
    }
    local q=lower(strtrim("`q'"))
    if "`q'"=="" local q both
    if "`q'"=="bh" local q qval
    if inlist("`q'","bky","sharpened") local q qval_sharpened
    if !inlist("`q'","qval","qval_sharpened","both") {
        display as error "q(): specify qval, qval_sharpened or both."
        exit 198
    }
    local T : word count `coefficients'
    local unique : list uniq coefficients
    local U : word count `unique'
    local M : word count `outcome'
    local unique_outcomes : list uniq outcome
    local U_outcomes : word count `unique_outcomes'
    if `U_outcomes'!=`M' {
        display as error "Outcomes: list each outcome only once."
        exit 198
    }
    local H=`M'*`T'
    if !`T' {
        display as error "coefficients(): specify at least one coefficient."
        exit 198
    }
    if `T'!=`U' {
        display as error "coefficients(): list each coefficient only once."
        exit 198
    }
    if `H'>32740 {
        display as error "Hypothesis family: `H' tests requested. The maximum is 32,740."
        exit 198
    }
    if "`keep'"=="" & "`dataframe'"!="" {
        display as error "dataframe(): specify the variables to copy in keep()."
        exit 198
    }
    if "`keep'"!="" {
        if "`dataframe'"=="" local dataframe `frame'_data
        capture confirm name `dataframe'
        local rc = _rc
        if `rc' {
            display as error "dataframe(): `dataframe' is an invalid frame name. Specify a valid name."
            exit `rc'
        }
        if inlist("`dataframe'","`frame'","`c(frame)'") {
            display as error "dataframe(): choose a name different from the current and results frames."
            exit 198
        }
        capture frame `dataframe': count
        if !_rc & "`replace'"=="" {
            display as error "dataframe(): `dataframe' already exists. Use a different name or specify replace."
            exit 110
        }
    }
    local table_option "`estadd'"
    if "`table'"!="" {
        local estadd estadd
        local table_option table
    }
    if "`estadd'"!="" & "`store'"=="" {
        display as error "`table_option': specify store(prefix) to save the models."
        exit 198
    }
    if `"`tableopts'"'!="" & "`table'"=="" {
        display as error "tableopts(): specify table to pass options to esttab."
        exit 198
    }
    local models ""
    if "`store'"!="" {
        quietly estimates dir
        local existing `r(names)'
        forvalues j=1/`M' {
            local name `store'`j'
            capture confirm name `name'
            local rc = _rc
            if `rc' {
                display as error "store(): `name' is an invalid estimate name. Try a shorter prefix."
                exit `rc'
            }
            local found : list name in existing
            if `found' {
                display as error "store(): estimate `name' already exists. Choose a different prefix."
                exit 110
            }
            local models `models' `name'
        }
    }
    if "`estadd'"!="" {
        capture noisily {
            capture which estout
            if _rc ssc install estout, replace
            quietly which estadd
            if "`table'"!="" quietly which esttab
        }
        local rc = _rc
        if `rc' {
            display as error "`table_option': estout is required. Check the installation with ssc install estout, replace."
            exit `rc'
        }
    }

    * Hold e() before preserve so its e(sample) holder is included in the snapshot.
    tempname held results datastage
    capture noisily {
        _estimates hold `held', restore nullok
        preserve
    }
    local rc = _rc
    if `rc' {
        display as error "fdrq: could not save the current data or estimates before fitting the models."
        exit `rc'
    }
    local fitoptions ""
    foreach field in suffix modeloptions margins store tableopts {
        local content `"``field''"'
        if `"`content'"'!="" local fitoptions `"`fitoptions' `field'(`"`content'"')"'
    }
    if "`keep'"!="" local fitoptions `"`fitoptions' keep(`keep')"'
    capture noisily fdrq__fit, lead(`"`lead'"') outcomes(`outcome') ///
        coefficients(`coefficients') result(`results') datastage(`datastage') q(`q') ///
        invocation(`"`invocation'"') `fitoptions' `estadd' `table'
    local rc=_rc
    capture noisily restore
    local restore_rc = _rc
    if `restore_rc' {
        display as error "fdrq: could not restore the original data after fitting the models."
        if !`rc' local rc = `restore_rc'
    }
    if `rc' {
        foreach name of local models {
            capture estimates drop `name'
        }
        exit `rc'
    }
    * Publishing both frames is one rollback-protected operation.
    local publishopts ""
    if "`keep'"!="" local publishopts "datastage(`datastage') dataframe(`dataframe')"
    capture noisily fdrq__publish, result(`results') frame(`frame') `publishopts'
    local rc=_rc
    if `rc' {
        foreach name of local models {
            capture estimates drop `name'
        }
        exit `rc'
    }
    display as text "Results frame: " as result "`frame'" ///
        as text " (" as result `H' as text " hypotheses in one family)."
    return scalar N_tests=`H'
    return scalar N_models=`M'
    return local frame "`frame'"
    return local dataframe "`dataframe'"
    return local kept "`keep'"
    return local q "`q'"
    return local outcomes "`outcome'"
    return local coefficients "`coefficients'"
    return local models "`models'"
    return local cmdline `"`invocation'"'
end

program define fdrq__fit
    version 16.0
    syntax, LEAD(string) OUTCOMES(varlist numeric) COEFficients(string) ///
        RESULT(name) DATASTAGE(name) Q(string) INVOCATION(string) ///
        [SUFFIX(string) MODELOPTIONS(string) MARGINS(string) KEEP(varlist) ///
         STORE(string) TABLEOPTS(string) ESTADD TABLE]
    local step "creating the results frame"
    local failed_command ""
    capture noisily {
        frame create `result' long(modelid hypothesisid coefficient_column) ///
            str32(outcome estimate) str128(coefficient) strL(command) ///
            double(b se statistic df_r N pval)
        if "`keep'"!="" {
            local step "keep() while copying variables"
            frame put `keep', into(`datastage')
            frame `datastage': char _dta[fdrq_role] "Unfiltered pre-estimation source variables; original observation order"
            frame `datastage': char _dta[fdrq_command] `"`invocation'"'
        }
        tempname B V beta se stat df n p
        local estimate_source model
        if `"`margins'"'!="" local estimate_source "margins results"
        local j=0
        local row=0
        foreach y of local outcomes {
            local ++j
            local fitted `"`lead' `y' `suffix'"'
            if strtrim(`"`modeloptions'"')!="" local fitted `"`fitted', `modeloptions'"'
            display as text "Outcome `j': " as result "`y'"
            ereturn clear
            local step "estimation for outcome `y'"
            local failed_command `"`fitted'"'
            quietly `fitted'
            local fitted_outcome `"`e(depvar)'"'
            if `"`fitted_outcome'"'!="" & `"`fitted_outcome'"'!="`y'" {
                local outcome_before_list : list fitted_outcome in lead
                if `outcome_before_list' {
                    local step ""
                    display as error "Outcomes: put the list where the dependent variable normally goes."
                    exit 198
                }
            }
            if `"`margins'"'!="" {
                local step "margins() for outcome `y'"
                local failed_command `"margins, `margins' post"'
                quietly margins, `margins' post
            }
            local failed_command ""
            local step "reading `estimate_source' estimates for outcome `y'"
            matrix `B'=e(b)
            matrix `V'=e(V)
            scalar `n'=e(N)
            scalar `df'=e(df_r)
            local full : colfullnames `B'
            local bare : colnames `B'
            foreach term of local coefficients {
                local step "coefficients(`term') for outcome `y'"
                local hits=0
                forvalues c=1/`=colsof(`B')' {
                    local a : word `c' of `full'
                    local b : word `c' of `bare'
                    if "`a'"=="`term'" | (strpos("`term'",":")==0 & "`b'"=="`term'") {
                        local ++hits
                        local selected=`c'
                    }
                }
                if `hits'==0 {
                    local step ""
                    display as error "coefficients(): `term' is absent from the `estimate_source' for outcome `y'."
                    exit 498
                }
                if `hits'>1 {
                    local step ""
                    display as error "coefficients(): `term' matches multiple terms for outcome `y'. Use equation:name."
                    exit 498
                }
                if missing(`V'[`selected',`selected']) | `V'[`selected',`selected']<=0 {
                    local step ""
                    display as error "coefficients(): `term' is omitted or has no usable variance for outcome `y'."
                    exit 498
                }
                scalar `beta'=`B'[1,`selected']
                scalar `se'=sqrt(`V'[`selected',`selected'])
                scalar `stat'=`beta'/`se'
                capture quietly test _b[`term']=0
                local test_rc=_rc
                if `test_rc' {
                    local step ""
                    display as error "coefficients(): test failed for `term' in outcome `y'."
                    exit `test_rc'
                }
                scalar `p'=r(p)
                if missing(`p') | !inrange(`p',0,1) {
                    local step ""
                    display as error "coefficients(): test returned an invalid p-value for `term' in outcome `y'."
                    exit 459
                }
                local ++row
                local estimate ""
                if "`store'"!="" local estimate `store'`j'
                local step "writing the result for `term' in outcome `y'"
                frame post `result' (`j') (`row') (`selected') ("`y'") ///
                    ("`estimate'") ("`term'") (`"`fitted'"') ///
                    (`beta') (`se') (`stat') (`df') (`n') (`p')
            }
            if "`store'"!="" {
                local step "store() for outcome `y' (estimate `store'`j')"
                quietly estimates store `store'`j'
            }
        }
        * Raw script variable names are confined to this new frame.
        local step "q() while calculating or recording ordinary BH q-values"
        if inlist("`q'","qval","both") {
            frame `result': quietly fdrq__bh_original
            frame `result': rename bh95_qval qval
            frame `result': drop rank original_sorting_order
        }
        else {
            frame `result': generate float qval=.
        }
        local step "q() while calculating or recording sharpened BKY q-values"
        if inlist("`q'","qval_sharpened","both") {
            frame `result': quietly fdrq__bky_original
            frame `result': rename bky06_qval qval_sharpened
            frame `result': drop rank original_sorting_order
        }
        else {
            frame `result': generate float qval_sharpened=.
        }
        local reportopts ""
        foreach field in store tableopts {
            local content `"``field''"'
            if `"`content'"'!="" local reportopts `"`reportopts' `field'(`"`content'"')"'
        }
        local step ""
        fdrq__report, result(`result') outcomes(`outcomes') ///
            coefficients(`coefficients') q(`q') invocation(`"`invocation'"') ///
            `reportopts' `estadd' `table'
    }
    local rc = _rc
    if `rc' {
        if `"`step'"'!="" {
            display as error "fdrq: `step' failed (r(`rc'))."
            if `"`failed_command'"'!="" {
                display as error `"Command: `failed_command'"'
                error `rc'
            }
        }
        exit `rc'
    }
end

program define fdrq__report
    version 16.0
    syntax, RESULT(name) OUTCOMES(string) COEFficients(string) Q(string) ///
        INVOCATION(string) [STORE(string) TABLEOPTS(string) ESTADD TABLE]
    tempname B
    local step "displaying the results summary"
    capture noisily {
        frame `result': format b se statistic %10.4f
        frame `result': format pval qval qval_sharpened %9.3f
        frame `result': label variable qval "BH q-value"
        frame `result': label variable qval_sharpened "Sharpened q-value"
        frame `result': char _dta[fdrq_command] `"`invocation'"'
        frame `result': char _dta[fdrq_q] "`q'"
        frame `result': char _dta[fdrq_family] "All selected coefficients across the listed outcomes"
        frame `result': list outcome coefficient b se pval qval qval_sharpened, ///
            noobs sepby(outcome) abbreviate(24)

        if "`estadd'"!="" {
            local T : word count `coefficients'
            tempname QB QK value
            local j=0
            foreach y of local outcomes {
                local ++j
                local step "estadd for outcome `y' (estimate `store'`j')"
                quietly estimates restore `store'`j'
                matrix `B'=e(b)
                matrix `QB'=`B'
                matrix `QK'=`B'
                forvalues c=1/`=colsof(`B')' {
                    matrix `QB'[1,`c']=.
                    matrix `QK'[1,`c']=.
                }
                local t=0
                foreach term of local coefficients {
                    local ++t
                    local row=(`j'-1)*`T'+`t'
                    frame `result': local selected=coefficient_column[`row']
                    frame `result': scalar `value'=qval[`row']
                    matrix `QB'[1,`selected']=`value'
                    frame `result': scalar `value'=qval_sharpened[`row']
                    matrix `QK'[1,`selected']=`value'
                }
                if inlist("`q'","qval","both") quietly estadd matrix qval=`QB' : `store'`j'
                if inlist("`q'","qval_sharpened","both") quietly estadd matrix qval_sharpened=`QK' : `store'`j'
            }
        }
        if "`table'"!="" {
            local models ""
            forvalues k=1/`j' {
                local models `models' `store'`k'
            }
            local cells "b(fmt(3)) se(par fmt(3)) p(fmt(3))"
            if inlist("`q'","qval","both") local cells "`cells' qval(fmt(3))"
            if inlist("`q'","qval_sharpened","both") local cells "`cells' qval_sharpened(fmt(3))"
            local step "table while running esttab"
            if `"`tableopts'"'!="" local step "table/tableopts() while running esttab"
            esttab `models', keep(`coefficients') cells("`cells'") `tableopts'
        }
    }
    local rc = _rc
    if `rc' {
        display as error "fdrq: `step' failed (r(`rc'))."
        exit `rc'
    }
end

* Publish staged frames together; restore previous frames if either rename fails.
program define fdrq__publish
    version 16.0
    syntax, RESULT(name) FRAME(name) [DATASTAGE(name) DATAFRAME(name)]
    tempname oldresult olddata
    local moved_result=0
    local moved_data=0
    local published_result=0
    local published_data=0
    local step "frame(`frame')"
    capture noisily {
        capture frame `frame': count
        if !_rc {
            frame rename `frame' `oldresult'
            local moved_result=1
        }
        if "`dataframe'"!="" {
            local step "dataframe(`dataframe')"
            capture frame `dataframe': count
            if !_rc {
                frame rename `dataframe' `olddata'
                local moved_data=1
            }
        }
        local step "frame(`frame')"
        frame rename `result' `frame'
        local published_result=1
        if "`dataframe'"!="" {
            local step "dataframe(`dataframe')"
            frame rename `datastage' `dataframe'
            local published_data=1
        }
    }
    local rc=_rc
    if `rc' {
        if `published_data' capture frame rename `dataframe' `datastage'
        if `published_result' capture frame rename `frame' `result'
        if `moved_data' capture noisily frame rename `olddata' `dataframe'
        if `moved_result' capture noisily frame rename `oldresult' `frame'
        display as error "`step': could not save the output frame (r(`rc'))."
        exit `rc'
    }
end

* From fdr_qvalues.do, provided by Michael Anderson (20 November 2007).
program define fdrq__bh_original
    version 10
* Collect the total number of p-values tested

quietly sum pval
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank

quietly gen int original_sorting_order = _n
quietly sort pval
quietly gen int rank = _n if pval != .

* Set the initial counter to 1 

local qval = 1

* Generate the variable that will contain the BH (1995) q-values

gen bh95_qval = 1 if pval != .

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.

while `qval' > 0 {
	* Generate value qr/M
	quietly gen fdr_temp = `qval' * rank / `totalpvals'
	* Generate binary variable checking condition p(r) <= qr/M
	quietly gen reject_temp = ( fdr_temp >= pval ) if fdr_temp != .
	* Generate variable containing p-value ranks for all p-values that meet above condition
	quietly gen reject_rank = reject_temp * rank
	* Record the rank of the largest p-value that meets above condition
	quietly egen total_rejected = max( reject_rank )
	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	replace bh95_qval = `qval' if rank <= total_rejected & rank != .
	* Reduce q by 0.001 and repeat loop
	quietly drop fdr_temp reject_temp reject_rank total_rejected
	local qval = `qval' - .001
}
	
quietly sort original_sorting_order
end

* From fdr_sharpened_qvalues.do, provided by Michael Anderson (20 November 2007).
program define fdrq__bky_original
    version 10
* Collect the total number of p-values tested

quietly sum pval
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank

quietly gen int original_sorting_order = _n
quietly sort pval
quietly gen int rank = _n if pval != .

* Set the initial counter to 1 

local qval = 1

* Generate the variable that will contain the BKY (2006) sharpened q-values

gen bky06_qval = 1 if pval != .

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.


while `qval' > 0 {
	* First Stage
	* Generate the adjusted first stage q level we are testing: q' = q/1+q
	local qval_adj = `qval' / ( 1 + `qval' )
	* Generate value q'*r/M
	gen fdr_temp1 = `qval_adj' * rank / `totalpvals'
	* Generate binary variable checking condition p(r) <= q'*r/M
	gen reject_temp1 = ( fdr_temp1 >= pval ) if pval != .
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank1 = reject_temp1 * rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected1 = max( reject_rank1 )

	* Second Stage
	* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
	local qval_2st = `qval_adj' * ( `totalpvals' / ( `totalpvals' - total_rejected1[1] ) )
	* Generate value q_2st*r/M
	gen fdr_temp2 = `qval_2st' * rank / `totalpvals'
	* Generate binary variable checking condition p(r) <= q_2st*r/M
	gen reject_temp2 = ( fdr_temp2 >= pval ) if pval != .
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank2 = reject_temp2 * rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected2 = max( reject_rank2 )

	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	replace bky06_qval = `qval' if rank <= total_rejected2 & rank != .
	* Reduce q by 0.001 and repeat loop
	drop fdr_temp* reject_temp* reject_rank* total_rejected*
	local qval = `qval' - .001
}


quietly sort original_sorting_order
end

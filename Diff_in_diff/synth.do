* synthetic control
use twfe.dta, clear

* synthetic control applies for only one treatment group
* so we will collapse treated group to one
gen group2 = min(group,26)

tab group2 treat

* collapse dataset 
collapse (mean) outcome, by(group2 time)

* set time variable
tsset group2 time

* in our example, no other predictor variable other than pre-treatment outcomes
synth outcome outcome, trunit(26) trperiod(6) 

ereturn list

matrix list e(W_weights)


* construct synthetic control unit
reshape wide outcome, i(time) j(group2)

qui gen scont = 0
forv i=1/25{
qui replace scont = scont + outcome`i' * e(W_weights)[`i',2]
}


* graph the two groups
twoway (scatter outcome26 time, c(l)) || ///
(scatter scont time, c(l)), legend(order(1 "Treated" 2 "Synthetic Control")) ///
xtitle("Time") ytitle("Outcome") xline(5)


* graph only gap between the two groups
gen gap = outcome26 - scont
twoway (scatter gap time, c(l)), xtitle("Time") ytitle("Treated - Synthetic Control") yline(0) xline(5)

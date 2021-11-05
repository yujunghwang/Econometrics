* event study design

use twfe.dta, clear

* to use eventdd command,
* for control group, timediff must be missing
gen timediff = time - 6 if treatgp==1 

* use STATA command eventdd
eventdd outcome i.time i.group, timevar(timediff) method(ols, cluster(group)) level(95) baseline(-1) graph_op(xtitle("years relative to treatment year") ytitle("outcome")) 


* the above command used ols method
* you can also use reghdfe 
eventdd outcome, timevar(timediff) method(hdfe, absorb(time group) cluster(group)) level(95) baseline(-1) graph_op(xtitle("years relative to treatment year") ytitle("outcome")) 


* now we will manually create an eventdd graph
* set base year t=5 (treatment year-1)

* manually create interaction term
qui gen ttime = treatgp*time

reg outcome i.treatgp i.time ib5.ttime i.group, vce(cluster group)

coefplot, keep(*.ttime) vertical base yline(0) xline(5) ///
coeflabels(1.ttime="-5" 2.ttime="-4" 3.ttime="-3" 4.ttime="-2" 5.ttime="-1" 6.ttime="0" 7.ttime="+1" 8.ttime="+2" 9.ttime="+3" 10.ttime="+4") ///
xtitle("Time to Treatment") ytitle("Outcome")


* truncate leads and lags
coefplot, keep(3.ttime 4.ttime 5.ttime 6.ttime 7.ttime 8.ttime 9.ttime) ///
vertical base yline(0) xline(3) ///
coeflabels(3.ttime="-3" 4.ttime="-2" 5.ttime="-1" 6.ttime="0" 7.ttime="+1" 8.ttime="+2" 9.ttime="+3") ///
xtitle("Time to Treatment") ytitle("Outcome")

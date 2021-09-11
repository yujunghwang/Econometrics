* treatment at multiple timing
clear
* simulate fake data
set seed 210828
* 50 groups
set obs 50
gen group = _n

* 30 obs from each group
expand 30
gen id = _n

* 10 periods 
expand 10

sort id
bys id : gen time=_n

egen tag=tag(group)
gen temp =rnormal() if tag
bys group : egen unitfe =mean(temp)
drop temp tag

egen tag= tag(time)
gen temp =rnormal() if tag
bys time : egen timefe = mean(temp)
drop temp tag
replace timefe = timefe + 0.5*time

sort group id time

* treatment groups are treated at different timing
* treatment year varies between 3,4,5,6,7
gen treatgp =group>25

egen tag=tag(group)
bys group : gen temp   =floor(3+5*runiform()) if treatgp==1 & tag
bys group : egen ttime = mean(temp)
drop temp tag

gen outcome = 1 + unitfe + timefe + rnormal()


* assume dynamic treatment effect with slope delta\
gen     treat =time>=ttime if treatgp==1
replace treat =0           if treatgp==0

local delta = 1
replace outcome = outcome + `delta'*(time-ttime+1) if treat==1 


* check treamtent timing
tab group ttime



*********************
* run diff-in-diff in a robust way
did_multiplegt outcome group time treat, robust_dynamic dynamic(4) placebo(4) jointtestplacebo breps(100) cluster(group) covariances seed(210828) longdiff_placebo


**********************************************************
* compare this to usual event study design command
gen timediff=time-ttime if treatgp==1

eventdd outcome treatgp i.time i.group, timevar(timediff) method(ols, cluster(group)) level(95) baseline(-1) graph_op(xtitle("years relative to treatment year") ytitle("outcome")) 


eventdd outcome, timevar(timediff) method(hdfe, absorb(time group) cluster(group)) level(95) baseline(-1) graph_op(xtitle("years relative to treatment year") ytitle("outcome")) 


* manually create interaction term
qui gen     ttime2 = treatgp*timediff

* shifts to remove negative values
qui replace ttime2 = ttime2 + 7

* control group
qui replace ttime2 =0                if treatgp==0

* treatment year -1 is baseline
reg outcome treatgp i.time ib6.ttime2 i.group, vce(cluster group)

coefplot, keep(*.ttime2) vertical base yline(0) ci(95) ///
coeflabels(1.ttime2="-6" 2.ttime2="-5" 3.ttime2="-4" 4.ttime2="-3" 5.ttime2="-2" 6.ttime2="-1" 7.ttime2="0" 8.ttime2="+1" 9.ttime2="+2" 10.ttime2="+3" 11.ttime2="+4" 12.ttime2="+5" 13.ttime2="+6" 14.ttime2="+7") ///
xtitle("Time to Treatment") ytitle("Outcome")



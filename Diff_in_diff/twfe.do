* two way fixed effect regression
clear

* this is similar to dd regression but with more time periods and more groups
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

gen outcome = 1 + unitfe + timefe + rnormal()

local delta = 1
* half of the group is treated at time t=6 
* treatment effect size is delta

gen treat = group>25 & time>=6
replace outcome = outcome + `delta' if treat==1 

gen treatgp =group>25

* make dummy variables
gen post  = time>5

* save data
save twfe.dta, replace


* check outcome in a graph
preserve
collapse (mean) outcome, by(treatgp time)

twoway (scatter outcome time if treatgp==0, c(l)) || ///
(scatter outcome time if treatgp==1, c(l)), ///
legend(order(1 "Control" 2 "Treatment")) xline(6) ///
xtitle("time") 
restore


* now let's run dd regression to estimate the treatment effect delta



* ## means interaction
* i. means categorical variable

* dd regression
reg outcome treatgp post i.treatgp##i.post, vce(cluster group)

* twfe
reg outcome treat i.group i.time, vce(cluster group)

* another stata command : twfe
twfe outcome treat, id(group time) cluster(group)

* another stata command : reghdfe
reghdfe outcome treat, absorb(group time) vce(cluster group)


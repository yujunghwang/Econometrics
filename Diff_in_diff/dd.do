* simple 2 by 2 dd regression
clear

set seed 210828

* simulate fake data
set obs 3000
gen id =_n
gen group = (_n>1500) +1 

gen unitfe = (group==2)

expand 2

sort id
bys id : gen time=_n

gen     timefe = 0 if time==1
replace timefe = 1 if time==2 

gen outcome = 1 + unitfe + timefe + rnormal()

local delta = 1
* unit 2 is treated at time t=2
* treatment effect size is delta
replace outcome = outcome + `delta' if group==2 & time==2 



* check outcome in a graph
preserve
collapse (mean) outcome, by(group time)

twoway (scatter outcome time if group==1, c(l)) || ///
(scatter outcome time if group==2, c(l)), ///
legend(order(1 "Group 1" 2 "Group 2")) ///
xtitle("time") 
restore


* now let's run dd regression to estimate the treatment effect delta

* make dummy variables
gen treat = group==2
gen post  = time==2

* ## means interaction
* i. means categorical variable
* ## controls for i.treat and i.post
reg outcome i.treat##i.post, vce(cluster group)


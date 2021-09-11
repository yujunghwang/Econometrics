* permutation test
use twfe,clear

* run twfe and save the coefficent
reghdfe outcome treat, absorb(group time) vce(cluster group)

* save the estimate
matrix define est =J(1,1,1)
matrix est[1,1] =_b[treat]


* count treated units
egen tag=tag(group)
tab treatgp if tag


matrix define placebo=J(100,1,1)

quietly{
* permutation test 100 times
forv i=1/100{
preserve
* randomly select 25 groups
gen  temp =runiform() if tag
egen temp2 =rank(temp)
bys group : egen temp3 = mean(temp2)

drop treat treatgp
gen treatgp = temp3<26
gen treat   = treatgp==1 & time>=6

reghdfe outcome treat, absorb(group time) vce(cluster group)
matrix placebo[`i',1] = _b[treat]
restore
}
}

clear
svmat est
svmat placebo

local est=est[1]

* compute exact p-value
qui gen ind=placebo1>`est'
su ind
local pval= `r(mean)'
di `pval'

twoway histogram placebo1, bin(20) xlabel(-1(0.1)1) xline(`est')

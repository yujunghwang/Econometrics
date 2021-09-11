* nearest neighbor matching

* load exact matching data
use nnmatching.dta, clear

* browse the data
br

* what is ATT?
* compute manually using a formula
di ((5-4) + (2-0) + (10-5) + (6-1))/4


* compute ATT using STATA command
* check that exact match fails
teffects nnmatch (Y X) (D), atet ematch(X) vce(iid)


* switch to nearest neighbor matching
teffects nnmatch (Y X) (D), atet nn(1) vce(iid) gen(match)


* if there are more than 2 observations for each match, it's recommended to use vce(robust) option instead


* generate much larger sample
clear
set seed 210815
set obs 10000
gen X=runiformint(0,20)
* distribution of X is different in D=0 versus D=1
gen D=(-1+0.1*X+runiform())>0.5
* true ate is 1
gen Y = rnormal() + D 

* plot control group treatment group histogram
twoway histogram X, by(D)
* do you see any assumptions violated?

**********************
* try exact matching
**********************
teffects nnmatch (Y X) (D), ate ematch(X) osample(outofsamp)
tab outofsamp


preserve
drop if outofsamp==1
drop outofsamp

teffects nnmatch (Y X) (D), ate ematch(X) 
* check estimated ate is close to the true ate
restore

********************
* next try nearest neighbor matching
********************

teffects nnmatch (Y X) (D), ate nn(1) 
* we are using nn matching so every observation is used at this time
* you can set maximum discrepancy (use caliper option)


* reduce bias in X discrepancy
teffects nnmatch (Y X) (D), ate nn(1) biasadj(X)


* compare results 


* when you have multiple covariates to match you can mix nearest neighbor matching with exact matching


















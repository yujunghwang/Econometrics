* simulate data
clear
set seed 210822

* num of individuals
set obs 1000

* generate individual fixed effects
gen id = _n
gen u  =rnormal()

* now generate 10 observations for each individual
expand 10
sort id

* generate time dimension
bys id : gen time=_n

* generate treatment
gen d = u + rnormal()

* generate outcome
gen y = 2 + 0.5*d + u + rnormal()

* note that u affects both y and d
* so d is endogenous regressor


/*
let's run regressions with fake data now !
*/


* usual OLS
reg y d, r
* do you see the estimates are biased?


* now, let's run a fixed effect regression
* first set panel dimensions (id, time)
xtset id time

* next run a FE regression
xtreg y d, fe

* or 

xtreg y d, fe vce(cluster id)
* you can cluster standard error at the individual level
* do you see that the bias is gone now?


* now let's demean by ourselves and run FE regression manually
bys id : egen meany = mean(y)
bys id : egen meand = mean(d)

gen dy = y - meany
gen dd = d - meand


reg dy dd
* check that the SE is different
* SE from xtreg command is correct !


* now let's consider running a regression with dummy variables
reg y d i.id
* see you can't do this easily because you have too many parameters ! (incidental parameter problem)


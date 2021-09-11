
* simulate data
clear
set seed 210822


* first stage
set obs 5000
* instrument z
gen z = rnormal()
* source of endogeneity u
gen u =rnormal()

* endogenous variable d
gen d=0.3+ z + u + rnormal()

* exogenous variable x
gen x=rnormal()

* outcome variable y
* because of u, d is endogenous
gen y=0.2+0.5*d + 0.3*x + u + rnormal()


* now we run regressions with fake data !

* run regression to check the OLS is not consistent
reg y d, r


* let's run 2SLS
ivreg2 y (d=z) x, r



* let's compare the results with manual 2sls

* manual first stage
reg d z x,r
* predict d hat
predict dhat, xb

* manual second stage
reg y dhat x, r

* how are the results different?


* you should use results from "ivreg2" instead of manual 2SLS


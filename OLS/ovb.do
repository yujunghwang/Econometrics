
* omitted variable bias example


clear
set obs 100000

* simulate fake data
gen schooling = 10 + 6*runiform()
gen ability = 2*schooling +  rnormal()

gen income = 2 + 0.07*schooling + ability + rnormal()


* run a regression without ability
reg income schooling, r

* do you see the coefficient is different from true parameters?


* run a true model
reg income schooling ability,r


* does the reduced model underestimate or overestimate the return to schooling?


* Is this consistent with the ovb sign you predict?
reg ability schooling, r



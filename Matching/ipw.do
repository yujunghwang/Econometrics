
clear
set seed 210815
set obs 10000
gen X=runiformint(0,20)
* distribution of X is different in D=0 versus D=1
gen D=(-1+0.1*X+runiform())>0.5
* true ate is 1
gen Y = rnormal() + D 

* estimate propensity score
logit D X
predict pscore

* compare propensity scores by groups
twoway histogram pscore, by(D)

* compute ATE using Horvitz and Thompson estimator
gen temp = Y*(D-pscore)/(pscore*(1-pscore))
su temp


* use normalized weight
gen d1=D/pscore
gen d0=(1-D)/(1-pscore)

gen yd1 = Y*D/pscore
gen yd0 = Y*(1-D)/(1-pscore)


egen ys1=sum(yd1)
egen  s1=sum(d1)

egen ys0=sum(yd0)
egen  s0=sum(d0)

su ys1
local a=`r(mean)'

su s1
local b=`r(mean)'

su ys0
local c=`r(mean)'

su s0
local d=`r(mean)'

di `a'/`b' - `c'/`d'


gen psweight = D/pscore + (1-D)/(1-pscore)
reg Y D [pweight=psweight]

* check the ate estimate is the same
* use command
teffects ipw (Y) (D X), ate







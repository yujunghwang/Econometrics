* ATE.do

clear all

set obs 30000
set seed 210809

* simulate data
local ate=2

gen y1 =rnormal() + `ate'
gen y0 =rnormal() 

* endogenous selection into treatment
gen d=( -1 + 0.5*(y1 - y0) - 0.7*y0 + rnormal() >0)

tab d

gen outcome= d*y1 + (1-d)*y0


* compute ATE
* suppose you observe both y1 and y0 for all observations
qui su y1
local y1mean =r(mean)

qui su y0
local y0mean =r(mean)

di `y1mean' - `y0mean'

global ate_est = `y1mean' - `y0mean'


* compute ATT
qui su y1 if d==1
local y1mean =r(mean)

qui su y0 if d==1
local y0mean =r(mean)

di `y1mean' - `y0mean'

global att_est =`y1mean' - `y0mean'


* compute ATU
qui su y1 if d==0
local y1mean =r(mean)

qui su y0 if d==0
local y0mean =r(mean)

di `y1mean' - `y0mean'

global atu_est =`y1mean' - `y0mean'


* compare observed outcome differences with ATE
qui su outcome if d==1
local y1mean =r(mean)

qui su outcome if d==0
local y0mean =r(mean)

global dif =`y1mean' - `y0mean'
di $dif

* another way to compute the dif 
reg outcome d
di _b[d]

di "outcome difference is $dif and the ATE is $ate_est "


* ATE decomposition
local rhs =round($dif , 0.001)

qui su y0 if d==1
local y0d1 =r(mean)
qui su y0 if d==0
local y0d0 =r(mean)

qui su d
local dmean =r(mean)

local lhs =round($ate_est + `y0d1' -`y0d0' + (1-`dmean')*($att_est - $atu_est) , 0.001)

di "rhs is `rhs' and lhs is `lhs'"


local bias =round(`y0d1' -`y0d0' + (1-`dmean')*($att_est - $atu_est) , 0.001)

di "bias is `bias'"


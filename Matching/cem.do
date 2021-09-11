* cem.do
clear
set seed 210815
set obs 10000
gen X=runiformint(0,20)
* distribution of X is different in D=0 versus D=1
gen D=(-1+0.1*X+runiform())>0.5
* true ate is 1
gen Y = rnormal() + D 


* specify manual cutpoints
cem X (0 5 10 15 20), treatment(D)

reg Y D [pweight=cem_weights] if cem_matched==1, r

drop cem*

* use automatic binning
* compare the number of bins
cem X, treatment(D) showbreaks

reg Y D [pweight=cem_weights] if cem_matched==1, r



clear
use nnmatching.dta

* use automatic binning
* compare the number of bins
cem X, treatment(D) showbreaks

reg Y D [pweight=cem_weights] if cem_matched==1, r


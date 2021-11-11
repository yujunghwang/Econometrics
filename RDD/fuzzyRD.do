
* fuzzy RD
clear

set seed 210830

* simulate sharp RD data
set obs 10000
gen X = runiform()
gen D = ((X>=0.5) + 1.5*rnormal() >= 0.5 )
gen Y = 1 + 0.3*X + 1*D + rnormal()

egen xbin = cut(X), at(0(0.05)1)

*************************
* visually display the RD
*************************
preserve
collapse (mean) Y X D, by(xbin)
sort X
twoway (scatter D X), xline(0.5) 
restore

preserve
collapse (mean) Y X D, by(xbin)
sort X
twoway (scatter Y X), xline(0.5) 
restore

***************************
* run fuzzy RD regression
* set a window you will use
***************************

global bw = 0.3

* set cutoff
global cutoff=0.5

* generate a recentered variable
gen dX = X - $cutoff

* run a regression using 4th order polynomial
gen dX2 = dX^2
gen dX3 = dX^3
gen dX4 = dX^4

gen Z = X>= $cutoff

****************************
* check how regression specification changes the result
****************************
preserve
keep if abs(dX)<$bw

ivreg2 Y dX (D i.D#c.dX = Z i.Z#c.dX), r
* RD estimate with SE
di _b[D]
di _se[D]

* model fit
predict yhat, xb

collapse (mean) Y X yhat, by(xbin)
sort X
twoway (scatter Y X)  || (line yhat X if X< $cutoff ) || ///
(line yhat X if X>=$cutoff , xline($cutoff ) legend(off)) 
restore

preserve
keep if abs(dX)<$bw

ivreg2 Y dX dX2 dX3 dX4 (D i.D#c.(dX dX2 dX3 dX4) = Z i.Z#c.(dX dX2 dX3 dX4)), r

* RD estimate with SE
di _b[D]
di _se[D]

* model fit
predict yhat, xb

collapse (mean) Y X yhat, by(xbin)
sort X
twoway (scatter Y X)  || (line yhat X if X<$cutoff ) || ///
(line yhat X if X>=$cutoff , xline($cutoff ) legend(off)) 
restore

***************
* data-driven bandwidth selection
***************

*rdbwselect Y X, c($cutoff ) kernel(epanechnikov) fuzzy(D)

* use rdrobust command
* if you do not set the bandwidth, it automatically choose the optimal bandwidth
rdrobust Y X, c($cutoff ) kernel(epanechnikov) fuzzy(D)
matrix list e(b)
* SE
di sqrt(e(V)[1,1])


****************************************
*** validating continuity assumption ***
****************************************

* placebo test

* pick a placebo cutoff
global pbcutoff1 =0.4
global pbcutoff2 =0.6

* RD estimate
rdrobust Y X, c($pbcutoff1 ) kernel(epanechnikov) fuzzy(D)
matrix list e(b)
di sqrt(e(V)[1,1])

* RD estimate 2
rdrobust Y X, c($pbcutoff2 ) kernel(epanechnikov) fuzzy(D)
matrix list e(b)
di sqrt(e(V)[1,1])




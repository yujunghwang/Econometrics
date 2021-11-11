* sharp RD example
clear

set seed 210830

* simulate sharp RD data
set obs 10000
gen X = runiform()
gen Z = 0.5*X + 1.5*rnormal()
gen D = X>=0.5
gen Y = 1 + 0.3*X + 1*D + rnormal()

egen xbin = cut(X), at(0(0.05)1)

* visually display the RD
preserve
collapse (mean) Y X, by(xbin)
sort X
twoway (scatter Y X), xline(0.5) 
restore


* run sharp RD regression

* set a window you will use
global bw = 0.3

* set cutoff
global cutoff=0.5

*** polynomial method ***
* generate a recentered variable
gen dX = X - $cutoff

* run a regression using 4th order polynomial
gen dX2 = dX^2
gen dX3 = dX^3
gen dX4 = dX^4


reg Y i.D##c.(dX dX2 dX3 dX4) if X >= $cutoff - $bw & X <= $cutoff + $bw, r

* RD estimate with SE
di _b[1.D]
di _se[1.D]


* model fit
predict yhat, xb
preserve
collapse (mean) Y X yhat, by(xbin)
sort X
twoway (scatter Y X if X >= $cutoff - $bw & X <= $cutoff + $bw )  || (line yhat X if X<$cutoff & X >= $cutoff - $bw ) || ///
(line yhat X if X>=$cutoff & X <= $cutoff + $bw, xline($cutoff ) legend(off)) 
restore


*** local polynomial version ***

* use lpoly command
preserve
lpoly Y dX if X< $cutoff & X >= $cutoff - $bw, kernel(epanechnikov) deg(1) gen(xg yg) se(se) nograph
keep xg yg se
drop if xg==.
save temp1.dta, replace
restore

preserve
lpoly Y dX if X> $cutoff & X <= $cutoff + $bw, kernel(epanechnikov) deg(1) gen(xg yg) se(se) nograph
keep xg yg se
drop if xg==.
append using temp1.dta
g ciplus=yg+1.96*se
g ciminus=yg-1.96*se
keep if abs(xg)< $bw
save temp2.dta, replace
restore
erase temp1.dta

preserve
collapse (mean) Y X yhat, by(xbin)
sort X
append using temp2.dta

replace X = xg + $cutoff if X==. & xg!=.

twoway (scatter Y X if X >= $cutoff - $bw & X <= $cutoff + $bw )  || ///
(line yg X if X<$cutoff  & X >= $cutoff - $bw ,lc(orange) ) || ///
(line yg X if X>=$cutoff & X <= $cutoff + $bw , lc(orange)) || ///
(line ciplus X  if X<$cutoff  & X >= $cutoff - $bw , lp(dash) lc(orange) ) || ///
(line ciminus X if X<$cutoff  & X >= $cutoff - $bw , lp(dash) lc(orange) ) || ///
(line ciplus X  if X>=$cutoff & X <= $cutoff + $bw , lp(dash) lc(orange) ) || ///
(line ciminus X if X>=$cutoff & X <= $cutoff + $bw , lp(dash) lc(orange) ), xline($cutoff ) legend(off) 
graph export lpolyex.png, as(png) replace
restore

* rdplot command
preserve
drop if abs(dX)>$bw
rdplot Y X, c($cutoff ) ci(95) shade kernel(epanechnikov) nbins(20 20) graph_options(title(RD graph))
restore

* data-driven bandwidth selection
*rdbwselect Y X, c($cutoff ) kernel(epanechnikov)

* use rdrobust command
* if you do not set the bandwidth, it automatically choose the optimal bandwidth
rdrobust Y X, c($cutoff ) kernel(epanechnikov) 
matrix list e(b)
* SE
di sqrt(e(V)[1,1])


*** validating continuity assumption ***

* balancing covariates
preserve
drop if abs(dX) >$bw
rdplot Z X, c($cutoff ) kernel(epanechnikov) ci(95) shade kernel(epanechnikov) nbins(20 20)
restore

rdrobust Z X, c($cutoff ) kernel(epanechnikov)


* density test
rddensity X, c($cutoff ) kernel(epanechnikov)

* density test statistics
di e(T_q)
di e(pv_q)

* placebo test

* pick a placebo cutoff
global pbcutoff1 =0.4
global pbcutoff2 =0.6

* RD estimate
rdrobust Y X, c($pbcutoff1 ) kernel(epanechnikov)
matrix list e(b)
di sqrt(e(V)[1,1])

* RD estimate 2
rdrobust Y X, c($pbcutoff2 ) kernel(epanechnikov)
matrix list e(b)
di sqrt(e(V)[1,1])

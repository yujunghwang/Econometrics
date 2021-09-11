* sharp RD example

clear

set seed 210830

* simulate sharp RD data
set obs 10000
gen X = runiform()
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

* generate a recentered variable
gen dX = X - 0.5

* run a regression using 4th order polynomial
gen dX2 = dX^2
gen dX3 = dX^3
gen dX4 = dX^4

reg Y i.D##c.(dX dX2 dX3 dX4), r

* model fit
predict yhat, xb

preserve
collapse (mean) Y X yhat, by(xbin)
sort X
twoway (scatter Y X)  || (line yhat X if X<0.5) || ///
(line yhat X if X>=0.5, xline(0.5) legend(off)) 
restore


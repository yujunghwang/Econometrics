* fuzzy RD
clear

set seed 210830

* simulate sharp RD data
set obs 10000
gen X = runiform()
gen D = ((X>=0.5) + 1.5*rnormal() >= 0.5 )
gen Y = 1 + 0.3*X + 1*D + rnormal()

egen xbin = cut(X), at(0(0.05)1)

* visually display the RD
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


* run fuzzy RD regression

* generate a recentered variable
gen dX = X - 0.5

* run a regression using 4th order polynomial
gen dX2 = dX^2
gen dX3 = dX^3
gen dX4 = dX^4

gen Z = X>=0.5

* check how regression specification changes the result
preserve
reg D i.Z##c.(dX)
predict Dhat, xb

reg Y c.Dhat##c.(dX)
* model fit
predict yhat, xb

collapse (mean) Y X yhat, by(xbin)
sort X
twoway (scatter Y X)  || (line yhat X if X<0.5) || ///
(line yhat X if X>=0.5, xline(0.5) legend(off)) 
restore


preserve
reg D i.Z##c.(dX dX2 dX3 dX4)
predict Dhat, xb

* check the RDD estimate
* how does it depend on specification?
reg Y c.Dhat##c.(dX dX2 dX3 dX4)

* model fit
predict yhat, xb

collapse (mean) Y X yhat, by(xbin)
sort X
twoway (scatter Y X)  || (line yhat X if X<0.5) || ///
(line yhat X if X>=0.5, xline(0.5) legend(off)) 
restore

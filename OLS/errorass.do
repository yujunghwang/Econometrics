

clear all

set seed 210804

* homoscedasticity
set obs 3000
gen x=runiform()
gen u=rnormal(0,1)
gen y = 0.1 + 2*x + u

reg y x 
predict uhat, residuals

* plot fitted regression lines
twoway (scatter y x) || (lfit y x), title("regression fit w/ hom. errors")
graph export hom_model_fit.png, as(png) replace

* plot residuals
twoway (scatter uhat x), title("homoscedastic errors") yline(0)
graph export hom_error.png, as(png) replace



* heteroscedasticity
set more off
gen u2=.
forv n=1/3000{
replace u2=rnormal(0,2*x)   if _n==`n'
}

gen y2=0.1 + 2*x + u2

reg y2 x
predict uhat2, residuals


* plot fitted regression lines
twoway (scatter y2 x) || (lfit y2 x), title("regression fit w/ hetero. errors")
graph export het_model_fit.png, as(png) replace

* plot residuals
twoway (scatter uhat2 x), title("heteroscedastic errors") yline(0)
graph export het_error.png, as(png) replace



* compare standard error of beta
* assume homoscedasticity
reg y2 x

* assume heteroscedasticity
reg y2 x, r

* observe that beta hats are same but only standard errors of the betas are different !


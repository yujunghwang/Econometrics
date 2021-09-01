* partialling out example
clear

set obs 3000
gen x1=runiform()
gen x2= 0.5*x1 + rnormal()
gen y = 2 + 0.3*x1 + 0.5*x2 + rnormal()

reg y x1 x2

* we can get the same coefficient on x1 by "partialling out variation explained by x2".
reg y x2
predict ry, residuals

reg x1 x2
predict rx1, residuals


* confirm results are same
reg ry rx1



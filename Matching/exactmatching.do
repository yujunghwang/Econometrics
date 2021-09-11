* exact matching example

* load exact matching data
use exactmatching.dta, clear

* browse the data
br

* what is ATT?
* compute manually using a formula
di ((5-4) + (2-0) + (10-5) + (6-1))/4


* compute ATT using STATA command
teffects nnmatch (Y X) (D), atet ematch(X) vce(iid)


* Most likely you will not use exact matching in most cases
* Instead you will use nearest neighbor matching or coarsened exact matching or 
* propensity score matching estimator

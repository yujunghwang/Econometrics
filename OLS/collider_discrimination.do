* collider bias
* reference : https://mixtape.scunning.com/dag.html

clear all
set obs 10000

set seed 210806

* Half of population is female
gen female=runiform()>=0.5

* innate ability is independent of gender
gen ability=rnormal()

* all women experience discrimination in this code
gen discrimination = female

* DGP
gen occupation = 1 + 2*ability -2*discrimination + rnormal()
gen wage = 1 -discrimination + occupation + 2*ability + rnormal()

* regression
reg wage female
reg wage female occupation
reg wage female occupation ability





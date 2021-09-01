
clear all

set seed 210804

sysuse nlsw88.dta  


* see what variables are in the dataset
* describe
de
* summarize
su


* regression models
gen poexp = age - grade
gen poexp2 = poexp^2

label var poexp  "Potential experience (years)"
label var poexp2 "Potential experience square"

label var grade "Years of education"

* simplest mincerian regression
reg wage grade poexp poexp2, r

* can anyone tell why the coefficient for "age" is omitted?
reg wage grade poexp poexp2 age, r


* i.(varname) means the variable is categorical variable
* see how the coefficients are reported for this variable
reg wage grade poexp poexp2 i.race married, r

reg wage grade poexp poexp2 i.race married smsa south, r


* or you can make it tidy
* use global variable
global control0     grade poexp poexp2
global control1     i.race married
global control2     smsa south

reg wage $control0 , r
reg wage $control0 $control1 , r
reg wage $control0 $control1 $control2 , r


* export regression tables
* export in Latex file

* install the following command if you have not done yet
* ssc install estout

est clear

reg wage $control0 , r
est store model1
estadd local demo="No"
estadd local geo="No"

reg wage $control0 $control1 , r
est store model2
estadd local demo="Yes"
estadd local geo="No"

reg wage $control0 $control1 $control2 , r
est store model3
estadd local demo="Yes"
estadd local geo="Yes"

#delimit ;
estout model1 model2 model3 using "regtable.tex", replace
cells(b(star fmt(3)) p(par fmt(3))) style(tex)  notype    
keep($control0 ) mlabels(,none) collabels(none) label 
varwidth(12) modelwidth(12) abbrev
stats(demo geo r2 N,
	labels("Demo. Control" "Geo. Control" "R-squared" "N")
	fmt(0 0 3 %9.0fc))
	noabbrev starlevels(* 0.10 ** 0.05 *** 0.01)
	varlabels(_cons Constant)
	prehead("\begin{table}[htbp]" "\centering" 
	"\caption{Typical Regression Table}" "\label{table.regtable}" 
	"\begin{tabular}{l*{@E}{c}}"
	"\hline"
	)
	posthead("\hline" " & \multicolumn{3}{c}{Dependent Variable : Hourly Wage}\\" "\hline")
	prefoot("\\" "\hline")
	postfoot("\hline\hline" 
	"\multicolumn{4}{l}{Note : We computed heteroscedasticity robust standard errors.} \\" 
	"\multicolumn{4}{l}{* p$<$0.10, ** p$<$0.05, *** p$<$0.01}\\"
	"\end{tabular}"
	"\end{table}");
#delimit cr;

* export in excel

* install the following command if you have not done yet
* ssc install outreg2

local replace replace
reg wage $control0 , r
outreg2 using "regtable.xls", keep($control0 ) addtext(Demo. Control, No, Geo. Control, No) label nocon excel dec(3) `replace'
local replace	
	
reg wage $control0 $control1 , r
outreg2 using "regtable.xls", keep($control0 ) addtext(Demo. Control, Yes, Geo. Control, No) label nocon excel dec(3) 

reg wage $control0 $control1 $control2 , r
outreg2 using "regtable.xls", keep($control0 ) addtext(Demo. Control, Yes, Geo. Control, Yes) label nocon excel dec(3) 






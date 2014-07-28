/*-------------------------------------------------------------------------------
# Name:		07_foodsecurity 
# Purpose:	Process household data and create food security variables
# Author:	Tim Essam, PhD
# Created:	11/15/2013
# Modified: 	07/23/2014
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	none
# Dependencies: copylabels.do; attachlabels.do
#-------------------------------------------------------------------------------*/

clear
capture log close
log using "$pathlog/foodsecurity", replace
set more off

* Load in transfers module data *
use "$pathin/ecvmamen_p2_en.dta"
sort hid

* Check food concerns about food
ren ms12q01 foodWorry
g byte foodinsuf = inlist(ms12q04, 2)
la var foodinsuf "Insufficent food for entire household"

* Create food shortage dummy by month (Use growing season as year)
local agrp e f g h i j k l m n o p
local bgrp Oct Nov Dec Jan Feb Mar Apr May Jun Jul Aug Sep
local n: word count `agrp'

* Use a double loop to create variable while meeting condition of 2nd
forvalues i = 1/`n' {
	local a: word `i' of `agrp'
	local b: word `i' of `bgrp'
	g byte foodpbrm`b' = inlist(ms12q05`a',1)
	la var foodpbrm`b' "Food problems in `b'"
}
*end

#delimit ;
egen foodpbrmTot = rowtotal(foodpbrmOct foodpbrmNov foodpbrmDec foodpbrmJan foodpbrmFeb 
	foodpbrmMar foodpbrmApr foodpbrmMay foodpbrmJun foodpbrmJul foodpbrmAug foodpbrmSep);
#delimit cr

g pctFoodprbm = foodpbrmTot/12
la var pctFoodprbm "Percent of months with food problems in hh"

* Grain stock information
ren ms12q07 grainstk
recode grainstk (2=0)

* Generate cut points of grain holdings based on weeks and months
egen grainstkDays = cut(ms12q08), at(1, 15, 30, 60, 90, 120, 150, 180, 365) icodes
recode grainstkDays (.=0)
la var grainstkDays "Amount of time food stock covers familiy needs"
la define stck 0 "No stocks or NA" 1 "Up to 2 weeks" 2 "2 weeks to 1 month" 3 " 1-2 months" ////
	4 "2-3 months" 5 "3-4 months" 6 "4-5 months" 7 "5-6 months" 8 "more than 6 months"
label values grainstkDays stck
tab grainstkDays, mi

/* Cause of food insecurity:
	1) Harvest issues - drought, insects, inputs, soil, or access
	2) Market access - high costs of products or difficult access
	3) Financial constrains - low financial resources
	4) other
*/

g byte foodInsHarv = inlist(ms12q06a, 1, 2, 3, 4, 5)
la var foodInsHarv "Food insecurity caused by harvest/ag outcomes"

g byte foodInsMkt = inlist(ms12q06a, 6, 7)
la var foodInsMkt "Food insecurity due to market access or prices"

g byte foodInsFin = inlist(ms12q06a, 8)
la var foodInsFin "Food insecurity caused by financial constraints"

g byte foodInsOth = inlist(ms12q06a, 9, 10, 11)
la var foodInsOth "Food insecurity caused other outcomes"

*Keep only relevant variables
ds(ms1* as* ms00*), not
keep `r(varlist)'

save "$pathout/foodsec.dta", replace

* Merge in base data to get cuts by region/dept
local agrp hhagasset hhchar hhdur hhinfra hhnc hhpc transfers shocks
local n: word count `agrp'

forvalues i = 1/`n'  {
	local a: word `i' of `agrp'
	display in yellow "Data set for `a'"
	merge 1:1 hid using "$pathout/`a'.dta"
	drop _merge
}
*

graph bar (sum) foodpbrmOct-foodpbrmSep, showyvars yvaroptions(relabel(1 ////
	"Oct" 2 "Nov" 3 "Dec" 4 "Jan" 5 "Feb" 6 "Mar" 7 "Apr" 8 "May" 9 "Jun" ////
	10 "Jul" 11 "Aug" 12 "Sep")) blabel(bar, format(%9.0gc) size(vsmall)) ////
	legend(off) scheme(burd) ylabel(0(250)1500) ////
	ytitle(Number of households , size(medsmall)) ////
	title(Households with food problems by growing season months, size(medium)) ////
	note(n = 3968)

g ageHeadsq = ageHead^2	
	
* Conduct basic regression analysis on some of the outcomes
set more off
tab region, gen(regBin)
global depvar "grainstk"
global exog1 "femHead marriedHead ageHead ageHeadsq literateHead eduMuslimHead educHigh mobile hhSize sexRatio depRatio hhmixed"
global exog2 "femHead marriedHead ageHeadsq ageHead literateHead eduMuslimHead educHigh mobile hhSize sexRatio depRatio under24Share hhmixed mlabor flabor"
global exog3 "$exog2 infraindex_ntl wealth agwealth_ntl"
global location "urbrur regBin1 regBin2 regBin3 regBin4 regBin5 regBin6 regBin7" 
local append "replace"
local options "robust or" /* robust or */

* Loop over the four main types of shocks and look at exogeneous factors 
foreach y of varlist $depvar{
	foreach x of numlist 1/3 {
		logit `y'  ${exog`x'} $location, `options' 
		outreg2 using "$pathout/foodinsec", bdec(3) br eform cti(odds ratio) ////
		label adds(Psuedo-R2, e(r2_p), Log pseudlolikelihood, e(ll)) `append'
		local append "append" 
	}
}
*end
compress
save "$pathout/hh_combined.dta", replace

log2html "$pathlog/foodsecurity", replace

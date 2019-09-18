/*-------------------------------------------------------------------------------
# Name:		06_shocks
# Purpose:	Process household data and create shock variables
# Author:	Tim Essam, PhD
# Created:	11/15/2013
# Modified: 	07/23/2014
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	copylabels.do; attachlabels.do
# Dependencies: agrp hhagasset hhchar hhdur hhinfra hhnc hhpc transfers
#-------------------------------------------------------------------------------*/

clear
capture log close
log using "$pathlog/shocks", replace
set more off

* Load in transfers module data *
use "$pathin/ecvmachoc_p1_en.dta"
sort hid

* Look at cross-tab of shocks & severity
tab ms11q01 ms11q03 if ms11q02==1

* Create filter to keep only those shocks that are the 1/2 most severe
g byte severe = inlist(ms11q03, 1,2)==1
g byte severe_affected = inlist(ms11q03, 1,2) & ms11q02 == 1

* Food prices, drought, crop disease are most common
* Few conflict shocks, but we can pursue further

* Generate any shock related to ag/food/health
g byte anyshock = (inlist(ms11q01, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 17)==1 &  ms11q02==1 & severe==1)
la var anyshock "HH faced shocks related to weather, ag, food, health"

* Weather shocks
g byte weathershk = (inlist(ms11q01, 1, 2)==1 & ms11q02==1 & severe==1)
la var weathershk "HH faced rain/drought shock"

g byte droughtshk = (inlist(ms11q01, 1)==1 & ms11q02==1 & severe==1)
la var droughtshk "HH faced drought shock"

g byte floodshk = (inlist(ms11q01, 2)==1 & ms11q02==1 & severe==1)
la var floodshk "HH faced flood shock"

* Ag related shocks
g byte agshk = (inlist(ms11q01, 3, 4, 5, 6)==1  & ms11q02==1 & severe==1)
la var agshk "HH faced ag/livestock related shock"

* Food related shocks
g byte foodshk = (inlist(ms11q01, 7)==1  & ms11q02==1 & severe==1)
la var foodshk "HH faced high prices for food shock"

* Theft or conflict related shocks
g byte conflictshk = (inlist(ms11q01, 17, 18 )==1  & ms11q02==1 & severe==1)
la var conflictshk "HH faced theft or conflict  related shock"

* Death or sickness related shocks
g byte healthshk = (inlist(ms11q01, 13, 14, 15)==1  & ms11q02==1 & severe==1)
la var healthshk "HH faced health or death related shock"

g byte finshk = (inlist(ms11q01, 8, 9, 10, 11, 12, 16)==1  & ms11q02==1 & severe==1)
la var finshk "HH faced financial related shock"

* Standard shocks are price, hazard, health, and any
g byte hazard 	= inlist(ms11q01, 1, 2) & severe_affected
g byte price	= inlist(ms11q01, 5, 6, 7) & severe_affected
g byte ag		= inlist(ms11q01, 3, 4) & severe_affected
g byte health 	= inlist(ms11q01, 13, 14, 15) & severe_affected

la var hazard "hazard shock"
la var price "price shock"
la var ag "ag shock"
la var health "health shock"


* Queue up encoding of food variables
label copy ms11q04ecode food

* Did shocks affect ability to purchase food?
foreach x of varlist weather agshk foodshk finshk conflictshk healthshk {
	g `x'Food = ms11q04e if `x'==1
	la var `x'Food "HH food purchase action due to `x'"
	g byte `x'Cope = (ms11q05a==21 & `x'==1)
	la var `x'Cope "HH engaged in spiritual activities to cope with `x'"
}
*end

*What coping strategies did the household use to respond/mitigate the shock?
labellist ms11q05a

/* Focus in primary coping strategy first using the following categories:
Financial 	= 1, 13, 12
Aid			= 2, 3, 4
Consumption = 6
Work/Migrate= 7, 8, 9, 11, 10, 19 
Liquidate	= 14, 15, 16, 17, 18
Spiritual	= 21
no Coping	= 24
*/

g byte financialCope= ((inlist(ms11q05a, 1, 13, 12)==1 | (inlist(ms11q05b, 1, 13, 12)==1) | (inlist(ms11q05c, 1, 13, 12)==1)) & ms11q02==1 & severe==1)
g byte aidCope 		= ((inlist(ms11q05a, 2, 3, 4)==1 | (inlist(ms11q05b, 2, 3, 4)==1) | (inlist(ms11q05b, 2, 3, 4)==1)) & ms11q02==1 & severe==1)
g byte consumeCope	= ((inlist(ms11q05a, 6)==1 | (inlist(ms11q05b, 6)==1) | (inlist(ms11q05b, 6)==1)) & ms11q02==1 & severe==1)
g byte workCope		= ((inlist(ms11q05a, 7, 8, 9, 11, 10, 19)==1 | (inlist(ms11q05b, 7, 8, 9, 11, 10, 19)==1) | (inlist(ms11q05b, 7, 8, 9, 11, 10, 19)==1)) & ms11q02==1 & severe==1)
g byte liquidateCope= ((inlist(ms11q05a, 14, 15, 16, 17, 18)==1 | (inlist(ms11q05b, 14, 15, 16, 17, 18)==1) | (inlist(ms11q05b, 14, 15, 16, 17, 18)==1)) & ms11q02==1 & severe==1)
g byte spiritCope 	= ((inlist(ms11q05a, 21)==1 | (inlist(ms11q05b, 21)==1) | (inlist(ms11q05b, 21)==1)) & ms11q02==1 & severe==1)
g byte noCope 		= ((inlist(ms11q05a, 99)==1 ) & ms11q02==1 & severe==1)
* Look at results
sum *Cope

*Label variables
la var financialCope "Financial"
la var aidCope "Assistance/Aid"
la var consumeCope "Change consumption patterns"
la var workCope "Change work level/effort"
la var liquidateCope "Sell assets"
la var spiritCope "Pray or spiritual ritual"
la var noCope "No coping strategy"

*Create specific coping response for each shock (shock type X cope type)
local shock "weathershk agshk foodshk conflictshk healthshk finshk"
foreach x of varlist financialCope-noCope {
	foreach y of local shock {
		g byte `x'`y' = (`x'==1 & `y'==1)
		la var `x'`y' "`x' to `y'"
	}
}
*end	

/*See http://siteresources.worldbank.org/EXTNWDR2013/Resources/8258024-1352909193861/
* 8936935-1356011448215/8986901-1380568255405/WDR15_bp_What_are_the_Sources_of_Risk_Oviedo.pdf
for rationale. 
Finally, create good/bad coping strategies
Good consist of = financial, aid, work, spirit
Bad consist of = liquidate, consume */
g byte goodCope = (financialCope==1 | aidCope==1 | workCope==1 | spiritCope ==1)
g byte badCope = (liquidateCope==1 | consumeCope==1)
la var goodCope "Good coping strategy"
la var badCope "Bad coping strategy"

* what does overall shock coping strategies look like?
tab ms11q05a if anyshock==1 

* Collapse variables to HH level
ds(ms11* ms00* ), not
keep `r(varlist)'

ds(hid passage grappe menage), not

* Copy variable labels to reapply after collapse
include "$pathdo/copylabels.do"

* Collapse data down to HH level
#delimit ;
collapse (max) `r(varlist)'
	(mean) passage grappe menage, 
	by(hid) fast;
#delimit cr
order hid passage grappe menage

* Reapply variable lables
include "$pathdo/attachlabels.do"

* Attach value labels back to 1/2/3 data
foreach x of varlist weathershk agshk foodshk conflictshk finshk healthshk {
	la values `x'Food food
	}
*end

g byte onlyGood = (goodCope==1 & badCope==0)
g byte onlyBad = (badCope==1 & goodCope==0)

la var onlyGood "Only good coping strategies"
la var onlyBad "Only bad coping strategies"

sort hid

* Save dataset and remerge with kep question about shocks
save "$pathout/shocks.dta", replace

* Merge back with original HH data but keep only key variables needed for merge
local agrp hhagasset hhchar hhdur hhinfra hhnc hhpc transfers
local n: word count `agrp'
forvalues i = 1/`n'  {
	local a: word `i' of `agrp'
	display in yellow "Data set for `a'"
	merge 1:1 hid using "$pathout/`a'.dta"
	drop _merge
}
*

/* NOTE: 22 households did not merge in from shock dataset; Should find out why*/

* Summarize the shocks by different regions of Niger; Account for weights
tabstat anyshock weathershk agshk foodshk conflictshk healthshk [aw=hhweight] ///
if urbrur==2, by(region) stats(mean sd n) 

* Summarize coping strategies
local stat Cope 
foreach x in `stat' {
	tabstat weathershk`x' agshk`x' foodshk`x' conflictshk`x' healthshk`x' [aw=hhweight] ///
	if urbrur==2, by(region) stats(mean sd n) 
}
*
compress
log2html "$pathlog/shocks", replace
log close

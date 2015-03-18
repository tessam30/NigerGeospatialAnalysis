/*-------------------------------------------------------------------------------
# Name:		09_ShockAnalysis
# Purpose:	Create summary statistics, data checks, and run logistic regressions
# Author:	Tim Essam, Ph.D.
# Created:	17/04/2013
# Modified: 	07/23/2014
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	mat2txt, AdminTwoRecode.do, estout, winsor2
# Dependencies: Admin2.dta
#-------------------------------------------------------------------------------
*/
clear
capture log close
log using "$pathlog/PrelimAnalysis", replace

*Quietly run all previous do file to incorporate any changes made on the fly.
do "$pathdo/01_hhchar.do"
do "$pathdo/02_hhinfrastructure.do"
do "$pathdo/03_hhnatcap.do"
do "$pathdo/04_hhpc.do"
do "$pathdo/05_transfers.do"
do "$pathdo/06_shocks.do"
do "$pathdo/07_foodsecurity.do"
do "$pathdo/08_comservices.do"
set more off

* Check that fixed-effect geography file is included in dataout folder
* If not there, it must be created or downloaded from github (https://github.com/tessam30/NigerGeospatialAnalysis/tree/master/data)
cd "$pathout"
local required_file Admin2
foreach x of local required_file { 
	 capture findfile `x'.dta
		if _rc==601 {
			disp in red "Please install `x'.dta file or create _newline in ArcGIS/QGIS using spatial join commands"
			disp in red "Admin2 links geovariables to 2nd adminstrative zones (départements)"
			* Create an exit conditions based on whether or not file is found.
			if _rc==601 exit = 1
		}
		else disp in yellow "`x' currently installed and will be merged below in code (@120ish)."
	}
*end
cd "$path"


* Load data created in 08 do file from above
set more off
use "$pathout/hh_combined.dta", clear

* Merge in community characteristics & GIS variablees
merge m:1 grappe using "$pathout\comresilience.dta", gen(merge1)
merge m:1 grappe using "$pathout\comservices.dta", gen(merge2)
merge m:1 grappe using "$pathout\community.dta", gen(merge3)
merge 1:1 hid using "$pathin\NER_HouseholdGeovars_Y1.dta", gen(merge4)
merge 1:1 grappe menage using "$pathin\ECVMA2011_Welfare_en.dta", gen(welfareMerge)

* Remove any records not matching 
drop if merge2==1

* Create binary variable for agroecological zone
tab zae, gen(agzone)

* Winsorize transfers for analysis later on
winsor2 transfers transfersOut, replace cuts(1 99)

/* NOTES: Create a logged value of total land cultivated to be used in regressions
for households with 1 ha of land, adding 1 so logged value will not be 0. Adding
1 to household with 0 ha of land so they will not be changed to missing. */
extremes ownLandCult
winsor2 ownLandCult, replace cuts(1 99)
replace ownLandCult = ownLandCult + 1 if ownLandCult<=1
g lnownLandCult = ln(ownLandCult)
la var lnownLandCult "Logged value of cultivated land owned"

*Check the density of the two variables
sum ownLandCult lnownLandCult if ownLandCult ~=.

* Rename weather variables
ren af_bio_12 annualPrecip
ren af_bio_1 annualMeanTemp

* Set sampling weights for household
svyset grappe [pweight= hhweight], strata(strate) singleunit(centered)
recode urbrur (1=0)(2=1)
la define urban 0 "Urbain" 1 "Rural"
la values urbrur urban

* Summarize the survey set results
svydescribe

* Before looking at shocks, let's run some summary statistics on who/where shocks are located
svy: mean anyshock agshk finshk foodshk healthshk weathershk, over(urbrur region)
svy, subpop(urbrur): mean anyshock agshk finshk foodshk healthshk weathershk, over(urbrur region)

* Keep a matrix of results, select only mean and se
matrix A = r(table)
local dim = e(rank)
matrix B = (A[1, 1..`dim']\A[2, 1..`dim']\A[5, 1..`dim']\A[6, 1..`dim']\e(_N))'
mat2txt, matrix(B) saving("$pathxls/mytable") title(Table 1. Shock Summary) replace

* Repeat for second wave of variables
svy: mean malaria diarrhea grainstk conflict, over(urbrur region)
matrix A = r(table)
matrix B = A[1, 1..60]'
mat2txt, matrix(B) saving("$pathxls/mytable2") title(Table 1. Correlations) replace

* Create summary table for exogenous covariates (Descriptive stats table in paper) 
global exog1 "femHead marriedHead ageHead literateHead eduMuslimHead educHigh mobile hhSize sexRatio depRatio hhmixed"
global exog2 "$exog1 mlabor flabor under15Share landless lnownLandCult"
global exog3 "$exog2 infraindex wealth agwealth comservindex comhealthindex"
global exog4 "$exog3 dist_road dist_market annualMeanTemp annualPrecip"

* Execute summary command; Keep if observations are non-missing; Save stats in a matrix; Export matrix to .txt file
svy, subpop(urbrur): mean $exog4
g byte filter = 1 if e(sample)
matrix A = r(table)
local dim = e(rank)
matrix C = (A[1, 1..`dim']\A[2, 1..`dim']\A[5, 1..`dim']\A[6, 1..`dim']\e(_N))'
mat2txt, matrix(C) saving("$pathxls/mytable") title(Table 1. ExogenousVariables) replace

* Recode a few of the economic variables
recode hsitac12m (2=0)

/* -NOTE: Merge in Admin Two names which are used for geographic-fixed effects analysis
	These were created using ArcGIS spatial join command with the geovariables
	Ensure that this file is copied into the pathout folder
*/
merge m:1 hid grappe using "$pathout\Admin2.dta"

* Call do file to rename Admin2 names; 
do "$pathdo\AdminTwoRecode.do"

* Set exogenous variables for regression specifications
global exog1 "femHead marriedHead ageHead literateHead eduMuslimHead educHigh mobile hhSize sexRatio depRatio hhmixed"
global exog2 "$exog1 mlabor flabor under15Share lnownLandCult "
global exog3 "$exog2 infraindex wealth agwealth comservindex comhealthindex"
global exog4 "$exog3 dist_road dist_market annualMeanTemp annualPrecip"

* Set Mayahi as base location; Set Maradi as base location 
global location "ib(21).admin"
global location2 "i.zae ib(4).region"
global interact "i.femHead##i.region"

* Save coefficients and std. errs for R Graphs
/* NOTE: could not estimate anyshock b/c it is a perfect predictor for Ouallam; */
eststo clear
svy, subpop(urbrur): logit anyshock $exog4 $location
*outreg2 using "$pathreg/shocksFinal", bdec(3) br eform cti(odds ratio) label adds(Observations, e(N), Pop. size , e(N_pop)) replace
eststo: svy, subpop(urbrur): logit anyshock $exog4 $location
g byte regFilt = 1 if e(sample)

* Extract the coefficients and standard errors; (http://www.stata.com/statalist/archive/2009-04/msg00240.html)
matrix V = e(V)
* Take the sqrt in R to get the standard errors 
matrix Var = vecdiag(V)
matrix A = (e(b)\Var)'
mat2txt, matrix(A) saving("$pathRin/Anyshock") replace

* Create a variable to ensure that correct observations are exported to R/ArcGIS
predict tag if e(sample)

/*NOTE: Cannot use admin2 dummies b/c of multicollinearity, use higher level fixed-effect. 
  Use estout commands as they are easier to manipulate with multiple regressions */
eststo: svy, subpop(urbrur): logit agshk $exog4 $location2
eststo: svy, subpop(urbrur): logit foodshk $exog4 $location2
eststo: svy, subpop(urbrur): logit weathershk $exog4 $location2
eststo: svy, subpop(urbrur): logit healthshk $exog4 $location2
eststo: svy, subpop(urbrur): logit finshk $exog4 $location2

esttab, se star(* 0.10 ** 0.05 *** 0.01) label 
esttab using "$pathRin/OtherShocks.txt", replace wide plain se mlabels(none) 

local star "star(* 0.10 ** 0.05 *** 0.01) se b(4) se(2) "
esttab using "$pathreg/OtherShocks.rtf", replace label nogap `star'

* Make a table to summarize geograhpic effects alone
eststo clear
eststo: svy, subpop(urbrur): logit anyshock $exog4 $location 
esttab, label cells("b(star fmt(3)) se b") 
esttab using "$pathRin/geo_fixed_effects.txt", replace wide plain se mlabels(none) baselevels 

eststo clear
eststo: svy, subpop(urbrur): logit floodshk $exog4 $location2
eststo: svy, subpop(urbrur): logit droughtshk $exog4 $location2
esttab, se star(* 0.10 ** 0.05 *** 0.01) label 
esttab using "$pathRin/WeatherShocks.txt", replace wide plain se mlabels(none) 

* Export cut of data for use in R spatial regression models
export 
export delimited using "$pathout\R_spatreg.csv" if regFilt==1, replace

* Estimate the nubmer of female headed households in rural areas (2011 pop estimate, 82% rural)
* svmat - creates variables from a matrix
g popsize2011R = 16468890*.82
svy, subpop(urbrur): mean femHead
matrix m= e(b)
matrix se = e(V)
svmat m, names(fh)
svmat se, names(se)
replace se1 = sqrt(se1)

g femHeadPopLB = popsize2011R*(fh1-se1)
g femHeadPopUB = popsize2011R*(fh1+se1)
sum femHeadPop*

/* NOTES: Run SpatReg.R to generate output from Spatial Regressions; Then, run
ShockGraphs to create forest plots from point estimates and standard errors.
* Located at: "..nigerlsms/r/NigerLogitGraphs.R" and 




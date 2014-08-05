/*-------------------------------------------------------------------------------
# Name:		08_comservices
# Purpose:	Process community level data and create service provision indicators
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
log using "$pathlog/comservices", replace
set more off

* Load in transfers module data *
use "$pathin/ecvmacoms01_p1_en.dta"

/* Notes: Data are presented as 1 entry, per service, per cluster (270 total)*/
*Decode comm. service types for ease of coding
decode cs01q00, gen(infratype)
bys infratype: g labinfra = _n
sort cs01q00
clist cs01q00 infratype if labinfra==1, nol noo

/* Community services available to households - Decoded below --
-----------------------------------------------------------------
                         1                       Public preschool
                         2                      Private preschool
                         3                  Public primary school
                         4                 Private primary school
                         5         Public secondary establishment
                         6        Private secondary establishment
                         7                         Literacy agent
                         8                      District hospital
                         9               Integrated Health Center
                        10                                 Clinic
                        11                            Health Post
                        12      Ambulance for the health facility
                        13        Pharmacy or medicine wharehouse
                        14                            Post office
                        15                       Permanent market
                        16                        Periodic market
                        17          bank/microfinance institution
                        18                            Bus station
                        19        Point to provide drinking water
                        20           Agriculture Extension Center
                        21                            Cereal Bank
                        22                Food stores for animals
                        23                     Civil state center
                        24                           Asphalt road
                        25                         laterite roads
                        26                             Rural path
                        27  Social center(protection of children)
                        28                        Community radio
-----------------------------------------------------------------*/

*Check status of all comm. services across categories 
table infratype cs01q01

* Remove special characters so we can use labels as variable name
replace infratype = subinstr(infratype, " ", "", .)
replace infratype = subinstr(infratype, "(", "", .)
replace infratype = subinstr(infratype, ")", "", .)
replace infratype = subinstr(infratype, "/", "", .)

preserve
*Keep select community services and export to R to conduct data science analysis
keep if cs01q01 == 1
keep grappe infratype
export delimited using "$pathRin\NigerComServices.csv", replace
restore

* Reshape the data so we can conduct a factor analysis and create an index
set more off
levelsof(infratype), local(levels)
encode infratype, gen(infracode)
local i = 1
foreach x of local levels {
	g byte `x' = (cs01q01 == 1) if infracode  ==`i'
	local i =`i' + 1
}
*end

* Collapse data in wide format to be merged with household data
collapse (max) AgricultureExtensionCenter-lateriteroads, by(grappe)
* Reapply variable lables

/* Conduct a principal components analysis to develop a community
service indicator; Will provide a sense of what communities are well
served by local government. */
foreach x of varlist _all{
	replace `x'=0 if `x'==.
}
*end

* Keep only variables relevant to factor analysis
ds(grappe Socialcenterprotectionofchildren), not

* Use polychoric correlation matrix b/c of binaries
polychoric `r(varlist)'
matrix C = r(R)
global N = r(N)
factormat C, n($N) pcf factor(2) forcepsd 

/* NOTE: the resulting polychoric correlation matrix is not PSD so we force it */
rotate, varimax
greigen
predict comservindex 
la var comservindex "Community service index"
order bankmicrofinanceinstitution Privateprimaryschool
alpha AgricultureExtensionCenter-lateriteroads

save "$pathout/comservices.dta", replace
export delimited using "$pathRin/comservices.csv", replace
clear


/* --------------------------------
	Module 2: Community resilience 
-----------------------------------*/

* Open 2nd community module and extract useful community characteristics
use "$pathin\ecvmacoms02_p1_en.dta", clear

/* NOTE: Data is in wide format already, no need to reshape */

/* Tab through major variables
foreach x of varlist cs02q01a- cs05q19c {
	tab `x', mi
	}
*/
*end

* Extract relevant community variables
ren cs02q01a econActivity
g byte electricCon = inlist(cs02q05, 1)
la var electricCon "Village has electrical connection"

g byte transport = inlist(cs02q13, 1)
la var transport "Transportation passed through village"

g byte access = inlist(cs02q04a, 1)
la var access "Access route to village not passable during rainy season"

g byte tapwater = inlist(cs02q07, 1)
la var tapwater "tap water used in village"

g byte  malariaCom = inlist(cs03q05a, 1)
la var malariaCom "Malaria is common in community"

g byte tradFarmAssist = inlist(cs04q19, 1)
la var tradFarmAssist "Traditional farmer assistance program in community"

g milletseason =  cs04q21-cs04q20
la var milletseason "Length of millet growing season"

g byte pasture = inlist(cs05q07, 3)
la var pasture "Livestock do not have enough pasture in last 12 months"

g byte animal = inlist(cs05q11, 1)
la var animal "Community had epidemic attack on animals in last 5 years"

g byte insect = inlist(cs05q12, 1)
la var insect "Community had insect attack harvests during last 5 years"

g byte drought = inlist(cs05q17, 1)
la var drought "Community faced serious drought during last 5 years"

g byte flood = inlist(cs05q18, 1)
la var flood "Community faced serious floods during last 5 years"

* Keep relevant variables for saving
ds(cs*), not
keep `r(varlist)'

* Clean up existing data for mappping/analysis in R
local fixvar econActivity transport 
foreach x of local fixvar {
	replace `x' =. if `x'==9
}
*end

save "$pathout/comresilience.csv", replace
save "$pathout/comresilience.dta", replace

/*------------------------------------
	Module 3: Community Health Quality 
--------------------------------------*/
* Add-in in medical information
use "$pathin/ecvmacoms03_p1_en", clear

preserve
keep if cs03q02==1
keep cs03q00 grappe
export delimited using "$pathRin\NigerComHealth.csv", replace
restore

set more off
decode cs03q00, gen(healthtype)
replace healthtype = subinstr(healthtype, " ", "", .)
replace healthtype = subinstr(healthtype, "(", "", .)
replace healthtype = subinstr(healthtype, ")", "", .)

levelsof(healthtype), local(levels)
encode healthtype, gen(healthcode)
local i = 1
foreach x of local levels {
	g byte `x' = (cs03q02 == 1) if healthcode  ==`i'
	local i =`i' + 1
}
*end

* Copy variable labels to reapply after collapse
include "$pathdo/copylabels.do"

* Collapse the data to get health services available to community
collapse (max) Certifiednurse-healthtechnician, by(grappe)

* Reapply variable lables
include "$pathdo/attachlabels.do"

* Reapply variable lables
* Use polychoric correlation matrix b/c of binaries
ds(grappe Nursewithstatediploma), not
polychoric `r(varlist)'
matrix C = r(R)
global N = r(N)
factormat C, n($N) pcf factor(2) forcepsd 

/* NOTE: the resulting polychoric correlation matrix is not PSD so we force it */
rotate, varimax
greigen
predict comhealthindex 
la var comhealthindex "Community service index"
order Nursewithstatediploma
alpha Certifiednurse-healthtechnician

save "$pathout/comHealthQuality.csv", replace
merge 1:1 grappe using  "$pathout/comservices", gen(commerge)
drop commerge
merge 1:1 grappe using "$pathout/comresilience"
drop _merge
order passage region milieu s0q0 id grappe

save "$pathout/community.dta", replace

/*------------------------------------
	Module 3: Community Infrastructure 
--------------------------------------*/

* Load in infrastructure improvement module
use "$pathin/ecvmacoms06_p1_en.dta", clear

/* NOTE: Nothing to do basket analysis on, not enough variation */

set more off
decode cs06q00, gen(itype)

* Replace long strings so we can use them as variable names
replace itype = regexr(itype, "construction", "_C")
replace itype = regexr(itype, "Maintenance or repair", "_MR")
replace itype = regexr(itype, "maintenance or repair", "_MR")
replace itype = regexr(itype, "maintenance", "_M")
replace itype = regexr(itype, "Public transportation", "PubTransit")
replace itype = regexr(itype, "Agriculture/Fishing/Livestock", "AgFishLvstck")
replace itype = regexr(itype, "extension services", "ExtSrvcs")


* Remove list of missing characters
replace itype = subinstr(itype, " ", "", .)
replace itype = subinstr(itype, "(", "", .)
replace itype = subinstr(itype, ")", "", .)
replace itype = subinstr(itype, ":", "", .)
replace itype = subinstr(itype, "/", "", .)
replace itype = subinstr(itype, ",", "", .)

* Iterate over each type of infrastructure and create binary
levelsof(itype), local(levels)
encode itype, gen(icode)
local i = 1
foreach x of local levels {
	g byte `x' = (cs06q01 == 1) if icode  ==`i'
	local i =`i' + 1
}
*end


* Export to R for preliminary descriptive analysis
preserve
keep if cs06q01 == 1
keep grappe itype
export delimited using "$pathRin/community.csv", replace
restore

* Copy variable labels to reapply after collapse
include "$pathdo/copylabels.do"

* Collapse into useable dataset to be merged w/ HH data
ds(itype icode), not
keep `r(varlist)'

* Copy variable labels to reapply after collapse
include "$pathdo/copylabels.do"

collapse (max) AgFishLvstckExtSrvcs- Secondaryeducationcenter_MR, by(grappe)

* Reapply variable lables
include "$pathdo/attachlabels.do"


* Save data
save "$pathout/communityMaint.dta", replace

* Merge with other datasets created at community level
merge 1:1 grappe using "$pathout/community.dta", gen(merge)
if `r(N)' == 0 {
	drop merge
	}
	else disp in yellow "Merge not fully matched"
*end

* Clean up variable labels
foreach var of varlist bankmicrofinanceinstitution-lateriteroads {
	loc oldlab: var lab `var'
	local newlab = subinstr("`oldlab'", "(max)", "", .)
	lab var `var' "`newlab'" 
}
*end

* Re-order data for analysis and graphics
order passage grappe region milieu s0q0 id

* Merge in geo-variables
merge 1:1 grappe using "$pathin/NER_EA_Offsets.dta", gen(merge)
if `r(N)' == 0 {
	drop merge
	}
else disp in yellow "`r(N)' case(s) not fully matched"

* Save final dataset
save "$pathout/community.dta", replace

*drop missing values o/wise statistic will not be calculated
drop if comservindex==.

* Consider spatial correlation analysis on the indices
* First: Calculate the spatial weighting matrix.
spatwmat, name(LSMSweights) xcoord(LON_DD_MOD) ycoord(LAT_DD_MOD) band(0 100) standardize

* Second: Calculate the Moran's I for indices & Geary's C
/* NOTES: Geary's C lies between 0 and 2. 1 means no spatial autocorrelation. 
Values lower than 1 demonstrate increasing positive spatial autocorrelation, whilst 
values higher than 1 illustrate increasing negative spatial autocorrelation.

MORANS I:  Values range from -1 (indicating perfect dispersion) to +1 (perfect correlation) */

spatgsa comservindex, weights(LSMSweights) moran
spatgsa comservindex, weights(LSMSweights) geary

spatgsa comhealthindex, weights(LSMSweights) moran
spatgsa comhealthindex, weights(LSMSweights) geary


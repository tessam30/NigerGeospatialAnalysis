/*-------------------------------------------------------------------------------
# Name:		04_hhpc
# Purpose:	Process household data and create physical capital variables
# Author:	Tim Essam, Ph.D.
# Created:	11/15/2013
# Modified: 	07/23/2014
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ados:		copylabels.do; attachlabels.do	
# Dependencies: 
#-------------------------------------------------------------------------------*/

clear
capture log close
log using "$pathlog/physcapital", replace
set more off

* Load in ag module data *
use "$pathin/ecvmaactif_p1_en.dta"
sort hid

/* Create durable asset variables:
Furniture, sewing, stove, refrig, conditioner, fan, radiocassette, gascooker
generatator, video, washer, tv, camera, ironelec, bicycle, motorcycle, car, house,
stove, h20trans, outboardmotor, mattress */

* Furniture: armchair, living room set, chair, table, dining table & chairs, 
bys hid: gen furniture = (inlist(ms07q01, 141, 142, 143, 144, 145)==1 & ms07q02==1)
la var furniture "hh owns furniture"

* bed
bys hid: gen bed = (inlist(ms07q01, 146, 147, 148)==1 &  ms07q02==1)
la var bed "hh owns some type of mattress"

* Iron
bys hid: gen iron = (inlist(ms07q01, 150)==1 &  ms07q02==1)
la var iron "hh owns iron"

* Stove
bys hid: gen stove = (inlist(ms07q01, 151, 152)==1 &  ms07q02==1)
la var stove "hh owns gas/oil stove"

* Sewing machine
bys hid: gen sew = (inlist(ms07q01, 153)==1 &  ms07q02==1)
la var sew "hh owns sewing machine"

* Gas cooker
bys hid: gen gascooker = (inlist(ms07q01, 155, 156)==1 &  ms07q02==1)
la var gascooker "hh owns gas cooker"

* refrig
bys hid: gen refrig = (inlist(ms07q01, 157)==1 &  ms07q02==1)
la var refrig "hh owns regrigerator"

* fan
bys hid: gen fan = (inlist(ms07q01, 158)==1 &  ms07q02==1)
la var fan "hh owns fan"

* air conditioner
bys hid: gen conditioner = (inlist(ms07q01, 159)==1 &  ms07q02==1)
la var conditioner "hh owns air conditioner"

* radio
bys hid: gen radio = (inlist(ms07q01, 160)==1 &  ms07q02==1)
la var radio "hh owns  radio"

* tv
bys hid: gen tv = (inlist(ms07q01, 161)==1 &  ms07q02==1)
la var tv "hh owns tv"

* dvd or cd
bys hid: gen dvd  = (inlist(ms07q01, 162)==1 &  ms07q02==1)
la var dvd "hh owns cd/dvd/tape player"

* antenna
bys hid: gen antenna  = (inlist(ms07q01, 163)==1 &  ms07q02==1)
la var antenna "hh owns tv antenna"

* car
bys hid: gen car  = (inlist(ms07q01, 164)==1 &  ms07q02==1)
la var car "hh owns car"

* moped
bys hid: gen moped  = (inlist(ms07q01, 165)==1 &  ms07q02==1)
la var moped "hh owns moped"

* bicycle
bys hid: gen bicycle  = (inlist(ms07q01, 166)==1 &  ms07q02==1)
la var bicycle "hh owns bicycle"

* camera
bys hid: gen camera  = (inlist(ms07q01, 167)==1 &  ms07q02==1)
la var camera "hh owns camera"

* phone
bys hid: gen phone  = (inlist(ms07q01, 169, 170)==1 &  ms07q02==1)
la var phone "hh owns phone"

* computer
bys hid: gen computer  = (inlist(ms07q01, 171)==1 &  ms07q02==1)
la var computer "hh owns computer"

* videocam
bys hid: gen videocam  = (inlist(ms07q01, 172)==1 &  ms07q02==1)
la var videocam "hh owns videocam"

* videocam
bys hid: gen generator  = (inlist(ms07q01, 173)==1 &  ms07q02==1)
la var generator "hh owns generator"

* wheelbarrow
bys hid: gen wheelbarrow  = (inlist(ms07q01, 174)==1 &  ms07q02==1)
la var wheelbarrow "hh owns wheelbarrow"

sort hid
egen hhdurval = total(ms07q06) if ms07q06!=99999999, by(hid ms07q01)
sum hhdurval, d
la var hhdurval "Total value of durables"

* Collapse the data and sum totals, keeping max for assets and totals
ds(ms0*), not
keep `r(varlist)'

* Copy variable labels to reapply after collapse
include "$pathdo/copylabels.do"

* Collapse data down to HH level
#delimit ;
collapse (mean)  passage grappe menage
	(max) furniture-wheelbarrow 
	(sum) hhdurval, 
	by(hid) fast;
#delimit cr

* Reapply variable lables and save a copy
include "$pathdo/attachlabels.do"

sort hid
save "$pathout/hhdur.dta", replace


/* -----------------------------------------------
 # Create AGRICULTURAL ASSET VARIABLES AND VALUE #
--------------------------------------------------*/

* Create ag assets varaibles (From 2nd visit)
use "$pathin/ecvmaas06_p2_en.dta", clear
sort hid
mvencode as06q04, mv(0) override

/* hoe, machete, shovel, pick, hilaire, axe, plow, cart, tractor, yoke, seeder
sprayer, poudreuse, water, pump, thresher, storage, pens, shed, generator, dryshed,
sheller, baler, silos */ 

g handtool= as06q04 if inlist(as06q02, 1, 2, 3, 4, 5, 6, 7)==1 & as06q03==1
g plow = 	as06q04 if inlist(as06q02, 8)==1 & as06q03==1
g cart = 	as06q04 if inlist(as06q02, 9)==1 & as06q03==1
g tractor = as06q04 if inlist(as06q02, 10)==1 & as06q03==1
g yoke = 	as06q04 if inlist(as06q02, 11)==1 & as06q03==1
g seeder = 	as06q04 if inlist(as06q02, 12)==1 & as06q03==1
g sprayer = as06q04 if inlist(as06q02, 13)==1 & as06q03==1
g watering = as06q04 if inlist(as06q02, 15)==1 & as06q03==1
g motorpump = as06q04 if inlist(as06q02, 16)==1 & as06q03==1
g thresher = as06q04 if inlist(as06q02, 17)==1 & as06q03==1
g storage = as06q04 if inlist(as06q02, 18)==1 & as06q03==1
g chxpen = as06q04 if inlist(as06q02, 19)==1 & as06q03==1
g shed = 	as06q04 if inlist(as06q02, 20)==1 & as06q03==1
g generator = as06q04 if inlist(as06q02, 21)==1 & as06q03==1
g dryshed = as06q04 if inlist(as06q02, 22)==1 & as06q03==1
g sheller = as06q04 if inlist(as06q02, 23)==1 & as06q03==1
g baler = 	as06q04 if inlist(as06q02, 24)==1 & as06q03==1
g silo = 	as06q04 if inlist(as06q02, 25)==1 & as06q03==1

*Apply lables to variables
foreach name of varlist handtool-silo {
	la var `name' "No. `name's owned by hh"
	by hid: egen n`name' = total(`name')
	la var n`name' "Total `name's owned by hh"
}
*end

* Calculate the median value of each asset group
* For example: for tractors, take the median value of all tractors listed
* Then multiply that number by the number of tractors owned by a hh 
egen munitprice = median(as06q05), by(as06q02)
la var munitprice "Median price of asset"

* Calculate the total value of all ag assets
egen hhagasset = total(as06q04*munitprice), by(hid)
la var hhagasset "Total value of all ag assets"
replace hhagasset = . if hhagasset ==0

* Collapse
ds (as0* ms0*), not
keep `r(varlist)'

* Copy variable labels to reapply after collapse
include "$pathdo/copylabels.do"

* Collapse data down to HH level
ds(hid munitprice), not
#delimit ;
	collapse (mean)	`r(varlist)',
	by(hid) fast;
#delimit cr

* Reapply variable lables and save a copy
include "$pathdo/attachlabels.do"
drop handtool- silo
sort hid

save "$pathout/hhagasset.dta", replace

/* -----------------------------------------------
 # Create LIVESTOCK ASSETS VARIABLES AND VALUE #
--------------------------------------------------*/

* Create livestock assets varaibles (From 2nd visit)
use "$pathin/ecvmaas4a_p2_en.dta", clear
sort hid

*Number of animals
g ox = 	as4aq04 == 111
g bull = 	as4aq04 == 121
g cowt = 	as4aq04 == 131
g ycow = 	as4aq04 == 141
g heifer = 	as4aq04 == 151
g calf = 	as4aq04 == 161
g sheep = 	as4aq04 == 211
g ewe = 	as4aq04 == 221
g bgoat = 	as4aq04 == 231
g fgoat	= 	as4aq04 == 241 
g mcamel = 	as4aq04 == 311
g fcamel = 	as4aq04 == 321
g ycame = 	as4aq04 == 331
g donkey = 	as4aq04 == 411
g horse = 	as4aq04 == 511
g bird =	as4aq04 == 711 |  811 | 911

* Row sum the total number of animals owned
egen tmp = rsum(as4aq11)

* Create a total of animals owned by hh
/* --- NOTE: Not accounting for the animals placed in other hh ---*/
foreach x of varlist ox-bird {
	qui egen `x'Tot = total(tmp) if `x'==1, by(hid)
	qui replace `x'Tot = 0 if `x'Tot==.
	la var `x'Tot "Total `x's owned by hh"
	drop `x'
}
*end

* Generate unit price of sales
replace as4aq55=. if as4aq55==0
g unitprice = as4aq55/as4aq51
la var unitprice "Unit price of animal"

* Create median value of each animal across Niger 
egen medvalanim = median(unitprice), by(as4aq04)
bysort as4aq04: g valanim = as4aq11 * medvalanim 
la var valanim "Value of animal"

*Calculate hh-level total
egen tvalanim = total(valanim), by(hid)
la var tvalanim "Total value of animals"

* Stolen livestock
g byte stolenLS = as4aq48>0 & as4aq48!=. & inlist(as4aq04, 911, 811, 711)!=1
la var stolenLS "Had at least one large animal stolen"

* Livestock died from disease
g byte diseasedLS = as4aq50>0 & as4aq50~=. & inlist(as4aq04, 911, 811, 711)!=1
la var diseasedLS "Had at least one large animal die from disease"

* Collapse data down to hh level taking totals of animals and value
ds(ms0* as4*), not
keep `r(varlist)'

* Copy variable labels to reapply after collapse
include "$pathdo/copylabels.do"

#delimit ;
	collapse (mean) passage grappe menage tvalanim
	(max) oxTot-birdTot stolenLS diseasedLS
	,
	by(hid) fast;
#delimit cr

* Reapply variable lables and save a copy
include "$pathdo/attachlabels.do"

* Save a copy of dataset
save "$pathout/hhpcLivestock.dta", replace

* Now merge datasets together, bring in weights and calculate indices
merge 1:1 hid using "$pathout/hhagasset.dta", gen(lv2Agassets)
merge 1:1 hid using "$pathout/hhdur.dta", gen(ag2dur)
merge 1:1 hid using "$pathout/hhinfra.dta", gen(assets2infra)
merge 1:1 hid using "$pathout/hhnc.dta", gen(all)

* Create wealth indices from hh and ag assets to complement infra index
* First check to see what vars are missing (hhagassets has some missing info)
mdesc


*end
* Run a polychoric correlation b/c variables are binary in nature;
* Had to iterate through variables a bit to find all positivie eigenvalues

global wealth "furniture iron gascooker radio tv dvd moped bicycle phone generator"
set more off
polychoric  $wealth [aweight=hhweight]
matrix C =r(R)
matrix symeigen eigenvectors eigenvalues = C
matrix list eigenvalues
global N = r(N)
factormat C, n($N) pcf factor(2)
predict wealth

* Check Cronbach's alpha for Scale reliability coefficent higher than 0.50
alpha $wealth 

* Reasonable reliability but not great!
la var wealth "Durable wealth for rural HH"

/* ## NOTE: No need to do this b/c factormat cannot handle if statements; ##
Just make one factor prediction.

Repeat the same process for urban wealth and overall
tetrachoric  $wealth if urbrur==1, notable posdef
matrix C =r(corr)
matrix symeigen eigenvectors eigenvalues = C
matrix list eigenvalues
global N = r(N)
factormat C, n($N) pcf factor(1)
predict wealth_urb if urbrur==1
alpha $wealth if urbrur==1
la var wealth_urb "Durable wealth for urban HH"

* Again, same process for overall wealth
tetrachoric  $wealth, notable posdef
matrix C =r(corr)
matrix symeigen eigenvectors eigenvalues = C
matrix list eigenvalues
global N = r(N)
factormat C, n($N) pcf factor(1)
predict wealth_ntl 
alpha $wealth
la var wealth_ntl "Durable wealth for all HH"

*Check all three distributions
twoway (kdensity wealth) (kdensity wealth_urb ) (kdensity wealth_ntl)
*/

* Ag assets index (rural, urban, all)
* First summarize animals
sum  oxTot- birdTot
sum nhandtool- nsilo

* check for extreme values before running factor analysis
* Household ID 3119 has extremely large values, omit for analysis for now.
foreach x of varlist oxTot-birdTot nhandtool- nsilo {
	extremes `x', n(5)
	display in yellow "Outlier summary for `x'"
}
drop if hid==19810
*end

*

* RE: ag assets, only handtools, carts, storage, chxpen, shed to be used
* Can use normal factor anlaysis  b/c variables are continuous and are counts
factor oxTot-birdTot nhandtool ncart nstorage nchxpen nshed [aw=hhweight] if urbrur==2, pcf fac(2)

* Rotate factors
rotate, varimax

* Plot results
greigen
predict agwealth if urbrur==2
la var agwealth "Agricultural wealth index for rural HH"
alpha oxTot-birdTot nhandtool ncart nstorage nchxpen nshed if urbrur==2

* Makes little sense to calculate this for urban areas; so jump to national index
factor oxTot-birdTot nhandtool ncart nstorage nchxpen nshed [aw=hhweight], pcf fac(2)

* Rotate factors
rotate, varimax

* Plot results
greigen
predict agwealth_ntl
la var agwealth_ntl "Agricultural wealth for all HH"
alpha oxTot-birdTot nhandtool ncart nstorage nchxpen nshed

twoway (kdensity agwealth_ntl) (kdensity agwealth)

* Create TLU (based on values from http://www.fao.org/wairdocs/ilri/x5443e/x5443e04.htm)
/* Notes: Sheep includes sheep and goats
Horse includes all draught animals (donkey, horse, bullock)
chxTLU includes all small animals (chicken, fowl, etc).
*/

g camelVal = 1.0
g cattleVal = 0.70
g sheepVal = 0.10
g horsesVal = 0.80
g mulesVal = 0.70
g assesVal = 0.50
g chxVal = 0.01

* Generate TLU values now
g TLUcamel = (mcamelTot + fcamelTot + ycameTot) * camelVal
la var TLUcamel "Tropical Livestock Units: camels"

g TLUcattle = (cowtTot + ycowTot + heiferTot + calfTot) * cattleVal
la var TLUcattle "Tropical Livestock Units: cattle"

g TLUsheep = (sheepTot + eweTot + bgoatTot + fgoatTot) * sheepVal
la var TLUsheep "Tropical Livestock Units: sheep"

g TLUhorses = (oxTot + bullTot + horseTot) * horsesVal
la var TLUhorses "Tropical Livestock Units: horses"

g TLUmules = donkeyTot * mulesVal
la var TLUmules "Tropical Livestock Units: mules"

g TLUchx = birdTot * chxVal
la var TLUchx "Tropical Livestock Units: small animals"

egen totalTLU = rsum( TLUcamel TLUcattle TLUsheep TLUhorses TLUmules TLUchx)
la var totalTLU "Total TLU of animals"
sum totalTLU

*Drop conversion factors
drop TLU*

*Create cattle variables 
g cattle = (cowtTot + ycowTot + heiferTot + calfTot)

replace totalTLU=0 if totalTLU==.

* Does HH own any livestock?
g livesth=totalTLU>0 & totalTLU~=.
la var livesth "HH owns some livestock"

replace cattle = 0 if cattle==.
tabstat livesth totalTLU cattle  [aw=hhweight]

* Check TLU quintiles
xtile TLU_quintile = totalTLU [aw=hhweight], n(5)
sort TLU_quintile
sum totalTLU [aw=hhweight] if TLU_quintile==5

* Generate cumulative distribution of livestock holders
cumul totalTLU if totalTLU>0 & totalTLU!=. [aw=hhweight], gen(cumtlu)
la var cumtlu "Cumulative distribution of livestock holdings"

* Save combined datasets
notes: Combined dataset of hh durables, ag assets, and livestock
compress
save "$pathout/hhpc.dta", replace

log2html "$pathlog/physcapital", replace

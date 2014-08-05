/*-------------------------------------------------------------------------------
# Name:		05_transfers
# Purpose:	Process household data and create transfer variables
# Author:	Tim Essam, Ph.D.
# Created:	11/15/2013
# Modified: 	07/23/2014
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	extremes, copylabels.do; attachlabels.do
# Dependencies: 
#-------------------------------------------------------------------------------*/

clear
capture log close
log using "$pathlog/transfers", replace
set more off

* Load in transfers module data *
use "$pathin/ecvmatrecus_p1_en.dta"
sort hid

* Calculate total transfers recieved by hh
egen transfers = total(ms10aq07), by(hid)
la var transfers "HH total value of transfers"

egen money = total(ms10aq07) if ms10aq04==1, by(hid)
egen food = total(ms10aq07) if ms10aq04==2, by(hid)
egen other = total(ms10aq07) if ms10aq04==3, by(hid)

* Calculate and label types of transfers
foreach x of varlist money food other {
	egen `x'Trans = max(`x'), by(hid)
	replace `x'Trans=0 if `x'Trans==.
	drop `x'
	extremes `x'Trans, n(10)
}
* end
la var moneyTrans "HH total money transfers received"
la var foodTrans "HH total food transfers received"
la var otherTrans "HH other non-food transfers received"

* Collapse data down to HH level
ds(ms*), not
keep `r(varlist)'

* Copy variable labels to reapply after collapse
include "$pathdo/copylabels.do"

* Collapse data down to HH level
#delimit ;
collapse (max) transfers moneyTrans foodTrans otherTrans
	(mean) passage grappe menage, by(hid) fast;
#delimit cr

* Reapply variable lables
include "$pathdo/attachlabels.do"
save "$pathout/transIn.dta", replace

/* Calculate Transfers out */
clear
capture log close
log using "$pathlog/transfers.log", replace
set more off

* Load in transfers module data *
use "$pathin/ecvmatemis_p1_en.dta"
sort hid

* Calculate total transfers recieved by hh
egen transfersOut = total(ms10aq14), by(hid)
la var transfersOut "HH total value of transfers out"

egen money = total(ms10aq14) if ms10aq11==1, by(hid)
egen food = total(ms10aq14) if ms10aq11==2, by(hid)
egen other = total(ms10aq14) if ms10aq11==3, by(hid)

* Calculate and label types of transfers
foreach x of varlist money food other {
	egen `x'TransOut = max(`x'), by(hid)
	replace `x'TransOut=0 if `x'TransOut==.
	drop `x'
	extremes `x'TransOut, n(10)
}
* end

la var moneyTrans "HH total money transfers sent"
la var foodTrans "HH total food transfers sent"
la var otherTrans "HH other non-food transfers sent"

* Collapse data down to HH level
ds(ms*), not
keep `r(varlist)'

* Copy variable labels to reapply after collapse
include "$pathdo/copylabels.do"

* Collapse data down to HH level
#delimit ;
collapse (max) transfersOut moneyTransOut foodTransOut otherTransOut
	(mean) passage grappe menage, by(hid) fast;
#delimit cr

* Reapply variable lables
include "$pathdo/attachlabels.do"
save "$pathout/transOut.dta", replace

* Merge with ECVMAMEN module data to get HH info on transfers
use "$pathin/ecvmamen_p1_en.dta", clear
global keeplist "hid passage grappe menage region urbrur zae strate hhweight hhsize ms10q01 ms10q01a ms10q08 ms10q08a"
keep $keeplist

ren ms10q01 transferRcvd
ren ms10q08 transferSent
ren ms10q01a numTransfers
ren ms10q08a numTransferSent
recode numTransferSent numTransfers (.=0)

* Merge the two datasets with hh base data
merge 1:1 hid using "$pathout/transOut.dta", gen(mergeTransout)
merge 1:1 hid using "$pathout/transIn.dta", gen(mergeTransin)

* label variables
la var transferSent "During last 12 months, did house sent tranfers"
recode transferRcvd transferSent (2=0)
label define non 0 "non" 
la values transferSent non 
la values transferRcvd non

* clean up 
drop mergeTransout mergeTransin

* Take logarithm of transfers to get normally distributed variable
g lnTransfer=ln(transfers)
g lnTransfersOut = ln(transfersOut)
twoway (kdensity lnTransfer) (kdensity lnTransfersOut)

* Generate a binary for food transfers
g byte transferFood = (foodTrans>0 & foodTrans!=. )
g byte transferFoodOut = (foodTransOut>0 & foodTransOut!=.)

* label new variables
la var lnTransfer "HH total value of transfers logged"
la var lnTransfersOut "HH total value of transfers out logged"
la var transferFood "HH recived food transfer during last 12 mo"
la var transferFoodOut "HH gave food transfer during last 12 mo"

* All HH
tabstat transferRcvd transferSent transferFood  transferFoodOut [aw=hhweight], by(region) stats(mean sd n) 

* Only Rural HH
tabstat transferRcvd transferSent transferFood  transferFoodOut [aw=hhweight] ///
if urbrur==2, by(region) stats(mean sd n) 

tabstat lnTransfer lnTransfersOut [aw=hhweight] ///
if urbrur==2, by(region) stats(mean sd n) 
* In Maradi, rural areas, nearly 30% of hh get food transfers

compress
save "$pathout/transfers.dta", replace

log2html "$pathlog/transfers", replace

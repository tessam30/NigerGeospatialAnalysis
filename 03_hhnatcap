/*-------------------------------------------------------------------------------
# Name:		03_hhnatcap
# Purpose:	Process household data and create natural capital variables
# Author:	Tim Essam, Ph.D.
# Created:	15/11/2013
# Modified: 	07/23/2014
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	log2html
# Dependencies: copylabels.do; attachlabels.do, 00_SetupFoldersGlobals.do
#-------------------------------------------------------------------------------
*/
clear
capture log close
log using "$pathlog/natcapital", replace

* Load in ag module data *
use "$pathin/ecvmaas1_p1_en.dta"

/* - Creates natural capital variables for Niger */
* Calculate land that is owned, first at the field level, then hh *
g owntagt = (as01q16==1)
egen ownLand = total(as01q09) if as01q09!=999999 & owntagt, by(hid)
la var ownLand "Total land owned (in m^2)"

egen ownLandCult = total(as01q09) if as01q09!=999999 & owntagt & as02aq04==1, by(hid)
la var ownLandCult "Total land owned and cultivated (in m^2)"
mvencode ownLand*, mv(0) override

egen titleland = total(as01q09) if as01q09!=999999 & owntagt & as01q18==1, by(hid)
la var titleland "Land owned, cultivated and titled (in m^2)"

egen rentland = total(as01q09) if as01q09!=999999 & as01q16!=1, by(hid)
la var rentland "Land rented/mortgaged/loaned and cultivated (in m^2)"

g byte flag = inlist(as01q20, 9999989, 9999998, 9999999 )==1
egen landvalue = total(as01q20) if owntag==1 & flag!=1, by(hid)
la var landvalue "Total estimated value of land (in CFA)"

* Replace land values that end in something other than 0 with 0
* likely miscoded
replace landvalue=0 if mod(landvalue, 10) & landvalue!=.

* Distance, travel time, and size of primary field
g distland = as01q10 if as01q03==1 & as02aq04==1
la var distland "Distance to primary field"
replace distland=. if distland ==999

g timeland = as01q12 if as01q03==1 & as02aq04==1
la var timeland "Travel time to primary field"
replace timeland=. if timeland ==999

egen sizeland = total(as01q09) if as01q03==1 & as01q09!=999999 & as02aq04==1, by(hid)
la var sizeland "Size of primary field"

* Generate field characteristics
* % of land w/ erosion problems
egen erosiont = total(as01q09) if as01q25==1 & as01q09!=999999 & owntagt & as02aq04==1, by(hid)
recode erosiont(.=0)
g erosionPct = erosiont/ownLand
recode erosionPct(.=0)
la var erosionPct "% of cultivated land with erosion problems"

/* Regarding water access -- Over 90% of plots do not have
a principal source of water */

* Generate a metric for % of owned land manured or composted
egen fertt = total(as01q09) if as01q09!=999999 & owntagt & as02aq06==1 & as02aq04==1, by(hid)
recode fertt(.=0)
gen fertPct = fertt/ownLand
recode fertPct(.=0)
la var fertPct "% of cultivated land manured/composted"

* Collapse created variables down
* br hid-as01q09 owntagt-fertPct if inlist(hid, 1201, 1202, 1203)

/* Rules for collapse variables
	Use MEAN option for the following:
		ownLand ownLandCult titleLand rentland 
		landvalue distland timeland sizeland
		
	Use MAX option for erosionPct fertPct
*/
ren as01qa id
ren as01q03 fieldno
ren as01q04 fieldname
ren as01q05 parcelno

ds(as0* ms00*), not
keep `r(varlist)'

* Rename variables so you can merge
preserve
clear
use "$pathin/ecvmaas1_p2_en.dta"
ren as01qa id
ren as01q03 fieldno
ren as01q04 fieldname
ren as01q05 parcelno
save "$pathout/tmpag.dta", replace
restore

* Merge the second wave of data in and extract info related to conflict
merge 1:1 hid id fieldno parcelno using "$pathout/tmpag.dta", gen(merge1)

* Create a conflict variable
g byte tconflict=as01q51==1
egen conflict=max(tconflict), by(hid)
drop tconflict merge1 id 

ds(as0* ms00*), not
keep `r(varlist)'

* Copy variable labels to reapply after collapse
include "$pathdo/copylabels.do"

* Collapse data down to HH level
#delimit ;
collapse (max) erosionPct fertPct conflict
	(mean)ownLand ownLandCult titleland rentland 
	landvalue distland timeland sizeland
	menage grappe passage, by(hid) fast;
#delimit cr

order hid menage grappe passage

* Reapply variable lables
include "$pathdo/attachlabels.do"
mvencode titleland rentland, mv(0) override

* Generate a landless dummy
g byte landless = (ownLand+rentland==0)
la var landless "HH is farm landless"

order hid menage passage grappe

sort hid
compress
save "$pathout/hhnc.dta", replace

* Delete tempag data as they are no longer needed
cap erase "$pathout/tmpag.dta" 

* Create html log file for sharing
log2html "$pathlog/natcapital", replace

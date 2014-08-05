/*-------------------------------------------------------------------------------
# Name:		AdminTwoRecode
# Purpose:	Applies Admin two names to rural households; Cuts data in half.
# Author:	Tim Essam, Ph.D.
# Modified: 	07/23/2014
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
#-------------------------------------------------------------------------------
*/

*Fix the strings for admin2 zones
#delimit ;
label define admin
           1 "Aguie"
           2 "Bkonni" 
           3 "Boboye" 
           4 "Bouza" 
           5 "Dakoro" 
           6 "Diffa" 
           7 "Dogon-Doutchi" 
           8 "Dosso" 
           9 "Filingue" 
          10 "Gaya" 
          11 "Goure" 
          12 "Groumdji" 
          13 "Illela" 
          14 "Keita" 
          15 "Kollo" 
          16 "Loga" 
          17 "Madaoua" 
          18 "Madarounfa" 
          19 "Magaria" 
          20 "Matameye" 
          21 "Mayahi" 
          22 "Maine-Soroa" 
          23 "Mirriah" 
          24 "NGuigmi" 
          25 "Ouallam" 
          26 "Say" 
          27 "Tahoua" 
          28 "Tanout" 
          29 "Tchighozerine" 
          30 "Tchin-Tabarade" 
          31 "Tessaoua" 
          32 "Tillabery" 
          33 "Tera" ;
#delimit cr
label values admin2 admin 
replace admin2=999 if admin2==.

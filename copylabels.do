/*-------------------------------------------------------------------------------
# Name:		copylabels
# Purpose:	Copies labels from a dataset; for use before collapse command
# Author:	Tim Essam, Ph.D.
# Created:	14/11/2013
# Licence:	<Tim Essam Consulting/OakStream Systems, LLC>
# Ado(s):	none
#-------------------------------------------------------------------------------
*/

foreach v of var * {
        local l`v' : variable label `v'
            if `"`l`v''"' == "" {
            local l`v' "`v'"
        }
}

#### Niger Geospatial Livelihood Analysis of World Bank LSMS Data

This Stata code will reproduce the data and results of our geospatial analysis of [World Bank Living Standard's Measurement Study (LSMS) for Niger][1]. The following Stata do files create a folder file structure for the project, processes the LSMS Niger data, and produces a series of summary tables and logistic regression models to analyze how exogenous shocks affect rural households in Niger. See the [GettingStarted.md][3] file for complete details.

To reproduce the analysis, clone the repository, set the appropriate working directory and run the .do files in the following order. The .do files work best if copied into the ```ProjectPath\Dofiles\``` folder that is created after running the setup file. Download and unzip the raw WB LSMS data to the ```Datain``` folder.

* 00_SetupFolderGlobals.do  
* 01_hhchar.do
* 02_hhinfrastructure.do
* 03_hhnatcap.do
* 04_hhpc.do
* 05_transfers.do
* 06_shocks.do
* 07_foodsecurity.do
* 08_commservices.do
* 09_ShockAnalysis.do  
  
R files  
* The two R files (SpatReg.R and ShocksGraphs.R) can be used to reproduce the spatial filter model results and the forest plots, respectively.   

  
*Disclaimer: The findings, interpretation, and conclusions expressed herein are those of the authors and do not necessarily reflect the views of United States Agency for International Development or the United States Government. All errors remain our own.*  

[1]: http://web.worldbank.org/WBSITE/EXTERNAL/EXTDEC/EXTRESEARCH/EXTLSMS/EXTSURAGRI/0,,contentMDK:23353883~pagePK:64168445~piPK:64168309~theSitePK:7420261,00.html.
[2]: http://resources.arcgis.com/en/help/main/10.1/index.html#//0031000000q9000000  
[3]: https://github.com/tessam30/NigerGeospatialAnalysis/blob/master/GettingStarted.md  

#### Niger Geospatial Livelihood Analysis of World Bank LSMS Data
<img src="https://cloud.githubusercontent.com/assets/5873344/4593685/2e5d1e24-5088-11e4-82ce-09b65b1f7bc2.jpg" alt="Smoothed Shock Estimates. Source: GeoCenter" align="middle">


This Stata code will reproduce the data and results of our geospatial analysis of [World Bank Living Standard's Measurement Study (LSMS) for Niger][1]. The following Stata do files create a folder file structure for the project, processes the LSMS Niger data, and produces a series of summary tables and logistic regression models to analyze how exogenous shocks affect rural households in Niger. 

To reproduce the analysis, clone the repository, set the appropriate working directory and run the .do files in the following order. The .do files work best if copied into the ```ProjectPath\Dofiles\``` folder that is created after running the setup file.
* 00_SetupFolderGlobals.do  (_After running, this download and unzip the raw WB LSMS data to the ```Datain``` folder and move do files into Dofile folder._)
* 01_hhchar.do
* 02_hhinfrastructure.do
* 03_hhnatcap.do
* 04_hhpc.do
* 05_transfers.do
* 06_shocks.do
* 07_foodsecurity.do
* 08_commservices.do
* 09_ShockAnalysis.do

Questions: tessam[at]usaid.gov

[1]: http://web.worldbank.org/WBSITE/EXTERNAL/EXTDEC/EXTRESEARCH/EXTLSMS/EXTSURAGRI/0,,contentMDK:23353883~pagePK:64168445~piPK:64168309~theSitePK:7420261,00.html

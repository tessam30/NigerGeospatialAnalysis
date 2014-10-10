#### Niger Geospatial Livelihood Analysis of World Bank LSMS Data Results
===
The figures below summarize the logistic regression analysis conducted on the LSMS data. The forest plot can be read as follows:
* The circle is the coefficient estimate.  
* The horizontal line going through each circle is the confidence intervale of the estimate.
* The values on the x-axis are raw coeficient values. These can be transformed into odds-ratios by exponentiating them.

######Results  
Results from logistic regression models estimated in Stata 13.1 SE using the survey package to estimate standard errors.
<p><img src="https://cloud.githubusercontent.com/assets/5873344/4593934/f948e026-508a-11e4-9ea4-e3afe48b3a51.png" alt="Logistic  Estimates. Source: GeoCenter" align="middle"></p>

Results from the spatial filter model () estimed in R using `RColorBrewer, spdep, classInt, MASS, maptools` libraries.
<p><img src="https://cloud.githubusercontent.com/assets/5873344/4594082/6eba67d4-508c-11e4-9823-106be59f8982.png" alt="Logistic Estimates from Spatial Filter Model. Source: GeoCenter" align="middle"></p>

Finally, results from logistic regression on a composite shock variable using geographic fixed-effects and other control variables.  
<p><img src="https://cloud.githubusercontent.com/assets/5873344/4594303/4e024c1c-508e-11e4-97db-f69fcf238c4d.jpg" alt="Logistic Estimates from Spatial Filter Model. Source: GeoCenter" align="middle"></p>

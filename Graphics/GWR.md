#### Geographically Weighted Regression Results
===  
The final model we estimate is a geographically weighted regression (GWR).  GWR differs from the previous two techniques in that it estimates a local model of the dependent variable by fitting an ordinary linear regression equation to a neighborhood around each feature in the dataset.  This gives us a set of regression coefficients, standard errors, and goodness of fit statistics for each household, based solely upon the surrounding area.  This can elucidate spatial patterns in the relationships, such as isolating regions where the relationship between two variables differs from the rest of the country, suggesting the presence of unique local conditions. This routine is accomplished by setting up bandwidths around each target feature. The characteristics of the bandwidths are determined by selecting values for the kernel type, bandwidth method, distance, and number of neighbors to be used in the estimation. For our estimation routines we used fixed kernels and Akaikie Information Criterion Bandwidths. All of the GWR models are estimated using ArcGIS 10.2 Spatial Statistics Toolbox.  

===  
Results for selected variables are shown below for the three major shocks.   
###### Food Price Shocks
<p><img src="https://cloud.githubusercontent.com/assets/5873344/4595038/12e098b2-5095-11e4-8edc-f98057a621cd.jpg" alt="Smoothed Shock Estimates. Source: GeoCenter" align="middle"></p>

###### Weather Shocks
<p><img src="https://cloud.githubusercontent.com/assets/5873344/4595062/46483a02-5095-11e4-8d4c-5a4d8a86392d.jpg" alt="Smoothed Shock Estimates. Source: GeoCenter" align="middle"></p>

###### Agricultural & Livestock Shocks
<p><img src="https://cloud.githubusercontent.com/assets/5873344/4595033/03c73cd2-5095-11e4-9478-71b0c4c047b4.jpg" alt="Smoothed Shock Estimates. Source: GeoCenter" align="middle"></p>



As part of the project we were asked to create a few reference products. To visualize the bulging population of Niger we create a population pyramid using R and data from the World Bank.

<p><img src="https://cloud.githubusercontent.com/assets/5873344/4594468/eabd7814-508f-11e4-85ad-a13c0f5b0505.png" alt="Pop pyramid. Source: GeoCenter" align="middle"></p>

The code to create the graphic follows:  
```r
Load required libraries  
library(plotrix)    
library(RColorBrewer)    
library(colorRamps)
```

Check out color ramps available.  
```r
display.brewer.all()
```
Add in the data that was gathered from the WB. This eventually should be automated as well.
```r
xy.pop<-c(20.96, 16.41, 13.39, 10.22, 7.18, 5.84, 5.00, 4.44, 
              3.64, 3.01, 3.26, 2.49, 1.71, 1.17, 0.71, 0.36, 0.21)
xx.pop<-c(20.5, 16.00, 13.01, 10.45, 8.14, 6.50, 5.43, 4.49, 
              3.74, 3.10, 2.49, 1.94, 1.47, 1.25, 0.86, 0.45, 0.23)
agelabels<-c("0-4","5-9","10-14","15-19","20-24","25-29","30-34",
             "35-39","40-44","45-49","50-54","55-59","60-64","65-69","70-74",
             "75-79", "80+")
```


Set color parameters.
```r
colourCountxx = length(xx.pop)  
colourCountxy = length(xy.pop)  
mcol = colorRampPalette(rev(brewer.pal(8, "Blues")))  
fcol = colorRampPalette(rev(brewer.pal(8, "PuRd")))
```

Create pyramid and apply colors.
```r
poppyr <- par(mar=pyramid.plot(xy.pop,xx.pop,labels=agelabels,
  main="Niger Population Pyramid 2015",
  lxcol=mcol(colourCountxx),rxcol=fcol(colourCountxy),
  gap=1,show.values=TRUE, ndig=1, space=0))
```

Use code below to add custom notes to margins
```r
mtext(c("Source: World Bank 2015 Population Projections"),side=1,line=1.5,at=c(.5), cex=.66)
mtext(c("Percent of overall population"),side=1,line=1,at=c(-7), cex=1)
```

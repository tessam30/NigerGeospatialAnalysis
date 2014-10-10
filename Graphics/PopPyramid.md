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

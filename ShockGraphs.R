# Name:	ShockGraphs.R	
# Purpose:	Create logit regression graphs (forest plots) for Niger LSMS livelihood analysis
# Author:	Tim Essam, Ph.D.
# Created:	07/23/2014
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Adopted from "Using Graphs Instead of Tables in Politcal Science" (Kastelle & Leoni, 2007)
# NOTES: Works best using R Studio.

rm( list=ls())

#Load Shock data in matrix format from Stata
mydir <- c("U:/nigerlsms/r") #your working directory goes here.
setwd(mydir)
dir()

#Read in the matrix that was exported from Stata
d <- read.table("OtherShocks.txt", sep= "", header=TRUE, row.names=1, nrows=25, fill = TRUE)
d <- d[complete.cases(d), ]

#No special libraries required
#Step 1: Create vector for coefs, std errs, var names
coef.vec  <- d[1:24,1]
se.vec    <- d[1:24,2]

minV <- round(min(coef.vec)-1,0)
maxV <- round(max(coef.vec)+1,0)

#Variable names
var.names <- c("Female head of household", "Married head of household", "Age of head of household",
               "Literate head of household", "Muslim educated head", "Highest education in household",
               "Mobile phone", "Household size", "Gender ratio","Dependency ratio", 
               "Ethnically mixed", "Male labor", "Female labor", "Under 15 share",
               "Cultivated land owned", "Infrastructure index", "Durable Wealth index",
               "Agricultural wealth index", "Community services", "Community health services",
               "Nearest road (in km)", "Nearest market(in km)", "Annual mean temp.", "Annual Precip (in mm)")


#y-axis indicator, descending so that R orders vars from top to bottom
y.axis <- c(length(coef.vec):1)#create indicator for y.axis, descending so that R orders vars from top to bottom on y-axis

#Open pdf device
png("4anyShocks.png", height = 550, width = 600)#open pdf device

par(mar=c(3, 13.5, 1, 0)) #set margins for plot, leaving lots of room on left-margin (2nd number in margin command) for variable names
plot(coef.vec, y.axis, type = "p", axes = F, xlab = "", ylab = "", pch = 19, cex = 1.5,#plot coefficients as points, turning off axes and labels. 
     xlim = c(minV,maxV), xaxs = "r", main = "") #set limits of x-axis so that they include mins and maxs of 
#coefficients + .95% confidence intervals and plot is symmetric; use "internal axes", and leave plot title empty
#the 3 lines below create horiztonal lines for 95% confidence intervals, and vertical ticks for 90% intervals

segments(coef.vec-qnorm(.975)*se.vec, y.axis, coef.vec+qnorm(.975)*se.vec, y.axis, lwd =  1)#coef +/-1.96*se = 95% interval, lwd adjusts line thickness
#if you want to add tick marks for 90% confidence interval, use following 2 lines:
#segments(coef.vec-qnorm(.95)*se.vec, y.axis -.1, coef.vec-qnorm(.95)*se.vec, y.axis +.1, lwd = 1.1)#coef +/-1.64*se = 90% interval
#segments(coef.vec+qnorm(.95)*se.vec, y.axis -.1, coef.vec+qnorm(.95)*se.vec, y.axis +.1, lwd = 1.1)

axis(1, at = seq(minV,maxV,by=.25), labels = NA, tick = T,#draw x-axis and labels with tick marks
     cex.axis = 1.2, mgp = c(2,.7,0))#reduce label size, moves labels closer to tick marks

axis(1, at = seq(minV,maxV,by=1), labels = c(minV:maxV), tick = T,#draw x-axis and labels with tick marks
     cex.axis = 1.2, mgp = c(2,.7,0))#reduce label size, moves labels closer to tick marks    

axis(2, at = y.axis, label = var.names, pos=minV, las = 1, tick = T, ,mgp = c(1,.6,0), cex.axis = 1.2) #draw y-axis with tick marks, make labels perpendicular to axis and closer to axis
segments(0,0,0,length(coef.vec):1+.25,lty=2) # draw dotted line through 0
#box(bty = "l") #place box around plot
title("1. Any Type of Shock", font.main= 1)
mtext(c("Coefficient estimates"),side=1,line=1.5,at=c(0), cex=.75)

dev.off()


#### Ag Shocks #####
coef.vec  <- d[1:24,3]
se.vec    <- d[1:24,4]

#Calculate min and max for axis ranges
minV <- round(min(coef.vec)-1,0)
maxV <- round(max(coef.vec)+2,0)

#y-axis indicator, descending so that R orders vars from top to bottom
y.axis <- c(length(coef.vec):1)

png("5AgShocks.png", height = 550, width = 600)#open pdf device

par(mar=c(3, 2, 1, 2))
plot(coef.vec, y.axis, type = "p", axes = F, xlab = "", ylab = "", pch = 19, cex = 1.5,#plot coefficients as points, turning off axes and labels. 
     xlim = c(minV,maxV), xaxs = "r", main = "") #set limits of x-axis so that they include mins and maxs of 
#coefficients + .95% confidence intervals and plot is symmetric; use "internal axes", and leave plot title empty
#the 3 lines below create horiztonal lines for 95% confidence intervals, and vertical ticks for 90% intervals

segments(coef.vec-qnorm(.975)*se.vec, y.axis, coef.vec+qnorm(.975)*se.vec, y.axis, lwd =  1)#coef +/-1.96*se = 95% interval, lwd adjusts line thickness
#if you want to add tick marks for 90% confidence interval, use following 2 lines:
#segments(coef.vec-qnorm(.95)*se.vec, y.axis -.1, coef.vec-qnorm(.95)*se.vec, y.axis +.1, lwd = 1.1)#coef +/-1.64*se = 90% interval
#segments(coef.vec+qnorm(.95)*se.vec, y.axis -.1, coef.vec+qnorm(.95)*se.vec, y.axis +.1, lwd = 1.1)

axis(1, at = seq(minV,maxV,by=.25), labels = NA, tick = T,#draw x-axis and labels with tick marks
     cex.axis = 1.2, mgp = c(2,.7,0))#reduce label size, moves labels closer to tick marks

axis(1, at = seq(minV,maxV,by=1), labels = c(minV:maxV), tick = T,#draw x-axis and labels with tick marks
     cex.axis = 1.2, mgp = c(2,.7,0))#reduce label size, moves labels closer to tick marks    

#axis(2, at = y.axis, label = var.names, pos=minV, las = 1, tick = T, ,mgp = c(1,.6,0), cex.axis = 1.2) #draw y-axis with tick marks, make labels perpendicular to axis and closer to axis
segments(0,0,0,length(coef.vec):1+.25,lty=2) # draw dotted line through 0
title("2. Agriculture & Livestock Shocks", font.main= 1)
mtext(c("Coefficient estimates"),side=1,line=1.5,at=c(0), cex=.75)
dev.off()


#### Food Price Shocks #####
coef.vec  <- d[1:24,5]
se.vec    <- d[1:24,6]

#Calculate min and max for axis ranges
minV <- round(min(coef.vec)-1,0)
maxV <- round(max(coef.vec)+2,0)

#y-axis indicator, descending so that R orders vars from top to bottom
y.axis <- c(length(coef.vec):1)

png("6FoodShocks.png", height = 550, width = 600)#open pdf device
par(mar=c(3, 0, 1, 14.5))
plot(coef.vec, y.axis, type = "p", axes = F, xlab = "", ylab = "", pch = 19, cex = 1.5,#plot coefficients as points, turning off axes and labels. 
     xlim = c(minV,maxV), xaxs = "r", main = "") #set limits of x-axis so that they include mins and maxs of 
#coefficients + .95% confidence intervals and plot is symmetric; use "internal axes", and leave plot title empty
#the 3 lines below create horiztonal lines for 95% confidence intervals, and vertical ticks for 90% intervals

segments(coef.vec-qnorm(.975)*se.vec, y.axis, coef.vec+qnorm(.975)*se.vec, y.axis, lwd =  1)#coef +/-1.96*se = 95% interval, lwd adjusts line thickness
#if you want to add tick marks for 90% confidence interval, use following 2 lines:
#segments(coef.vec-qnorm(.95)*se.vec, y.axis -.1, coef.vec-qnorm(.95)*se.vec, y.axis +.1, lwd = 1.1)#coef +/-1.64*se = 90% interval
#segments(coef.vec+qnorm(.95)*se.vec, y.axis -.1, coef.vec+qnorm(.95)*se.vec, y.axis +.1, lwd = 1.1)

axis(1, at = seq(minV,maxV,by=.25), labels = NA, tick = T,#draw x-axis and labels with tick marks
     cex.axis = 1.2, mgp = c(2,.7,0))#reduce label size, moves labels closer to tick marks

axis(1, at = seq(minV,maxV,by=1), labels = c(minV:maxV), tick = T,#draw x-axis and labels with tick marks
     cex.axis = 1.2, mgp = c(2,.7,0))#reduce label size, moves labels closer to tick marks    

axis(4, at = y.axis, label = var.names, las = 1, tick = T, ,mgp = c(1,.6,0), cex.axis = 1.2) #draw y-axis with tick marks, make labels perpendicular to axis and closer to axis
segments(0,0,0,length(coef.vec):1+.25,lty=2) # draw dotted line through 0
title("3. Food Price Shocks", font.main= 1)
mtext(c("Coefficient estimates"),side=1,line=1.5,at=c(0), cex=.75)
dev.off()

#### Weather Shocks #####
coef.vec  <- d[1:24,7]
se.vec    <- d[1:24,8]

#Calculate min and max for axis ranges
minV <- round(min(coef.vec)-2,0)
maxV <- round(max(coef.vec)+2,0)

#y-axis indicator, descending so that R orders vars from top to bottom
y.axis <- c(length(coef.vec):1)
png("1WeatherShocks.png", height = 550, width = 600)#open pdf device
par(mar=c(3, 13.5, 1, 0))

plot(coef.vec, y.axis, type = "p", axes = F, xlab = "", ylab = "", pch = 19, cex = 1.5,#plot coefficients as points, turning off axes and labels. 
     xlim = c(minV,maxV), xaxs = "r", main = "") #set limits of x-axis so that they include mins and maxs of 
#coefficients + .95% confidence intervals and plot is symmetric; use "internal axes", and leave plot title empty
#the 3 lines below create horiztonal lines for 95% confidence intervals, and vertical ticks for 90% intervals

segments(coef.vec-qnorm(.975)*se.vec, y.axis, coef.vec+qnorm(.975)*se.vec, y.axis, lwd =  1)#coef +/-1.96*se = 95% interval, lwd adjusts line thickness
#if you want to add tick marks for 90% confidence interval, use following 2 lines:
#segments(coef.vec-qnorm(.95)*se.vec, y.axis -.1, coef.vec-qnorm(.95)*se.vec, y.axis +.1, lwd = 1.1)#coef +/-1.64*se = 90% interval
#segments(coef.vec+qnorm(.95)*se.vec, y.axis -.1, coef.vec+qnorm(.95)*se.vec, y.axis +.1, lwd = 1.1)

axis(1, at = seq(minV,maxV,by=.25), labels = NA, tick = T,#draw x-axis and labels with tick marks
     cex.axis = 1.2, mgp = c(2,.7,0))#reduce label size, moves labels closer to tick marks

axis(1, at = seq(minV,maxV,by=1), labels = c(minV:maxV), tick = T,#draw x-axis and labels with tick marks
     cex.axis = 1.2, mgp = c(2,.7,0))#reduce label size, moves labels closer to tick marks    

axis(2, at = y.axis, label = var.names, pos=minV, las = 1, tick = T, ,mgp = c(1,.6,0), cex.axis = 1.2) #draw y-axis with tick marks, make labels perpendicular to axis and closer to axis
segments(0,0,0,length(coef.vec):1+.25,lty=2) # draw dotted line through 0
title("4. Weather Shocks", font.main= 1)
mtext(c("Coefficient estimates"),side=1,line=1.5,at=c(0), cex=.75)
dev.off()

#### Health Shocks #####
coef.vec  <- d[1:24,9]
se.vec    <- d[1:24,10]

#Calculate min and max for axis ranges
minV <- round(min(coef.vec)-1,0)
maxV <- round(max(coef.vec)+1,0)


#y-axis indicator, descending so that R orders vars from top to bottom
y.axis <- c(length(coef.vec):1)

png("2HealthShocks.png", height = 550, width = 600)#open pdf device
par(mar=c(3, 2, 1, 2))

plot(coef.vec, y.axis, type = "p", axes = F, xlab = "", ylab = "", pch = 19, cex = 1.5,#plot coefficients as points, turning off axes and labels. 
     xlim = c(minV,maxV), xaxs = "r", main = "") #set limits of x-axis so that they include mins and maxs of 
#coefficients + .95% confidence intervals and plot is symmetric; use "internal axes", and leave plot title empty
#the 3 lines below create horiztonal lines for 95% confidence intervals, and vertical ticks for 90% intervals

segments(coef.vec-qnorm(.975)*se.vec, y.axis, coef.vec+qnorm(.975)*se.vec, y.axis, lwd =  1)#coef +/-1.96*se = 95% interval, lwd adjusts line thickness
#if you want to add tick marks for 90% confidence interval, use following 2 lines:
#segments(coef.vec-qnorm(.95)*se.vec, y.axis -.1, coef.vec-qnorm(.95)*se.vec, y.axis +.1, lwd = 1.1)#coef +/-1.64*se = 90% interval
#segments(coef.vec+qnorm(.95)*se.vec, y.axis -.1, coef.vec+qnorm(.95)*se.vec, y.axis +.1, lwd = 1.1)

axis(1, at = seq(minV,maxV,by=.25), labels = NA, tick = T,#draw x-axis and labels with tick marks
     cex.axis = 1.2, mgp = c(2,.7,0))#reduce label size, moves labels closer to tick marks

axis(1, at = seq(minV,maxV,by=1), labels = c(minV:maxV), tick = T,#draw x-axis and labels with tick marks
     cex.axis = 1.2, mgp = c(2,.7,0))#reduce label size, moves labels closer to tick marks    

#axis(2, at = y.axis, label = var.names, pos=minV, las = 1, tick = F, ,mgp = c(1,.6,0), cex.axis = 1.2) #draw y-axis with tick marks, make labels perpendicular to axis and closer to axis
segments(0,0,0,length(coef.vec):1+.25,lty=2) # draw dotted line through 0
title("5. Health Shocks", font.main= 1)
mtext(c("Coefficient estimates"),side=1,line=1.5,at=c(0), cex=.75)
dev.off()


#### Financial Shocks #####
coef.vec  <- d[1:24,11]
se.vec    <- d[1:24,12]

#Calculate min and max for axis ranges
minV <- round(min(coef.vec)-2,0)
maxV <- round(max(coef.vec)+1,0)

png("3FinShocks.png", height = 550, width = 600)#open pdf device
par(mar=c(3, 0, 1, 14.5))#set margins for plot, leaving lots of room on left-margin (2nd number in margin command) for variable names

#y-axis indicator, descending so that R orders vars from top to bottom
y.axis <- c(length(coef.vec):1)

plot(coef.vec, y.axis, type = "p", axes = F, xlab = "", ylab = "", pch = 19, cex = 1.5,#plot coefficients as points, turning off axes and labels. 
     xlim = c(minV,maxV), xaxs = "r", main = "") #set limits of x-axis so that they include mins and maxs of 
#coefficients + .95% confidence intervals and plot is symmetric; use "internal axes", and leave plot title empty
#the 3 lines below create horiztonal lines for 95% confidence intervals, and vertical ticks for 90% intervals

segments(coef.vec-qnorm(.975)*se.vec, y.axis, coef.vec+qnorm(.975)*se.vec, y.axis, lwd =  1)#coef +/-1.96*se = 95% interval, lwd adjusts line thickness
#if you want to add tick marks for 90% confidence interval, use following 2 lines:
#segments(coef.vec-qnorm(.95)*se.vec, y.axis -.1, coef.vec-qnorm(.95)*se.vec, y.axis +.1, lwd = 1.1)#coef +/-1.64*se = 90% interval
#segments(coef.vec+qnorm(.95)*se.vec, y.axis -.1, coef.vec+qnorm(.95)*se.vec, y.axis +.1, lwd = 1.1)

axis(1, at = seq(minV,maxV,by=.25), labels = NA, tick = T,#draw x-axis and labels with tick marks
     cex.axis = 1.2, mgp = c(2,.7,0))#reduce label size, moves labels closer to tick marks

axis(1, at = seq(minV,maxV,by=1), labels = c(minV:maxV), tick = T,#draw x-axis and labels with tick marks
     cex.axis = 1.2, mgp = c(2,.7,0))#reduce label size, moves labels closer to tick marks    

axis(4, at = y.axis, label = var.names, las = 1, tick = T, ,mgp = c(1,.6,0), cex.axis = 1.2) #draw y-axis with tick marks, make labels perpendicular to axis and closer to axis
segments(0,0,0,length(coef.vec):1+.25,lty=2) # draw dotted line through 0
title("6. Financial Shocks", font.main= 1)
mtext(c("Coefficient estimates"),side=1,line=1.5,at=c(0), cex=.75)
dev.off()

######### COMBINE all PLOTS #########
ll <- list.files(path = 'C:/Users/t/Box Sync/Niger/R', pattern='Shocks*\\.png', full.names=F)
library(png)
imgs <- lapply(ll,function(x){
  as.raster(readPNG(x))  ## no need to convert to a matrix here!
})

x <- 1:2
y <- 1:3
dat <- expand.grid(x,y)

library(lattice)
library(grid)

#Create a function to use in the graph
bgColors <- c("transparent")
txtColors <- c("transparent")
myStripStyle <- function(which.panel, factor.levels, ...) {
  panel.rect(0, 0, 0, 0,
             col = bgColors[which.panel],
             border = 0)
  panel.text(x = 0.5, y = 0.5,
             font=2,
             lab = factor.levels[which.panel],
             col = txtColors[which.panel])
} 


xyplot(Var2~Var1|rownames(dat),data=dat,layout=c(3,2), xlab="",
       ylab = "", tck=c(1,0), scales=list(x=list(at=NULL), y=list(at=NULL)), strip=myStripStyle,
       panel=function(x,y,...){
         lims <- current.panel.limits()
         grid.raster(image =imgs[[panel.number()]],sum(lims$xlim)/2,sum(lims$ylim)/2,
                     width =diff(lims$xlim),
                     height=diff(lims$ylim),def='native' )         
             },
       par.settings = list(axis.line = list(col = "transparent")),

    )
trellis.focus("toplevel") ## has coordinate system [0,1] x [0,1]
panel.text(0.18, 0.038, "Source: GeoCenter Calculations based in World Bank LSMS 2011 Data for Niger; N = 1,752", cex = 0.60, font = 1)
trellis.unfocus()


########## Now Spatial Filter Model Results ################
rm( list=ls())
setwd("C:/Users/t/Box Sync/Niger/Excel")

d <- read.csv("SpatialFilterResults.csv", sep="," , header=TRUE)

setwd("C:/Users/t/Box Sync/Niger/R")
#Step 1: Create vector for coefs, std errs, var names
coef.vec  <- d[,2]
se.vec    <- d[,3]

minV <- round(min(coef.vec)-1,0)
maxV <- round(max(coef.vec)+2,0)

#Variable names
var.names <- c("Female head of household", "Married head of household", "Age of head of household",
               "Literate head of household", "Muslim educated head", "Highest education in household",
               "Mobile phone", "Household size", "Gender ratio","Dependency ratio", 
               "Ethnically mixed", "Male labor", "Female labor", "Under 15 share",
               "Landless household", "Cultivated land owned", "Infrastructure index", "Durable Wealth index",
               "Agricultural wealth index", "Community services", "Community health services",
               "Nearest road (in km)", "Nearest market(in km)", "Annual mean temp.", "Annual Precip (in mm)")


#y-axis indicator, descending so that R orders vars from top to bottom
y.axis <- c(length(coef.vec):1)#create indicator for y.axis, descending so that R orders vars from top to bottom on y-axis

#Open pdf device
png("4SpatialAny.png", height = 550, width = 600)#open pdf device
par(mar=c(3, 13.5, 1, 0))
plot(coef.vec, y.axis, type = "p", axes = F, xlab = "", ylab = "", pch = 19, cex = 1.5, xlim = c(minV,maxV), xaxs = "r", main = "") 
segments(coef.vec-qnorm(.975)*se.vec, y.axis, coef.vec+qnorm(.975)*se.vec, y.axis, lwd =  1)
axis(1, at = seq(minV,maxV,by=.25), labels = NA, tick = T, cex.axis = 1.2, mgp = c(2,.7,0))
axis(1, at = seq(minV,maxV,by=1), labels = c(minV:maxV), tick = T, cex.axis = 1.2, mgp = c(2,.7,0))  
axis(2, at = y.axis, label = var.names, pos=minV, las = 1, tick = T, ,mgp = c(1,.6,0), cex.axis = 1.2) 
segments(0,0,0,length(coef.vec):1+.25,lty=2) 
title("1. Any Type of Shock", font.main= 1)
mtext(c("Spatial Logit Coefficient estimates"),side=1,line=1.5,at=c(0), cex=.75)
dev.off()

# Ag shock Spatial
coef.vec  <- d[,4]
se.vec    <- d[,5]

minV <- round(min(coef.vec)-1,0)
maxV <- round(max(coef.vec)+1,0)

png("5SpatialAg.png", height = 550, width = 600)#open pdf device
par(mar=c(3, 2, 1, 2))
plot(coef.vec, y.axis, type = "p", axes = F, xlab = "", ylab = "", pch = 19, cex = 1.5, xlim = c(minV,maxV), xaxs = "r", main = "") 
segments(coef.vec-qnorm(.975)*se.vec, y.axis, coef.vec+qnorm(.975)*se.vec, y.axis, lwd =  1)
axis(1, at = seq(minV,maxV,by=.25), labels = NA, tick = T, cex.axis = 1.2, mgp = c(2,.7,0))
axis(1, at = seq(minV,maxV,by=1), labels = c(minV:maxV), tick = T, cex.axis = 1.2, mgp = c(2,.7,0))  
#axis(2, at = y.axis, label = var.names, pos=minV, las = 1, tick = T, ,mgp = c(1,.6,0), cex.axis = 1.2) 
segments(0,0,0,length(coef.vec):1+.25,lty=2) 
title("2. Agriculture & Livestock Shocks", font.main= 1)
mtext(c("Spatial Logit Coefficient estimates"),side=1,line=1.5,at=c(0), cex=.75)
dev.off()


# Food shock Spatial
coef.vec  <- d[,6]
se.vec    <- d[,7]

minV <- round(min(coef.vec)-1,0)
maxV <- round(max(coef.vec)+1,0)

png("6SpatialFood.png", height = 550, width = 600)#open pdf device
par(mar=c(3, 0, 1, 14.5))
plot(coef.vec, y.axis, type = "p", axes = F, xlab = "", ylab = "", pch = 19, cex = 1.5, xlim = c(minV,maxV), xaxs = "r", main = "") 
segments(coef.vec-qnorm(.975)*se.vec, y.axis, coef.vec+qnorm(.975)*se.vec, y.axis, lwd =  1)
axis(1, at = seq(minV,maxV,by=.25), labels = NA, tick = T, cex.axis = 1.2, mgp = c(2,.7,0))
axis(1, at = seq(minV,maxV,by=1), labels = c(minV:maxV), tick = T, cex.axis = 1.2, mgp = c(2,.7,0))  
axis(4, at = y.axis, label = var.names, las = 1, tick = T, ,mgp = c(1,.6,0), cex.axis = 1.2) 
segments(0,0,0,length(coef.vec):1+.25,lty=2) 
title("3. Food Price Shocks", font.main= 1)
mtext(c("Spatial Logit Coefficient estimates"),side=1,line=1.5,at=c(0), cex=.75)
dev.off()


# Weather shock Spatial
coef.vec  <- d[,8]
se.vec    <- d[,9]
minV <- round(min(coef.vec)-1,0)
maxV <- round(max(coef.vec)+1,0)

#Open pdf device
png("1SpatialWeather.png", height = 550, width = 600)#open pdf device
par(mar=c(3, 13.5, 1, 0))
plot(coef.vec, y.axis, type = "p", axes = F, xlab = "", ylab = "", pch = 19, cex = 1.5, xlim = c(minV,maxV), xaxs = "r", main = "") 
segments(coef.vec-qnorm(.975)*se.vec, y.axis, coef.vec+qnorm(.975)*se.vec, y.axis, lwd =  1)
axis(1, at = seq(minV,maxV,by=.25), labels = NA, tick = T, cex.axis = 1.2, mgp = c(2,.7,0))
axis(1, at = seq(minV,maxV,by=1), labels = c(minV:maxV), tick = T, cex.axis = 1.2, mgp = c(2,.7,0))  
axis(2, at = y.axis, label = var.names, pos=minV, las = 1, tick = T, ,mgp = c(1,.6,0), cex.axis = 1.2) 
segments(0,0,0,length(coef.vec):1+.25,lty=2) 
title("4. Weather Shock", font.main= 1)
mtext(c("Spatial Logit Coefficient estimates"),side=1,line=1.5,at=c(0), cex=.75)
dev.off()

# Health shock Spatial
coef.vec  <- d[,10]
se.vec    <- d[,11]

minV <- round(min(coef.vec)-1,0)
maxV <- round(max(coef.vec)+1,0)

png("2SpatialHealth.png", height = 550, width = 600)#open pdf device
par(mar=c(3, 2, 1, 2))
plot(coef.vec, y.axis, type = "p", axes = F, xlab = "", ylab = "", pch = 19, cex = 1.5, xlim = c(minV,maxV), xaxs = "r", main = "") 
segments(coef.vec-qnorm(.975)*se.vec, y.axis, coef.vec+qnorm(.975)*se.vec, y.axis, lwd =  1)
axis(1, at = seq(minV,maxV,by=.25), labels = NA, tick = T, cex.axis = 1.2, mgp = c(2,.7,0))
axis(1, at = seq(minV,maxV,by=1), labels = c(minV:maxV), tick = T, cex.axis = 1.2, mgp = c(2,.7,0))  
#axis(2, at = y.axis, label = var.names, pos=minV, las = 1, tick = T, ,mgp = c(1,.6,0), cex.axis = 1.2) 
segments(0,0,0,length(coef.vec):1+.25,lty=2) 
title("5. Health Shocks", font.main= 1)
mtext(c("Spatial Logit Coefficient estimates"),side=1,line=1.5,at=c(0), cex=.75)
dev.off()


# Food shock Spatial
coef.vec  <- d[,12]
se.vec    <- d[,13]

minV <- round(min(coef.vec)-1,0)
maxV <- round(max(coef.vec)+2,0)

png("3SpatialFin.png", height = 550, width = 600)#open pdf device
par(mar=c(3, 0, 1, 14.5))
plot(coef.vec, y.axis, type = "p", axes = F, xlab = "", ylab = "", pch = 19, cex = 1.5, xlim = c(minV,maxV), xaxs = "r", main = "") 
segments(coef.vec-qnorm(.975)*se.vec, y.axis, coef.vec+qnorm(.975)*se.vec, y.axis, lwd =  1)
axis(1, at = seq(minV,maxV,by=.25), labels = NA, tick = T, cex.axis = 1.2, mgp = c(2,.7,0))
axis(1, at = seq(minV,maxV,by=1), labels = c(minV:maxV), tick = T, cex.axis = 1.2, mgp = c(2,.7,0))  
axis(4, at = y.axis, label = var.names, las = 1, tick = T, ,mgp = c(1,.6,0), cex.axis = 1.2) 
segments(0,0,0,length(coef.vec):1+.25,lty=2) 
title("6. Financial Shocks", font.main= 1)
mtext(c("Spatial Logit Coefficient estimates"),side=1,line=1.5,at=c(0), cex=.75)
dev.off()

######### COMBINE all PLOTS #########
ll <- list.files(path = mydir, pattern='Spatial.*\\.png')

library(png)
imgs <- lapply(ll,function(x){
  as.raster(readPNG(x))  ## no need to convert to a matrix here!
})

x <- 1:2
y <- 1:3
dat <- expand.grid(x,y)

library(lattice)
library(grid)

#Create a function to use in the graph
bgColors <- c("transparent")
txtColors <- c("transparent")
myStripStyle <- function(which.panel, factor.levels, ...) {
  panel.rect(0, 0, 0, 0,
             col = bgColors[which.panel],
             border = 0)
  panel.text(x = 0.5, y = 0.5,
             font=2,
             lab = factor.levels[which.panel],
             col = txtColors[which.panel])
} 


xyplot(Var2~Var1|rownames(dat), data=dat, layout=c(3,2), xlab="",
       ylab = "", tck=c(1,0), scales=list(x=list(at=NULL), y=list(at=NULL)), strip=myStripStyle,
       panel=function(x,y,...){
         lims <- current.panel.limits()
         grid.raster(image =imgs[[panel.number()]],sum(lims$xlim)/2,sum(lims$ylim)/2,
                     width =diff(lims$xlim),
                     height=diff(lims$ylim),def='native' )         
       },
       par.settings = list(axis.line = list(col = "transparent")),
       
)
trellis.focus("toplevel") ## has coordinate system [0,1] x [0,1]
panel.text(0.18, 0.038, "Source: GeoCenter Calculations based in World Bank LSMS 2011 Data for Niger; N = 1,752", cex = 0.60, font = 1)
trellis.unfocus()

#Remove all .png files from directory when finished
pngs <- list.files(pattern = ".\\png")
spatial <- list.files( pattern ="^[S]", full.names=TRUE)



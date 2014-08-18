################################################################
# Purpose: Run spatial binary regression on vulnerability      #  
# Author: Prof. Jamison Conely, Tim Essam                      #
# References: Script provided in "Spatial Statistics &         #
# Geostatistics" by Y. Chun and D.A. Griffith.  It is on pages #
# 85-86.                                                       #
# Libraries: RColorBrewer, spdep, classInt, MASS, maptools     #                                                           #
################################################################

# Clear out workspace
rm( list=ls())

# Check if the required libraries exist, if not install them 
required_lib =c("RColorBrewer", "spdep", "classInt", "foreign", "MASS", "maptools", "ggplot2")

# Create a simple function to check if libraries exist or not, load if not;
install_required_libs<-function(){
  for(i in 1:length(required_lib)){
    if(required_lib[i] %in% rownames(installed.packages()) == FALSE)
    {install.packages(required_lib[i])}
  }
}

install_required_libs()
lapply(required_lib, require, character.only=T)

#Setup project directory
setwd("C:/Users/t/Box Sync/Niger/Export")
dir()
file.name = "R_spatreg.csv"

d <- read.csv(file.name)

x <- d$LON_DD_MOD
y <- d$LAT_DD_MOD
xy <- as.matrix(d[5:6])
distThresh <- dnearneigh(xy, 0, 100, longlat = TRUE)

## this sets up a distance threshold of a weights matrix within 100 km.
weights <- nb2listw(distThresh, style = "W")

## this converts the list of neighbors in the variable distThres into a proper weights matrix.  It is row standardized (style = "W")
# Set list of covariates for model
names(d)[40:64]
exog  <- as.matrix(d[40:64])

#Set dependent varaible
depvar <- d$anyshock

# Run the SAR error model 
## This applies a spatial error model.  The catch is that this essentially treats it as a linear regression, 
## ignoring any complexity from the fact that foodshk is really a binary variable.
sar <- errorsarlm(depvar ~ exog, listw = weights)
summary(sar)

#The spatial error term, though, is very significant, indicating spatial factors that aren't accounted for.
moran.test(depvar, weights)
geary.test(depvar, weights)

#Create spatial filter by calculating eigenvectors.
weightsB <- nb2listw(distThresh, style = "B")

## We need a non-row-standardized set of weights here, so style = "B"
n <- length(distThresh)
M <- diag(n) - matrix(1,n,n)/n
B <- listw2mat(weightsB)
MBM <- M %*% B %*% M
eig <- eigen(MBM, symmetric=T)
EV <- as.data.frame( eig$vectors[ ,eig$values/eig$values[1] > 0.25])
colnames(EV) <- paste("EV", 1:NCOL(EV), sep="")

## run a logistic regression (GLM with family=binomial)
full.glm <- glm(depvar ~ exog + ., data=EV, family=binomial)
summary(full.glm)

## Several of the eigenvectors are significant, although only literateHead (inverse) and mobile have  
## significant relationships from the original variables.
sf.glm <- stepAIC(glm(depvar ~ exog , data=EV, family=binomial), scope=list(upper=full.glm), direction="forward")
summary(sf.glm)

## Use the AIC to find an optimal model
sf.glm <- glm(depvar ~ exog + EV1 + EV12 + EV11, data=EV, family=binomial)
summary(sf.glm)

sf.glm.res <- round(residuals(sf.glm, type="response"))
moran.test(sf.glm.res, weights)
## residuals are *still* significantly spatially autocorrelated.  Grr...

shapefile <- "C:/Users/t/Box Sync/nigerlsms/R/rAnalysis/final_Niger_LSMS.shp"
##now create a map of food shocks (plot 1 in associated .docx)
points <- readShapePoints(shapefile)
pal.wr <- c("black", "red")
cols.wr <- pal.wr[depvar + 1]
plot(points, col=cols.wr)
pal.wr <- c("black", "red")
cols.wr <- pal.wr[depvar + 1]
plot(points, col=cols.wr)
leg <- c("no shock", "shock")
legend("bottomright", fill=pal.wr, legend=leg, bty="n")


## create a map of the predicted probability of experiencing a food shock (plot 2 in associated .docx)
pal.red <- brewer.pal(5, "Reds")
q5 <- classIntervals(sf.glm$fitted, 5, style="quantile")
cols.red <- findColours(q5, pal.red)
plot(points, col=cols.red)
brks <- round(q5$brks, 3)
leg <- paste(brks[-6], brks[-1], sep=" - ")
legend("bottomright", fill=pal.red, legend=leg, bty="n")

## and last map is symbolizing the probability based on whether it is above or below 0.5 (i.e., rounds up to 1 ##instead of down to 0) (plot 3)
cols.wr <- pal.wr[round(sf.glm$fitted)+1]
plot(points, col=cols.wr)
leg <- c("no shock", "shock")
legend("bottomright", fill=pal.red, legend=leg, bty="n")

LL <- d[,1:6]
EIG <- cbind(LL, EV)
setwd("C:/Users/t/Box Sync/Niger/GIS")
write.csv(EIG, file=sprintf("Eigen.csv"))



# data read


# data handle - preprocessing


# data represantation

library(sf)
library(concaveman)
library(conicfit)

data(meuse, package = "sp") # load data.frame from sp
meuse_sf = st_as_sf(meuse, coords = c("x", "y"), crs = 28992)

split_soil <- split(meuse_sf, meuse_sf$soil)
hulls <- lapply(split_soil, concaveman)
hulls <- do.call('rbind', hulls)

plot(meuse_sf['soil'], pch = 20, cex = 1, reset = FALSE, axes = T)
plot(hulls, add = TRUE, border = 'grey70', col = NA)
#https://gis.stackexchange.com/questions/302107/defining-convex-hull-of-clouds-of-points-using-r


X <- matrix(rnorm(2000), ncol = 2)
plot(X, cex = 0.5)
hpts <- chull(X)
hpts <- c(hpts, hpts[1])
lines(X[hpts, ])
#https://astrostatistics.psu.edu/datasets/R/html/graphics/html/chull.html

xy<-calculateEllipse(0,0,200,100,45,50, randomDist=TRUE,noiseFun=function(x)
  (x+rnorm(1,mean=0,sd=50)))
plot(xy[,1],xy[,2],xlim=c(-250,250),ylim=c(-250,250),col='magenta');par(new=TRUE)
ellipDirect <- EllipseDirectFit(xy)
ellipDirectG <- AtoG(ellipDirect)$ParG
xyDirect<-calculateEllipse(ellipDirectG[1], ellipDirectG[2], ellipDirectG[3],
                           ellipDirectG[4], 180/pi*ellipDirectG[5])
plot(xyDirect[,1],xyDirect[,2],xlim=c(-250,250),ylim=c(-250,250),type='l',
     col='cyan');par(new=TRUE)

#https://cran.r-project.org/web/packages/conicfit/conicfit.pdf


xy<-calculateEllipse(0,0,200,100,45,50, randomDist=TRUE,noiseFun=function(x)
  (x+rnorm(1,mean=0,sd=50)))
plot(xy[,1],xy[,2],xlim=c(-250,250),ylim=c(-250,250),col='magenta');par(new=TRUE)
ellipTaubin <- EllipseFitByTaubin(xy)
ellipTaubinG <- AtoG(ellipTaubin)$ParG
xyTaubin<-calculateEllipse(ellipTaubinG[1], ellipTaubinG[2], ellipTaubinG[3],
                           ellipTaubinG[4], 180/pi*ellipTaubinG[5])
plot(xyTaubin[,1],xyTaubin[,2],xlim=c(-250,250),ylim=c(-250,250),type='l',
     col='red');par(new=TRUE)

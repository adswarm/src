#random number generator from normal distribution

##############
# Initializing
# tips: ctrl + shft + c: comment selected lines
# refer for plotting: https://www.statmethods.net/advgraphs/parameters.html
##############

rm(list = ls())
library(plyr)
library(readr)
library(scales)
library(plyr)
library(conicfit) #library(concaveman)
library(geometry)
library(retistruct)
source("C:/Users/Chijung Jung/source/R_project/lib/functions.R")

set.seed(1)


#######
x.mean <-	c(-0.242551467,-0.406728453,-0.59001283)
x.var <- c(0.014604661, 0.009237011, 0.00965931)

y.mean <- c(0.143664352,-0.167873939,-0.029910216)	
y.var <- c(0.005996024, 0.011689131, 0.001910292)


f1.x <- rnorm(100, mean = x.mean[1], sd = sqrt(x.var[1]))
f1.y <- rnorm(100, mean = y.mean[1], sd = sqrt(y.var[1]))


f2.x <- rnorm(100, mean = x.mean[2], sd = sqrt(x.var[2]))
f2.y <- rnorm(100, mean = y.mean[2], sd = sqrt(y.var[2]))


f3.x <- rnorm(100, mean = x.mean[3], sd = sqrt(x.var[3]))
f3.y <- rnorm(100, mean = y.mean[3], sd = sqrt(y.var[3]))


# plotname <- paste(filename," with ",param.required_subset_size_rate,"(",param.dist_criteria,",",param.neighborNum_criteria,")",sep="" )
plot(c(f1.x, f2.x, f3.x),c(f1.y,f2.y,f3.y), pch = 2, xlab="x", ylab="y", main = "plotname")

points(f1.x, f1.y, pch = 3, col = "blue")
points(f2.x, f2.y, pch = 3, col = "brown")
points(f3.x, f3.y, pch = 3, col = "orange")


#version 2: big distance from original value
f1.x.v2 <- rnorm(100, mean = f1_sp[,1], sd = sqrt(x.var[1]))
f1.y.v2 <- rnorm(100, mean = f1_sp[,2], sd = sqrt(y.var[1]))
points(f1.x.v2, f1.y.v2, pch = 4, col = "blue")

f2.x.v2 <- rnorm(100, mean = f2_sp[,1], sd = sqrt(x.var[2]))
f2.y.v2 <- rnorm(100, mean = f2_sp[,2], sd = sqrt(y.var[2]))
points(f2.x.v2, f2.y.v2, pch = 3, col = "brown")

f3.x.v2 <- rnorm(100, mean = f3_sp[,1], sd = sqrt(x.var[3]))
f3.y.v2 <- rnorm(100, mean = f3_sp[,2], sd = sqrt(y.var[3]))
points(f3.x.v2, f3.y.v2, pch = 3, col = "orange")


#version 3: small distance from original value
f1.x.v2 <- rnorm(100, mean = f1_sp[,1], sd = x.var[1])
f1.y.v2 <- rnorm(100, mean = f1_sp[,2], sd = y.var[1])
points(f1.x.v2, f1.y.v2, pch = 4, col = "blue")

f2.x.v2 <- rnorm(100, mean = f2_sp[,1], sd = x.var[2])
f2.y.v2 <- rnorm(100, mean = f2_sp[,2], sd = y.var[2])
points(f2.x.v2, f2.y.v2, pch = 3, col = "brown")

f3.x.v2 <- rnorm(100, mean = f3_sp[,1], sd = x.var[3])
f3.y.v2 <- rnorm(100, mean = f3_sp[,2], sd = y.var[3])
points(f3.x.v2, f3.y.v2, pch = 3, col = "orange")

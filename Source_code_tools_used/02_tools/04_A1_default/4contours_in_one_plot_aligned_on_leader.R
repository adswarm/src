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
library(ggplot2)
library(ggforce)
library("shotGroups")
# source("C:/Users/Chijung Jung/source/R_project/lib/functions.R")
source("~/Research/tool_project_swarm_safety/lib/functions.R") # Linux version

set.seed(1)
# CEP for new aligned based on leader and theta
# 0.1
# f1   18  x/y/r:  -0.4923105   0.07289714   0.07582133 
# f2   18  x/y/r:  -0.5747002   -0.1167323   0.0703084 
# f3   18  x/y/r:  -0.6747458   -0.04274638   0.07616194 
# o   18  x/y/r:  0.4050354   -0.1299823   0.06360825 
# 
# 0.2
# f1   18  x/y/r:  -0.4923105   0.07289714   0.110343 
# f2   18  x/y/r:  -0.5747002   -0.1167323   0.10232 
# f3   18  x/y/r:  -0.6747458   -0.04274638   0.1108386 
# o   18  x/y/r:  0.4050354   -0.1299823   0.09256924
# 
# 0.3
# f1   18  x/y/r:  -0.4923105   0.07289714   0.1395047 
# f2   18  x/y/r:  -0.5747002   -0.1167323   0.1293614 
# f3   18  x/y/r:  -0.6747458   -0.04274638   0.1401314 
# o   18  x/y/r:  0.4050354   -0.1299823   0.1170337 
# 
# 0.4
# f1   18  x/y/r:  -0.4923105   0.07289714   0.1669509 
# f2   18  x/y/r:  -0.5747002   -0.1167323   0.154812 
# f3   18  x/y/r:  -0.6747458   -0.04274638   0.1677009 
# o   18  x/y/r:  0.4050354   -0.1299823   0.1400589 
# 
# 0.5
# f1   18  x/y/r:  -0.4923105   0.07289714   0.1944756 
# f2   18  x/y/r:  -0.5747002   -0.1167323   0.1803354 
# f3   18  x/y/r:  -0.6747458   -0.04274638   0.1953493 
# o   18  x/y/r:  0.4050354   -0.1299823   0.1631501 
# 
# 0.6
# f1   18  x/y/r:  -0.4923105   0.07289714   0.2235986 
# f2   18  x/y/r:  -0.5747002   -0.1167323   0.2073409 
# f3   18  x/y/r:  -0.6747458   -0.04274638   0.2246031 
# o   18  x/y/r:  0.4050354   -0.1299823   0.187582 
# 
# 0.7
# f1   18  x/y/r:  -0.4923105   0.07289714   0.2563072 
# f2   18  x/y/r:  -0.5747002   -0.1167323   0.2376712 
# f3   18  x/y/r:  -0.6747458   -0.04274638   0.2574586 
# o   18  x/y/r:  0.4050354   -0.1299823   0.215022 
# 
# 0.8
# f1   18  x/y/r:  -0.4923105   0.07289714   0.2963395 
# f2   18  x/y/r:  -0.5747002   -0.1167323   0.2747928 
# f3   18  x/y/r:  -0.6747458   -0.04274638   0.2976708 
# o   18  x/y/r:  0.4050354   -0.1299823   0.248606 
# 
# 0.9
# f1   18  x/y/r:  -0.4923105   0.07289714   0.3544544 
# f2   18  x/y/r:  -0.5747002   -0.1167323   0.3286822 
# f3   18  x/y/r:  -0.6747458   -0.04274638   0.3560466 
# o   18  x/y/r:  0.4050354   -0.1299823   0.2973599 

# d2d(combined_df, 'x','y','Legend')
# data <- combined_df
# var1 <- 'x'
# var2 <- 'y'
# col <- 'Legend'
d2d = function(data, var1, var2, col, exp=0.005) {
  
  # If the colour variable is numeric, convert to factor
  if(is.numeric(data[,col])) {
    data[,col] = as.factor(data[,col])
  }
  coef <- 1.0 #* 10 / 50

  center_x.l <- 0.0
  center_y.l <- 0.0
  center_r.l <- 0.0 * coef
  
  center_x.f1 <- -0.4923105
  center_y.f1 <- 0.17289714
  center_r.f1 <- 0.1944756 * coef
  
  center_x.f2 <- -0.5747002 + 0.1
  center_y.f2 <- -0.2167323
  center_r.f2 <- 0.1803354 * coef
  
  center_x.f3 <- -0.6747458
  center_y.f3 <- -0.04274638
  center_r.f3 <- 0.1953493 * coef
  
  center_x.o <- 0.4050354
  center_y.o <- -0.1299823
  center_r.o <- 0.1631501 * coef
  
  p=ggplot(data, aes_string(var1, var2, color=col)) +
    geom_density_2d_filled(contour_var = "ndensity", bins = 5) +
    geom_point() +
    scale_x_continuous(limits=c(min(data[,var1]) - 2*diff(range(data[,var1])),
                                max(data[,var1]) + 2*diff(range(data[,var1])))) +
    scale_y_continuous(limits=c(min(data[,var2]) - 2*diff(range(data[,var2])),
                                max(data[,var2]) + 2*diff(range(data[,var2]))))# + 
  # annotate("path",
  #          x=center_x.l+center_r.l*cos(seq(0,2*pi,length.out=100)),
  #          y=center_y.l+center_r.l*sin(seq(0,2*pi,length.out=100)))
  
  # Get min and max x and y values among all density contours
  pb = ggplot_build(p)
  xyscales = lapply(pb$data[[1]][,c("x","y")], function(var) {
    rng = range(var)
    rng + c(-exp*diff(rng), exp*diff(rng))
  })
  
  # for followers
  # xlim(-1.3, 0.0) +
  #   ylim(-0.7, 0.5) +
  
  # for obstacle
  #   xlim(0.0, 1.3) +

  g <- ggplot(data, aes_string(var1, var2, colour=col, fill = col)) +
    scale_colour_manual(values = c("Blue", "Brown", "Orange", "Black")) +
    xlim(-1.3, 0.0) +
    ylim(-0.7, 0.5) +
    geom_density_2d() +
    geom_point(size = 5.0) +
    theme_classic()
    # scale_x_continuous(limits=xyscales[[1]]) +
    # scale_y_continuous(limits=xyscales[[2]]) + 
    
    # 50%
    
    # annotate("path",
    #          x=center_x.f1+center_r.f1*cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f1+center_r.f1*sin(seq(0,2*pi,length.out=100)), color = "blue", size = 0.5) +
    # annotate("path",
    #          x=center_x.f2+center_r.f2*cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f2+center_r.f2*sin(seq(0,2*pi,length.out=100)), color = "brown", size = 0.5) +
    # annotate("path",
    #          x=center_x.f3+center_r.f3*cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f3+center_r.f3*sin(seq(0,2*pi,length.out=100)), color = "orange", size = 0.5) +
    # annotate("path",
    #          x=center_x.o+center_r.o*cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.o+center_r.o*sin(seq(0,2*pi,length.out=100)), color = "black", size = 0.5) +
    
  # # 40%
    # annotate("path",
    #          x=center_x.l+ 0.2016099 *cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.l+ 0.2016099 *sin(seq(0,2*pi,length.out=100)), color = "red", size = 0.8) +
    # annotate("path",
    #          x=center_x.f1+ 0.2166604 *cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f1+ 0.2166604 *sin(seq(0,2*pi,length.out=100)), color = "blue", size = 0.8) +
    # annotate("path",
    #          x=center_x.f2+ 0.2509237 *cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f2+ 0.2509237 *sin(seq(0,2*pi,length.out=100)), color = "brown", size = 0.8) +
    # annotate("path",
    #          x=center_x.f3+ 0.2160799 *cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f3+ 0.2160799 *sin(seq(0,2*pi,length.out=100)), color = "orange", size = 0.8) +

    # # 30%
    # annotate("path",
    #          x=center_x.l+ 0.1273975 *cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.l+ 0.1273975 *sin(seq(0,2*pi,length.out=100)), color = "red", size = 1) +
    # annotate("path",
    #          x=center_x.f1+ 0.1543995 *cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f1+ 0.1543995 *sin(seq(0,2*pi,length.out=100)), color = "blue", size = 1) +
    # annotate("path",
    #          x=center_x.f2+ 0.1595879 *cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f2+ 0.1595879 *sin(seq(0,2*pi,length.out=100)), color = "brown", size = 1) +
    # annotate("path",
    #          x=center_x.f3+ 0.1458916 *cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f3+ 0.1458916 *sin(seq(0,2*pi,length.out=100)), color = "orange", size = 1) +
    # 
    # # # 20%
    # # annotate("path",
    # #          x=center_x.l+ 0.1332501 *cos(seq(0,2*pi,length.out=100)),
    # #          y=center_y.l+ 0.1332501 *sin(seq(0,2*pi,length.out=100)), color = "red", size = 1.2) +
    # # annotate("path",
    # #          x=center_x.f1+ 0.1431975 *cos(seq(0,2*pi,length.out=100)),
    # #          y=center_y.f1+ 0.1431975 *sin(seq(0,2*pi,length.out=100)), color = "blue", size = 1.2) +
    # # annotate("path",
    # #          x=center_x.f2+ 0.1658431 *cos(seq(0,2*pi,length.out=100)),
    # #          y=center_y.f2+ 0.1658431 *sin(seq(0,2*pi,length.out=100)), color = "brown", size = 1.2) +
    # # annotate("path",
    # #          x=center_x.f3+ 0.1428138 *cos(seq(0,2*pi,length.out=100)),
    # #          y=center_y.f3+ 0.1428138 *sin(seq(0,2*pi,length.out=100)), color = "orange", size = 1.2) +
    # 
    # # 10%
    # annotate("path",
    #          x=center_x.l+ 0.06924104 *cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.l+ 0.06924104 *sin(seq(0,2*pi,length.out=100)), color = "red", size = 1.5) +
    # annotate("path",
    #          x=center_x.f1+ 0.08391673 *cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f1+ 0.08391673 *sin(seq(0,2*pi,length.out=100)), color = "blue", size = 1.5) +
    # annotate("path",
    #          x=center_x.f2+ 0.08673665 *cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f2+ 0.08673665 *sin(seq(0,2*pi,length.out=100)), color = "brown", size = 1.5) +
    # annotate("path",
    #          x=center_x.f3+ 0.07929268 *cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f3+ 0.07929268 *sin(seq(0,2*pi,length.out=100)), color = "orange", size = 1.5) +
    # 
    # theme_bw()
    
    
  
  
  return(g)
  #https://ggforce.data-imaginist.com/reference/geom_circle.html
  #https://stackoverflow.com/questions/61622270/ggplot2-highlight-area-between-two-geom-circle
}

##############
# configurations
##############
# param.culumn_O_remove <- c(16,17,20,21) # <-  1stO.x     1stO.y     2ndO.x   2ndO.y
# param.culumn_etc_remove <- c(1:7)
param.mode.savePlot <- TRUE
# directory for input 
# base_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/00_00_randomtesting/",sep="" )
# csv_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing/pre/",sep="" )

##############
# Reading data
# refer: https://lightblog.tistory.com/13
# factor, refer: https://rfriend.tistory.com/32
# which, refer: http://egloos.zum.com/entireboy/v/4837061
##############
# datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/1st_alg_SVMap_example/input")
# datalist #seed_1_150_Ix2.0_new_restriction
# i <- 8
# filename <- datalist[i]
# filename = "seed_1_150_Ix2.0_new_restriction_aligned_with_theta_with_obstacle.csv"
filename = "seed_1_150_Ix2.0_new_restriction_aligned_with_theta_with_obstacle_v2.csv"


csvname = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/1st_alg_SVMap_example/input/",filename,sep="" )
data_raw <- read.csv(file = csvname, header = FALSE, fileEncoding="UTF-8-BOM", as.is = 1)
nrow(data_raw)

colnames(data_raw) <- c("l.x", "l.y", "f1.x", "f1.y", "f2.x", "f2.y", "f3.x", "f3.y", "o.x", "o.y")


plot(data_raw$l.x, data_raw$l.y, col = 'red', pch = 17, xlim = c(-1.5, 0.5), ylim = c(-2.5, 1.0))
points(data_raw$f1.x, data_raw$f1.y, col = 'blue', pch = 17)
points(data_raw$f2.x, data_raw$f2.y, col = 'brown', pch = 17)
points(data_raw$f3.x, data_raw$f3.y, col = 'orange', pch = 17)

nrow(data_raw)

library(MASS)
library(ggplot2)
param.mode.savePlot <- FALSE

# for(mode.which in c('l','f1','f2','f3')){
  # for(range_idx in 1:130) { #0:8){
  # for(range_idx in 0:18) { #0:8){
    
mode.which <- 'f1'
# range_idx <- 199
range_idx <- 18
outputplotdir <- paste("~/Research/tool_project_swarm_safety/Preprocessing_R/1st_alg_SVMap_example/output/contour_",mode.which,"_",range_idx,".png",sep="" )
if(param.mode.savePlot == TRUE) {png(outputplotdir, width = 500, height = 500, units = "px")}
range_start <- 1 #(10*range_idx) #1#
range_end <- (10*(range_idx+1)) # range_idx # #

# if(mode.which == 'l'){
data_x.l <- data_raw$l.x[range_start:range_end]
data_y.l <- data_raw$l.y[range_start:range_end]
# }else if(mode.which == 'f1'){
data_x.f1 <- data_raw$f1.x[range_start:range_end]
data_y.f1 <- data_raw$f1.y[range_start:range_end]
# }else if(mode.which == 'f2'){
data_x.f2 <- data_raw$f2.x[range_start:range_end]
data_y.f2 <- data_raw$f2.y[range_start:range_end]
# }else if(mode.which == 'f3'){
data_x.f3 <- data_raw$f3.x[range_start:range_end]
data_y.f3 <- data_raw$f3.y[range_start:range_end]
# }
data_x.o <- data_raw$o.x[range_start:range_end]
data_y.o <- data_raw$o.y[range_start:range_end]

df2.l = data.frame(data_x.l, data_y.l)
tag_df2.l = df2.l$data_x.l * 0
tag_df2.l <- 'Leader'
df2.l.tag <- cbind(df2.l, tag_df2.l)
colnames(df2.l.tag) <- c('x', 'y', 'Legend')

df2.f1 = data.frame(data_x.f1, data_y.f1)
tag_df2.f1 = df2.f1$data_x.f1 * 0 + 2
tag_df2.f1 <- 'Follower_1'
df2.f1.tag <- cbind(df2.f1, tag_df2.f1)
colnames(df2.f1.tag) <- c('x', 'y', 'Legend')

df2.f2 = data.frame(data_x.f2, data_y.f2)
tag_df2.f2 = df2.f2$data_x.f2 * 0 + 3
tag_df2.f2 <- 'Follower_2'
df2.f2.tag <- cbind(df2.f2, tag_df2.f2)
colnames(df2.f2.tag) <- c('x', 'y', 'Legend')

df2.f3 = data.frame(data_x.f3, data_y.f3)
tag_df2.f3 = df2.f3$data_x.f3 * 0 + 4
tag_df2.f3 <- 'Follower_3'
df2.f3.tag <- cbind(df2.f3, tag_df2.f3)
colnames(df2.f3.tag) <- c('x', 'y', 'Legend')

df2.o = data.frame(data_x.o, data_y.o)
tag_df2.o = df2.o$data_x.o * 0 + 5
tag_df2.o <- 'Obstacle'
df2.o.tag <- cbind(df2.o, tag_df2.o)
colnames(df2.o.tag) <- c('x', 'y', 'Legend')

# combined_df <- rbind(df2.f1.tag, df2.f2.tag, df2.f3.tag)
combined_df <- rbind(df2.f1.tag, df2.f2.tag, df2.f3.tag, df2.o.tag)

# refer: https://stats.stackexchange.com/questions/31726/scatterplot-with-contour-heat-overlay

# how to add
# https://stackoverflow.com/questions/35974805/ggplot2-automatic-scaling-to-include-complete-contour-lines-in-geom-density-2d

g <- ggplot(combined_df, aes_string('x','y', colour='Legend', fill = 'Legend')) +
  scale_colour_manual(values = c("Blue", "Brown", "Orange", "Black")) +
  xlim(-1.3, 0.0) +
  ylim(-0.7, 0.5) +
  geom_density_2d() +
  geom_point(size = 5.0) +
  theme_classic()

g
head(combined_df,5)
n = length(combined_df$x)
n
q <- ggplot(data=combined_df, 
       aes(x=x, y=y, colour=Legend, fill=Legend)) +
  xlim(-1.3, 0.0) +
  ylim(-0.7, 0.5) +
  stat_density_2d(geom="polygon", bins=10, alpha=0.1) +
  geom_point(size=10) +
  scale_fill_manual(values=c("Blue4", "Darkred","Darkgreen", "Black")) +
  scale_colour_manual(values = c("Blue4", "Darkred", "Darkgreen", "Black")) +
  # scale_colour_manual(values=hcl(seq(15,375,length=n+1)[1:n], 300, 65, alpha=0.3)) +
  theme_bw()
  # theme_classic()
q




# for followers
# xlim(-1.3, 0.0) +
#   ylim(-0.7, 0.5) +

# for obstacle
#   xlim(0.0, 1.3) +




# ggplot_result <- d2d(combined_df, 'x','y','Legend')
# ggplot_result

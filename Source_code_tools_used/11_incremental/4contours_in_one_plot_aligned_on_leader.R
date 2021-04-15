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
# 50% CEP
# l   18  x/y/r:  0.08377587   -1.717918   0.2348487 
# f1   18  x/y/r:  -0.4094276   -1.650876   0.2523806 
# f2   18  x/y/r:  -0.4922588   -1.841481   0.2922927 
# f3   18  x/y/r:  -0.5891237   -1.772339   0.2517043 
# 0.4
# l   18  x/y/r:  0.08377587   -1.717918   0.2016099 
# f1   18  x/y/r:  -0.4094276   -1.650876   0.2166604 
# f2   18  x/y/r:  -0.4922588   -1.841481   0.2509237 
# f3   18  x/y/r:  -0.5891237   -1.772339   0.2160799 
# 
# 0.3
# l   18  x/y/r:  0.08377587   -1.717918   0.1684658 
# f1   18  x/y/r:  -0.4094276   -1.650876   0.1810421 
# f2   18  x/y/r:  -0.4922588   -1.841481   0.2096726 
# f3   18  x/y/r:  -0.5891237   -1.772339   0.180557 
# 
# 0.2
# l   18  x/y/r:  0.08377587   -1.717918   0.1332501 
# f1   18  x/y/r:  -0.4094276   -1.650876   0.1431975 
# f2   18  x/y/r:  -0.4922588   -1.841481   0.1658431 
# f3   18  x/y/r:  -0.5891237   -1.772339   0.1428138 
# 
# 0.1
# l   18  x/y/r:  0.08377587   -1.717918   0.09156183 
# f1   18  x/y/r:  -0.4094276   -1.650876   0.09839708 
# f2   18  x/y/r:  -0.4922588   -1.841481   0.1139579 
# f3   18  x/y/r:  -0.5891237   -1.772339   0.09813341 

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
  coef <- 1.0
  # 
  # center_x.l <- 0.08377587
  # center_y.l <- -1.717918
  # center_r.l <- 0.2348487 * coef
  # 
  # center_x.f1 <- -0.4094276
  # center_y.f1 <- -1.650876
  # center_r.f1 <- 0.2523806 * coef
  # 
  # center_x.f2 <- -0.4922588
  # center_y.f2 <- -1.841481
  # center_r.f2 <- 0.2922927 * coef
  # 
  # center_x.f3 <- -0.5891237
  # center_y.f3 <- -1.772339
  # center_r.f3 <- 0.2517043 * coef
  # 
  
  center_x.l <- 0.1029973
  center_y.l <- -1.774786
  center_r.l <- 0.1775977 * coef
  
  center_x.f1 <- -0.1887
  center_y.f1 <- -1.617731
  center_r.f1 <- 0.2152397 * coef
  
  center_x.f2 <- -0.4218828 + 0.1
  center_y.f2 <- -1.87519
  center_r.f2 <- 0.2224726 * coef
  
  center_x.f3 <- -0.5239419
  center_y.f3 <- -1.827902
  center_r.f3 <- 0.2033794 * coef
  
  p=ggplot(data, aes_string(var1, var2, colour=col)) +
    geom_density_2d() +
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
  
  # add transparency: https://rpubs.com/Mentors_Ubiqum/Transparent_Lines
  # Set x and y ranges to include complete density contours
  g <- ggplot(data, aes_string(var1, var2, colour=col)) +
    scale_colour_manual(values = c("Blue", "Brown", "Orange", "Red")) + 
    geom_density_2d(size = 1) +
    geom_point(size = 1.0) +
    # scale_x_continuous(limits=xyscales[[1]]) +
    # scale_y_continuous(limits=xyscales[[2]]) + 
    
    # 50%
    # annotate("path",
    #          x=center_x.l+center_r.l*cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.l+center_r.l*sin(seq(0,2*pi,length.out=100)), color = "red", size = 0.5) +
    # annotate("path",
    #          x=center_x.f1+center_r.f1*cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f1+center_r.f1*sin(seq(0,2*pi,length.out=100)), color = "blue", size = 0.5) +
    # annotate("path",
    #          x=center_x.f2+center_r.f2*cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f2+center_r.f2*sin(seq(0,2*pi,length.out=100)), color = "brown", size = 0.5) +
    # annotate("path",
    #          x=center_x.f3+center_r.f3*cos(seq(0,2*pi,length.out=100)),
    #          y=center_y.f3+center_r.f3*sin(seq(0,2*pi,length.out=100)), color = "orange", size = 0.5) +
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
    theme_bw()
    
    
  
  
  return(g)
  #https://ggforce.data-imaginist.com/reference/geom_circle.html
  #https://stackoverflow.com/questions/61622270/ggplot2-highlight-area-between-two-geom-circle
}

##############
# configurations
##############
param.culumn_O_remove <- c(16,17,20,21) # <-  1stO.x     1stO.y     2ndO.x   2ndO.y
param.culumn_etc_remove <- c(1:7)
param.mode.savePlot <- TRUE
# directory for input 
# base_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/00_00_randomtesting/",sep="" )
csv_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing/pre/",sep="" )

##############
# Reading data
# refer: https://lightblog.tistory.com/13
# factor, refer: https://rfriend.tistory.com/32
# which, refer: http://egloos.zum.com/entireboy/v/4837061
##############
datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/incremental/input")
datalist #seed_1_150_Ix2.0_new_restriction
i <- 8
filename <- datalist[i]
filename


csvname = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/incremental/input/",filename,sep="" )
data_raw <- read.csv(file = csvname, header = FALSE, fileEncoding="UTF-8-BOM", as.is = 1)
nrow(data_raw)

colnames(data_raw) <- c("l.x", "l.y", "f1.x", "f1.y", "f2.x", "f2.y", "f3.x", "f3.y")


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
outputplotdir <- paste("~/Research/tool_project_swarm_safety/Preprocessing_R/incremental/output/contour_",mode.which,"_",range_idx,".png",sep="" )
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

combined_df <- rbind(df2.l.tag, df2.f1.tag, df2.f2.tag, df2.f3.tag)

# refer: https://stats.stackexchange.com/questions/31726/scatterplot-with-contour-heat-overlay

# how to add
# https://stackoverflow.com/questions/35974805/ggplot2-automatic-scaling-to-include-complete-contour-lines-in-geom-density-2d

ggplot_result <- d2d(combined_df, 'x','y','Legend')
ggplot_result

# center_x.f3 <- -0.5891237
# center_y.f3 <- -1.772339
# center_r.f3 <- 0.2517043 * 1
# data_f3 <- data.frame(center_x.f3, center_y.f3, center_r.f3)
# data_f3
# df_circle_1 <- data.frame(x=0,y=-1.75, r=0.5)
# 
# ggplot_result + 
#   geom_circle(data=df_circle_1, 
#               aes(x0=x,
#                   y0=y,
#                   r=r), 
#               size=4,
#               colour="red")
# 
# 
# # l   18  x/y/r:  0.08377587   -1.717918   0.428039 
# # f1   18  x/y/r:  -0.4094276   -1.650876   0.4599929 
# # f2   18  x/y/r:  -0.4922588   -1.841481   0.5327374 
# # f3   18  x/y/r:  -0.5891237   -1.772339   0.4587603 
# 
# 
# 

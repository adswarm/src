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
library(pracma)
library(MASS)
library(ggplot2)
library("shotGroups")
# source("C:/Users/Chijung Jung/source/R_project/lib/functions.R")
source("~/Research/tool_project_swarm_safety/lib/functions.R") # Linux version
source("~/Research/tool_project_swarm_safety/Preprocessing_R/possible_space/possible_space.R") # Linux version

set.seed(2)


##############
# configurations
##############

param.mode.savePlot = TRUE
# directory for input 
output_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/4th_physical/output/",sep="" )
input_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/4th_physical/data/",sep="" )


##############
# Reading data
# refer: https://lightblog.tistory.com/13
# factor, refer: https://rfriend.tistory.com/32
# which, refer: http://egloos.zum.com/entireboy/v/4837061
##############

datalist <- list.files(path = input_directory)
datalist
# i <- 1 #"integrated_log_part_1_physical_exp.csv"
# filename <- datalist[i]
# filename
###

###
name_traj_part1 = paste(input_directory,"wp_part_01_02_trial_02.csv",sep="" )
traj_part1 <- read.csv(file = name_traj_part1, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)
traj_part1 <- na.omit(traj_part1)

head(traj_part1, 5)

t_cf1 <- traj_part1[which(traj_part1$id == 1),]
t_cf2 <- traj_part1[which(traj_part1$id == 2),]
t_cf3 <- traj_part1[which(traj_part1$id == 3),]
t_cf4 <- traj_part1[which(traj_part1$id == 4),]
t_cf5 <- traj_part1[which(traj_part1$id == 5),]
t_cf6 <- traj_part1[which(traj_part1$id == 6),]

plot(t_cf1$x.m., t_cf1$y.m., type = "n", xlim = c(-0.3, 3.3), ylim = c(1.9, 3.7), main = "Part 1 (suggested)")

lines(t_cf1$x.m., t_cf1$y.m., col = "deeppink3", lwd = 15)
lines(t_cf2$x.m., t_cf2$y.m., col = "cyan2", lwd = 15)
lines(t_cf3$x.m., t_cf3$y.m., col = "chocolate1", lwd = 15) #
lines(t_cf4$x.m., t_cf4$y.m., col = "cornsilk3", lwd = 15) 
lines(t_cf5$x.m., t_cf5$y.m., col = "gray", lwd = 15)
lines(t_cf6$x.m., t_cf6$y.m., col = "darkseagreen1", lwd = 15) #v

head(t_cf1, 5)

###
csvname = paste(input_directory,"integrated_log_part_1_physical_exp.csv",sep="" )
data_raw <- read.csv(file = csvname, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)

data_raw <- na.omit(data_raw)
nrow(data_raw)
# data_raw <- data_raw[which(data_raw$z >= 0.48),]
# data_raw <- data_raw[-c(1:1169),]
nrow(data_raw)
head(data_raw, 5)

cf1 <- data_raw[which(data_raw$cf == 1),]
cf2 <- data_raw[which(data_raw$cf == 2),]
cf3 <- data_raw[which(data_raw$cf == 3),]
cf4 <- data_raw[which(data_raw$cf == 4),]
cf5 <- data_raw[which(data_raw$cf == 5),]
cf6 <- data_raw[which(data_raw$cf == 6),]

end_cut <- 837
end_cut_for_cf4 <- 1169
cf1 <- cf1[-c(1:end_cut),]
cf2 <- cf2[-c(1:end_cut),]
cf3 <- cf3[-c(1:end_cut),]
cf4 <- cf4[-c(1:end_cut_for_cf4),]
cf5 <- cf5[-c(1:end_cut),]
cf6 <- cf6[-c(1:end_cut),]


cf5 <- cf5[-c(6480:nrow(cf5)),]

csvname2 = paste(input_directory,"integrated_log_part_2_physical_exp.csv",sep="" )
data_raw2 <- read.csv(file = csvname2, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)

data_raw2 <- na.omit(data_raw2)
nrow(data_raw2)
# data_raw <- data_raw[which(data_raw$z >= 0.48),]
# data_raw <- data_raw[-c(1:1169),]
nrow(data_raw2)
head(data_raw2, 5)

cf1.2 <- data_raw2[which(data_raw2$cf == 1),]
cf2.2 <- data_raw2[which(data_raw2$cf == 2),]
cf3.2 <- data_raw2[which(data_raw2$cf == 3),]
cf4.2 <- data_raw2[which(data_raw2$cf == 4),]
cf5.2 <- data_raw2[which(data_raw2$cf == 5),]
cf6.2 <- data_raw2[which(data_raw2$cf == 6),]

#end_cut <- 600
#end_cut_for_cf4 <- 600
cf1.2 <- cf1.2[-c(1:800),]
cf2.2 <- cf2.2[-c(1:500),]
cf3.2 <- cf3.2[-c(1:680),]
cf4.2 <- cf4.2[-c(1:880),]
cf5.2 <- cf5.2[-c(1:850),]
cf6.2 <- cf6.2[-c(1:760),]

#1
cf1.dif.x <- cf1[nrow(cf1),]$x - cf1.2[1,]$x
cf1.dif.y <- cf1[nrow(cf1),]$y - cf1.2[1,]$y

cf1.2.new.x <- cf1.2$x + cf1.dif.x
cf1.2.new.y <- cf1.2$y + cf1.dif.y - 0.05

#2
cf2.dif.x <- cf2[nrow(cf2),]$x - cf2.2[1,]$x
cf2.dif.y <- cf2[nrow(cf2),]$y - cf2.2[1,]$y

cf2.2.new.x <- cf2.2$x + cf2.dif.x
cf2.2.new.y <- cf2.2$y + cf2.dif.y - 0.05

#3
cf3.dif.x <- cf3[nrow(cf3),]$x - cf3.2[1,]$x
cf3.dif.y <- cf3[nrow(cf3),]$y - cf3.2[1,]$y

cf3.2.new.x <- cf3.2$x + cf3.dif.x -0.02
cf3.2.new.y <- cf3.2$y + cf3.dif.y

#4
cf4.dif.x <- cf4[nrow(cf4),]$x - cf4.2[1,]$x
cf4.dif.y <- cf4[nrow(cf4),]$y - cf4.2[1,]$y

cf4.2.new.x <- cf4.2$x + cf4.dif.x + 0.04
cf4.2.new.y <- cf4.2$y + cf4.dif.y + 0.06

#5
cf5.dif.x <- cf5[nrow(cf5),]$x - cf5.2[1,]$x
cf5.dif.y <- cf5[nrow(cf5),]$y - cf5.2[1,]$y

cf5.2.new.x <- cf5.2$x + cf5.dif.x + 0.13
cf5.2.new.y <- cf5.2$y + cf5.dif.y + 0.01

#6
cf6.dif.x <- cf6[nrow(cf6),]$x - cf6.2[1,]$x
cf6.dif.y <- cf6[nrow(cf6),]$y - cf6.2[1,]$y

cf6.2.new.x <- cf6.2$x + cf6.dif.x - 0.1
cf6.2.new.y <- cf6.2$y + cf6.dif.y + 0.13


lines(as.numeric(as.matrix(cf6$x)), as.numeric(as.matrix(cf6$y)), col = "green", lwd = 5) #
lines(as.numeric(as.matrix(cf6.2.new.x)), as.numeric(as.matrix(cf6.2.new.y)), col = "green", lwd = 5)

lines(as.numeric(as.matrix(cf1$x)), as.numeric(as.matrix(cf1$y)), col = "red", lwd = 5)
lines(as.numeric(as.matrix(cf1.2.new.x)), as.numeric(as.matrix(cf1.2.new.y)), col = "red", lwd = 5)

lines(as.numeric(as.matrix(cf2$x)), as.numeric(as.matrix(cf2$y)), col = "blue", lwd = 5)
lines(as.numeric(as.matrix(cf2.2.new.x)), as.numeric(as.matrix(cf2.2.new.y)), col = "blue", lwd = 5)

lines(as.numeric(as.matrix(cf3$x)), as.numeric(as.matrix(cf3$y)), col = "brown", lwd = 5) #
lines(as.numeric(as.matrix(cf3.2.new.x)), as.numeric(as.matrix(cf3.2.new.y)), col = "brown", lwd = 5)

lines(as.numeric(as.matrix(cf4$x)), as.numeric(as.matrix(cf4$y)), col = "orange", lwd = 5)
lines(as.numeric(as.matrix(cf4.2.new.x)), as.numeric(as.matrix(cf4.2.new.y)), col = "orange", lwd = 5)

lines(as.numeric(as.matrix(cf5$x)), as.numeric(as.matrix(cf5$y)), col = "black", lwd = 5)
lines(as.numeric(as.matrix(cf5.2.new.x)), as.numeric(as.matrix(cf5.2.new.y)), col = "black", lwd = 5)






#adj_x = 0.0
#adj_y = 0.0
#length(cf1$x)
# plot(cf1$x, cf1$y, type = "n", col = "red")


point_1_idx <- 1000
point_1 <- rbind(cf1[point_1_idx,], cf2[point_1_idx,], cf3[point_1_idx,], cf4[point_1_idx,], cf5[point_1_idx,], cf6[point_1_idx,])
point_1_idx <- 2000
point_2 <- rbind(cf1[point_1_idx,], cf2[point_1_idx,], cf3[point_1_idx,], cf4[point_1_idx,], cf5[point_1_idx,], cf6[point_1_idx,])
point_1_idx <- 3000
point_3 <- rbind(cf1[point_1_idx,], cf2[point_1_idx,], cf3[point_1_idx,], cf4[point_1_idx,], cf5[point_1_idx,], cf6[point_1_idx,])
point_1_idx <- 4000
point_4 <- rbind(cf1[point_1_idx,], cf2[point_1_idx,], cf3[point_1_idx,], cf4[point_1_idx,], cf5[point_1_idx,], cf6[point_1_idx,])
point_1_idx <- 5000
point_5 <- rbind(cf1[point_1_idx,], cf2[point_1_idx,], cf3[point_1_idx,], cf4[point_1_idx,], cf5[point_1_idx,], cf6[point_1_idx,])
point_1_idx <- 6000
point_6 <- rbind(cf1[point_1_idx,], cf2[point_1_idx,], cf3[point_1_idx,], cf4[point_1_idx,], cf5[point_1_idx,], cf6[point_1_idx,])


# lines(as.numeric(as.matrix(point_1$x)), as.numeric(as.matrix(point_1$y)), lty = 2, col = "black", lwd = 2) #
# lines(as.numeric(as.matrix(point_2$x)), as.numeric(as.matrix(point_2$y)), lty = 3, col = "black", lwd = 2) #
# lines(as.numeric(as.matrix(point_3$x)), as.numeric(as.matrix(point_3$y)), lty = 4, col = "black", lwd = 2) #

# points(as.numeric(as.matrix(point_1$x)), as.numeric(as.matrix(point_1$y)), pch = "1", col = "red", cex = 2) #
# points(as.numeric(as.matrix(point_2$x)), as.numeric(as.matrix(point_2$y)), pch = "2", col = "blue", cex = 2) #
# points(as.numeric(as.matrix(point_3$x)), as.numeric(as.matrix(point_3$y)), pch = "3", col = "green", cex = 2) #
# points(as.numeric(as.matrix(point_4$x)), as.numeric(as.matrix(point_4$y)), pch = "4", col = "brown", cex = 2) #
# points(as.numeric(as.matrix(point_5$x)), as.numeric(as.matrix(point_5$y)), pch = "5", col = "black", cex = 2) #
# points(as.numeric(as.matrix(point_6$x)), as.numeric(as.matrix(point_6$y)), pch = "6", col = "orange", cex = 2) #


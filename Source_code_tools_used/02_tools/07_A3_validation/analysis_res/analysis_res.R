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
library("shotGroups")
# source("C:/Users/Chijung Jung/source/R_project/lib/functions.R")
source("~/Research/tool_project_swarm_safety/lib/functions.R") # Linux version

set.seed(1)


##############
# configurations
##############
param.mode.savePlot <- TRUE
# directory for input 
# base_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/00_00_randomtesting/",sep="" )
# csv_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing/pre/",sep="" )

output_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/3rd_alg/analysis_res/output/",sep="" )

##############
# Reading data
# refer: https://lightblog.tistory.com/13
# factor, refer: https://rfriend.tistory.com/32
# which, refer: http://egloos.zum.com/entireboy/v/4837061
##############
# datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/incremental/input")
datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/3rd_alg/analysis_res/input")

# datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing")
datalist #seed_1_150_Ix2.0_new_restriction
i <- 1
filename <- datalist[i]
# filename = "crash_rt_from_various_var.txt"
filename = "new_profiling_original_coor.csv"

# csvname = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing/",filename,sep="" )
csvname = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/3rd_alg/analysis_res/input/",filename,sep="" )

data_raw <- read.csv(file = csvname, header = FALSE, fileEncoding="UTF-8-BOM", as.is = 1, sep = ",")
nrow(data_raw)


head(data_raw, 5)


head(data_raw[which(data_raw$V1 == 'this'),], 5)
head(data_raw[which(data_raw$V1 == 'this')+1,], 5)

nrow(data_raw[which(data_raw$V1 == 'this'),])
nrow(data_raw[which(data_raw$V1 == 'this')+1,])

# final_analysis = data_raw[which(data_raw$V1 == 'this'),]
# for(i in 1:10){
#   next_of_iteration = data_raw[which(data_raw$V1 == 'this') + i,]  
#   final_analysis = cbind(final_analysis, next_of_iteration)
# }
iteration_name = data_raw[which(data_raw$V1 == 'this'),]
next_of_iteration = data_raw[which(data_raw$V1 == 'this')+1,]

final_analysis = cbind(iteration_name, next_of_iteration)

output_file = paste(output_directory, "final_analysis_02.csv", sep = "")

write.csv(final_analysis,output_file, row.names = FALSE)

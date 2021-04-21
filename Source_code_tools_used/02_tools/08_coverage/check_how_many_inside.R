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
# source("C:/Users/Chijung Jung/source/R_project/lib/functions.R")
source("~/Research/tool_project_swarm_safety/lib/functions.R") # Linux version

set.seed(1)


temp.fct.plotting <- function(l_sp,l_sp_c_hull,target_l_sp, plotname){
  plot(c(l_sp[,1],target_l_sp[,1]),c(l_sp[,2],target_l_sp[,2]), pch = 18, xlab="x", ylab="y", main = plotname)
  
  points(l_sp, col = "blue", pch = 18)
  points(target_l_sp, col = "red", pch = 18)
  lines(l_sp_c_hull, type = "l", lty = 2, col = "black") 
}

##############
# configurations: standard: 0.03 / 2
##############
# param.mode.savePlot <- TRUE
# param.dist_criteria <- 0.02
# param.neighborNum_criteria <- 2
# param.required_subset_size_rate <- 0.7
# param.delta <- 0.1
param.mode.savePlot = TRUE



##############
# Reading data
##############

target_diretory <- paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/03_01_count_inside_points/target/",sep="" )
target_file <- paste(target_diretory, "randomized_r_x2.0_rollback_0.csv", sep = "")
target_data <- read.csv(file = target_file, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)


polygon_data_directory <- paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/03_01_count_inside_points/polygon/", sep="")
polygon_data_directory <- paste(polygon_data_directory,"5_integrated/", sep="")
polygon_data_directory <- paste(polygon_data_directory,"r/", sep="")
datalist <- list.files(path = polygon_data_directory)

# endLoop <- 1

endLoop <- length(datalist)


for(i in 1: endLoop){   #length(datalist)){
  
  ##############
  # configurations: initialization
  ##############
  # param.dist_criteria <- 0.02
  # param.neighborNum_criteria <- 2
  # param.required_subset_size_rate <- 0.7
  # param.delta <- 0.1
  # i <- 1
  
  filename <- datalist[i]
  #if(param.mode.savePlot == TRUE) {filename <- datalist[i]}
  #else{filename <- datalist[29]}
  outputplotdir <- paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/02_01_output_plot/",filename,".png",sep="" )
  if(param.mode.savePlot == TRUE) {png(outputplotdir, width = 385, height = 721, units = "px")}
  # directory = paste("C:/Users/Chijung Jung/source/R_project/project_swarm_model_data/data/02_01_output_plot/",filename,".png",sep="" )
  # if(param.mode.savePlot == TRUE) {png(directory, width = 385, height = 721, units = "px")}
  
  csvname = paste(polygon_data_directory,filename,sep="" )
  data_raw <- read.csv(file = csvname, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)
  
  # data_raw2 <- subset(data_raw, data_raw[,1]!="#DIV/0!")
  # preprocessed_csvname = paste(csvname,"_preprocessed.csv",sep="")
  # write.csv(data_raw2, file = preprocessed_csvname, row.names = FALSE)
  
  # preprocessed_data <- read.csv(file = preprocessed_csvname, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)
  
  
  
  # cat("[sys][log]rate(nocrash/total):",filename," | ", nrow(data_raw2[i]), "\n" )
  
  
  ################
  # Pre-processing
  ################
  
  l_sp <- data_raw[,c(1:2)]
  f1_sp <- data_raw[,c(3:4)] #f1.x, f1.y
  f2_sp <- data_raw[,c(5:6)] #f2.x, f2.y
  f3_sp <- data_raw[,c(7:8)] #f3.x, f3.y
  # f1_sp <- f1_sp[rowSums((is.na(f1_sp))) != ncol(f1_sp),]
  # f2_sp <- f2_sp[rowSums((is.na(f2_sp))) != ncol(f2_sp),]
  # f3_sp <- f3_sp[rowSums((is.na(f3_sp))) != ncol(f3_sp),]

  
  ##############
  # Convex hull
  # refer: https://astrostatistics.psu.edu/datasets/R/html/graphics/html/chull.html
  ##############
  
  #making a line: before prunned
  l_sp_c_hull_index <- fct.make_convex_hull(l_sp)
  f1_sp_c_hull_index <- fct.make_convex_hull(f1_sp)
  f2_sp_c_hull_index <- fct.make_convex_hull(f2_sp)
  f3_sp_c_hull_index <- fct.make_convex_hull(f3_sp)
  
  l_sp_c_hull <- l_sp[l_sp_c_hull_index, ]
  f1_sp_c_hull <- f1_sp[f1_sp_c_hull_index, ]
  f2_sp_c_hull <- f2_sp[f2_sp_c_hull_index, ]
  f3_sp_c_hull <- f3_sp[f3_sp_c_hull_index, ]
  
  
  
  target_l_sp <- target_data[,c(1:2)]
  target_f1_sp <- target_data[,c(3:4)]
  target_f2_sp <- target_data[,c(5:6)]
  target_f3_sp <- target_data[,c(7:8)]
  
  l_inner_points <- inpolygon(target_l_sp[,1], target_l_sp[,2], l_sp_c_hull[,1], l_sp_c_hull[,2], boundary = TRUE)   # TRUE
  f1_inner_points <- inpolygon(target_f1_sp[,1], target_f1_sp[,2], f1_sp_c_hull[,1], f1_sp_c_hull[,2], boundary = TRUE)   # TRUE
  f2_inner_points <- inpolygon(target_f2_sp[,1], target_f2_sp[,2], f2_sp_c_hull[,1], f2_sp_c_hull[,2], boundary = TRUE)   # TRUE
  f3_inner_points <- inpolygon(target_f3_sp[,1], target_f3_sp[,2], f3_sp_c_hull[,1], f3_sp_c_hull[,2], boundary = TRUE)   # TRUE
  
  l_rate <- length(l_inner_points[l_inner_points == TRUE]) / nrow(target_l_sp)
  f1_rate <- length(f1_inner_points[f1_inner_points == TRUE]) / nrow(target_f1_sp) 
  f2_rate <- length(f2_inner_points[f2_inner_points == TRUE]) / nrow(target_f2_sp)
  f3_rate <- length(f3_inner_points[f3_inner_points == TRUE]) / nrow(target_f3_sp)
  
  cat(filename,", l_rate: ",l_rate," ,f1_rate: ",f1_rate," ,f2_rate: ",f2_rate," ,f3_rate: ",f3_rate,"\n")
  
  temp.fct.plotting(l_sp, l_sp_c_hull, target_l_sp, "l")
  temp.fct.plotting(f1_sp, f1_sp_c_hull, target_f1_sp, "f1")
  temp.fct.plotting(f2_sp, f2_sp_c_hull, target_f2_sp, "f2")
  # temp.fct.plotting(f3_sp, f3_sp_c_hull, target_f3_sp, "f3")
  # plotting

  if(param.mode.savePlot == TRUE){dev.off()}
}




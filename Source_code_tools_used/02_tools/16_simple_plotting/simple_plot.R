# After checking whether plot has no problem, remove v1.
##############
# Initializing
# tips: ctrl + shft + c: comment selected lines
# refer for plotting: https://www.statmethods.net/advgraphs/parameters.html
##############

rm(list = ls())
library(plyr)
library(readr)
library(scales)
# library(plyr)
library(conicfit) #library(concaveman)
library(geometry)
library(retistruct)
# source("C:/Users/Chijung Jung/source/R_project/lib/functions.R") 
source("~/Research/tool_project_swarm_safety/lib/functions.R") # Linux version
set.seed(1)


##############
# configurations
##############
# param.culumn_O_remove <- c(16,17,20,21) # <-  1stO.x     1stO.y     2ndO.x   2ndO.y
# param.culumn_etc_remove <- c(1:7)
param.rand = TRUE
param.randmode = 'meanpoint' #eachpoint
param.plotmode = FALSE
param.mode.savePlot = TRUE

# base directory
base_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/00_00_randomtesting/",sep="" )
# directory for input 
input_directory = paste(base_directory,"output/randomized/",sep="" )
input_directory_randomized_data = paste(input_directory,"5/",sep="" )
# directory for output
# output_directory_randomized_data = paste(base_directory,"output/randomized/",sep="" )
# output_directory_aligned_data = paste(base_directory,"output/aligned/",sep="" )

# directory for plot-output
output_directory_plot = paste(base_directory,"output/plot/",sep="" )


##############
# Reading data
# refer: https://lightblog.tistory.com/13
# factor, refer: https://rfriend.tistory.com/32
# which, refer: http://egloos.zum.com/entireboy/v/4837061
##############
datalist <- list.files(path = input_directory_randomized_data)



# for loop
endLoop <- length(datalist)
for(i in 1: endLoop){
  # i <- 1
  filename <- datalist[i]
  
  
  csvname = paste(input_directory_randomized_data,filename,sep="" )
  # this aligned data has header that came from preprocessing, so set header = TRUE
  data_raw <- read.csv(file = csvname, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)
  
  plotfilename = paste(output_directory_plot, filename,".png",sep="" )
  if(param.mode.savePlot == TRUE) {png(plotfilename, width = 500, height = 500, units = "px")}
  
  fct.plotting(data_raw, filename, c(-1, 1), c(-2.6, -1.2))
  
  # plot(c(f1_sp[,1],f2_sp[,1],f3_sp[,1]),c(f1_sp[,2],f2_sp[,2],f3_sp[,2]), pch = 18, xlab="x", ylab="y", main = filename)
  
  
  if(param.mode.savePlot == TRUE){dev.off()}
  
}









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


##############
# configurations: standard: 0.03 / 2
##############
param.mode.savePlot <- TRUE
# param.dist_criteria <- 0.03
# param.neighborNum_criteria <- 2
# param.required_subset_size_rate <- 0.7


##############
# Reading data
# remove special characters, refer: https://stackoverrun.com/ko/q/3202461
##############

# directory for input 
datalist <- list.files(path = "C:/Users/Chijung Jung/source/R_project/project_swarm_model_data/data/01_01_input_regular_01")

endLoop <- 1
if(param.mode.savePlot == TRUE) {endLoop <- length(datalist)}


for(i in 1: endLoop){
  
  
  filename <- datalist[i]
  
  csvname = paste("C:/Users/Chijung Jung/source/R_project/project_swarm_model_data/data/01_01_input_regular_01/",filename,sep="" )
  data_raw <- read.csv(file = csvname, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)
  data_raw$data_raw_preproc_1.modi_start <- as.numeric(gsub("[^[:alnum:]///' ]", "", data_raw$data_raw_preproc_1.modi_start))
  
  
  crash_case <- data_raw[data_raw$crash==TRUE,]
  crash_after_modi <- crash_case[which( crash_case$data_raw_preproc_1.modi_start < crash_case$when),]
  crash_before_modi <- crash_case[which( crash_case$data_raw_preproc_1.modi_start > crash_case$when),]
  
  
  rate <- nrow(crash_case) /nrow(data_raw)
  rate.before <- nrow(crash_before_modi) /nrow(data_raw)
  rate.after <- nrow(crash_after_modi) /nrow(data_raw)
  
  cat("[sys][log]rate(nocrash/total):",filename,"(before/after) | ",
      rate,"(",rate.before,",",rate.after,") = ",
      nrow(crash_case),"(",nrow(crash_before_modi),",",nrow(crash_after_modi),") / ",nrow(data_raw), "\n" )
  
  
  
  
}





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
library(tidyverse) # https://kuduz.tistory.com/1231
# source("C:/Users/Chijung Jung/source/R_project/lib/functions.R") 
source("~/Research/tool_project_swarm_safety/lib/functions.R") # Linux version
set.seed(1)


##############
# configurations
##############
# param.culumn_O_remove <- c(16,17,20,21) # <-  1stO.x     1stO.y     2ndO.x   2ndO.y
# param.culumn_etc_remove <- c(1:7)
param.rand = TRUE
param.randmode = 'hybrid' #eachpoint, meanpoint, hybrid
param.plotmode = FALSE
param.coef.v1 = 1.0
param.coef.v2 = 1.0
param.coef.v3 = 1.0
param.coef.v4 = 2.593742

# base directory
base_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/00_00_randomtesting/",sep="" )
# directory for input 
input_directory = paste(base_directory,"input/",sep="" )
input_directory_aligned_data = paste(base_directory,"input/aligned/",sep="" )
# directory for output
output_directory_randomized_data = paste(base_directory,"output/randomized/",sep="" )
output_directory_randomized_data = paste(output_directory_randomized_data,"5_integrated/",sep="" )
output_directory_aligned_data = paste(base_directory,"output/aligned/",sep="" )

##############
# Reading data
# refer: https://lightblog.tistory.com/13
# factor, refer: https://rfriend.tistory.com/32
# which, refer: http://egloos.zum.com/entireboy/v/4837061
##############
datalist <- list.files(path = input_directory_aligned_data)


# for loop
endLoop <- length(datalist)
for(i in 1: endLoop){
  # i <- 1
  filename <- datalist[i]
  
  
  csvname = paste(input_directory_aligned_data,filename,sep="" )
  # this aligned data has header that came from preprocessing, so set header = TRUE
  data_raw <- read.csv(file = csvname, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)
  
  if(param.rand == TRUE){
    # Note: one run yields one set of random data
    if(param.randmode == 'meanpoint'){
      
      randomized_table <- fct.insert_rand_v1(data_raw, nrow(data_raw), param.coef.v1)  
      # for double
      # randomized_table <- rbind(randomized_table, fct.insert_rand_v1(data_raw, nrow(data_raw))  )
      
    }else if(param.randmode == 'eachpoint'){
      
      randomized_table_r <- fct.insert_rand_v2(data_raw, nrow(data_raw), param.coef.v2)
      randomized_table_ex <- fct.expand(randomized_table_r, param.coef.v4)
      
      randomized_table_r2 <- fct.insert_rand_v2(data_raw, nrow(data_raw), param.coef.v2)
      randomized_table_ex2 <- fct.expand(randomized_table_r2, param.coef.v4)
      
      randomized_table_r3 <- fct.insert_rand_v2(data_raw, nrow(data_raw), param.coef.v2)
      randomized_table_ex3 <- fct.expand(randomized_table_r3, param.coef.v4)
      
      randomized_table <- rbind(randomized_table_ex, randomized_table_ex2)
      
      
      
      # for double
      # randomized_table <- rbind(randomized_table, fct.insert_rand_v1(data_raw, nrow(data_raw))  )
      
    }else if(param.randmode == 'hybrid'){
      randomized_table1 <- fct.insert_rand_v1(data_raw, nrow(data_raw), param.coef.v1)
      # for double
      # randomized_table1 <- rbind(randomized_table1, fct.insert_rand_v1(data_raw, nrow(data_raw)))
      
      # randomized_table2 <- fct.insert_rand_v2(data_raw, nrow(data_raw), param.coef.v2)
      randomized_table2 <- fct.insert_rand_v3(data_raw, nrow(data_raw), param.coef.v3)
      # for double
      # randomized_table2 <- rbind(randomized_table2, fct.insert_rand_v2(data_raw, nrow(data_raw)))
      
      randomized_table <- rbind(randomized_table1, randomized_table2)
      randomized_table <- fct.expand(randomized_table, param.coef.v4)
    }

  }else{
    randomized_table <- data_raw
  }
  
  if(param.plotmode == TRUE){
    fct.plotting(randomized_table, 'randomized_table')
  }
  
  ###
  # randomized_table should be set as perfect form in advance (before here)
  ###
  
  # 1. rotate inversely: using negative theta
  
  table_rotated <- fct.reverse_rotate_shift(randomized_table, -data_raw$theta)
  if(param.plotmode == TRUE){
    fct.plotting(table_rotated, 'table_rotated')
  }
  # 2. shift: using the original leader's coordinate
  table_shifted <- fct.reverse_align_based_on_leader(table_rotated, data_raw$origin_l.x, data_raw$origin_l.y)
  if(param.plotmode == TRUE){
    fct.plotting(table_shifted, 'table_shifted')
  }
  # 3. write into file
  if(str_detect(filename, 'r_')){
    output_directory_randomized_data1 <- paste(output_directory_randomized_data, "r/", sep="")
  }else if(str_detect(filename, 'a_')){
    output_directory_randomized_data1 <- paste(output_directory_randomized_data, "a/", sep="")
  }else if(str_detect(filename, 'i_')){
    output_directory_randomized_data1 <- paste(output_directory_randomized_data, "i/", sep="")
  }else if(str_detect(filename, 'b_')){
    output_directory_randomized_data1 <- paste(output_directory_randomized_data, "b/", sep="")
  }
  table_final_name = paste(output_directory_randomized_data1, "randomized_",filename,sep="")
  write.csv(table_shifted, file = table_final_name, row.names = FALSE) 
  
}






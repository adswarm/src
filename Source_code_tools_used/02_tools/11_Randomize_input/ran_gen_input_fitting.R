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
# configurations
##############
# param.culumn_O_remove <- c(16,17,20,21) # <-  1stO.x     1stO.y     2ndO.x   2ndO.y
# param.culumn_etc_remove <- c(1:7)
param.targetparam = 'r_x2.0'
param.mode.savePlot = TRUE
param.rand = TRUE
param.randmode = 'hybrid' #eachpoint, meanpoint, hybrid
param.plotmode = FALSE
param.coef.v1 = 1.0
param.coef.v2 = 1.0
param.coef.v3 = 1.0
param.coef.v4 = 1.0

# base directory
base_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/00_00_randomtesting/",sep="" )
# directory for input 
input_directory = paste(base_directory,"input/",sep="" )
input_directory_aligned_data = paste(base_directory,"input/aligned/",sep="" )
# directory for output
output_directory_randomized_data = paste(base_directory,"output/randomized/",sep="" )
output_directory_randomized_data = paste(output_directory_randomized_data,"5_ex/",sep="" )
output_directory_aligned_data = paste(base_directory,"output/aligned/",sep="" )


target_diretory <- paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/03_01_count_inside_points/target/",sep="" )
target_file <- paste(target_diretory, "randomized_r_x2.0_rollback_0.csv", sep = "")
target_data <- read.csv(file = target_file, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)


##############
# Reading data
# refer: https://lightblog.tistory.com/13
# factor, refer: https://rfriend.tistory.com/32
# which, refer: http://egloos.zum.com/entireboy/v/4837061
##############
datalist <- list.files(path = input_directory_aligned_data)
datalist <- datalist[str_detect(datalist, param.targetparam)]
                     
# data_rate <- c()

# for loop
endLoop <- length(datalist)

# endLoop <- 2



repeat{
  data_rate <- c()   
  data_area_rate <- c()
  
  
  for(i in 1: endLoop){
     
    
    # i <- 1
    filename <- datalist[i]
    
    outputplotdir <- paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/02_01_output_plot/",filename,".png",sep="" )
    if(param.mode.savePlot == TRUE) {png(outputplotdir, width = 500, height = 500, units = "px")}
    
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
        # randomized_table1 <- rbind(randomized_table1, fct.insert_rand_v1(data_raw, nrow(data_raw), param.coef.v1))
        
        randomized_table2 <- fct.insert_rand_v2(data_raw, nrow(data_raw), param.coef.v2)
        # randomized_table2 <- fct.insert_rand_v3(data_raw, nrow(data_raw), param.coef.v3)
        # for double
        # randomized_table2 <- rbind(randomized_table2, fct.insert_rand_v2(data_raw, nrow(data_raw), param.coef.v2))
        # randomized_table2 <- rbind(randomized_table2, fct.insert_rand_v2(data_raw, nrow(data_raw), param.coef.v2))
        
        randomized_table <- rbind(randomized_table1, randomized_table2)
        
        randomized_table <- fct.expand(randomized_table, param.coef.v4)
      }
      
    }else{
      randomized_table <- data_raw
    }
    
    if(param.plotmode == TRUE){
      fct.plotting(randomized_table, 'randomized_table')
    }
    
    
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
    
    
    polygon_data <- table_shifted
    
    l_sp <- polygon_data[,c(1:2)]
    f1_sp <- polygon_data[,c(3:4)] #f1.x, f1.y
    f2_sp <- polygon_data[,c(5:6)] #f2.x, f2.y
    f3_sp <- polygon_data[,c(7:8)] #f3.x, f3.y
    
    
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
    
    
    data_rate <- rbind(data_rate, c(l_rate, f1_rate, f2_rate, f3_rate))
  
    
    
    
    
    
    target_l_sp_c_hull_index <- fct.make_convex_hull(target_l_sp)
    target_f1_sp_c_hull_index <- fct.make_convex_hull(target_f1_sp)
    target_f2_sp_c_hull_index <- fct.make_convex_hull(target_f2_sp)
    target_f3_sp_c_hull_index <- fct.make_convex_hull(target_f3_sp)
    
    target_l_sp_c_hull <- target_l_sp[target_l_sp_c_hull_index, ]
    target_f1_sp_c_hull <- target_f1_sp[target_f1_sp_c_hull_index, ]
    target_f2_sp_c_hull <- target_f2_sp[target_f2_sp_c_hull_index, ]
    target_f3_sp_c_hull <- target_f3_sp[target_f3_sp_c_hull_index, ]
    
    
    l_area_rate <- polyarea(target_l_sp_c_hull[,1],target_l_sp_c_hull[,2]) / polyarea(l_sp_c_hull[,1],l_sp_c_hull[,2])
    f1_area_rate <- polyarea(target_f1_sp_c_hull[,1],target_f1_sp_c_hull[,2]) / polyarea(f1_sp_c_hull[,1],f1_sp_c_hull[,2])
    f2_area_rate <- polyarea(target_f2_sp_c_hull[,1],target_f2_sp_c_hull[,2]) / polyarea(f2_sp_c_hull[,1],f2_sp_c_hull[,2])
    f3_area_rate <- polyarea(target_f3_sp_c_hull[,1],target_f3_sp_c_hull[,2]) / polyarea(f3_sp_c_hull[,1],f3_sp_c_hull[,2])
    
    data_area_rate <- rbind(data_area_rate, c(l_area_rate, f1_area_rate, f2_area_rate, f3_area_rate))
    
    temp.fct.plotting(l_sp, l_sp_c_hull, target_l_sp, "l")
    lines(target_l_sp_c_hull, type = "l", lty = 2, col = "black")
    
    # temp.fct.plotting(f1_sp, f1_sp_c_hull, target_f1_sp, "f1")
    # lines(target_f1_sp_c_hull, type = "l", lty = 2, col = "black")
    
    
    # temp.fct.plotting(f2_sp, f2_sp_c_hull, target_f2_sp, "f2")
    # lines(target_f2_sp_c_hull, type = "l", lty = 2, col = "black")
    
    # temp.fct.plotting(f3_sp, f3_sp_c_hull, target_f3_sp, "f3")
    # lines(target_f3_sp_c_hull, type = "l", lty = 2, col = "black")
    
    

    
    
    
    # # 3. write into file
    # if(str_detect(filename, 'r_')){
    #   output_directory_randomized_data1 <- paste(output_directory_randomized_data, "r/", sep="")
    # }else if(str_detect(filename, 'a_')){
    #   output_directory_randomized_data1 <- paste(output_directory_randomized_data, "a/", sep="")
    # }else if(str_detect(filename, 'i_')){
    #   output_directory_randomized_data1 <- paste(output_directory_randomized_data, "i/", sep="")
    # }else if(str_detect(filename, 'b_')){
    #   output_directory_randomized_data1 <- paste(output_directory_randomized_data, "b/", sep="")
    # }
    # table_final_name = paste(output_directory_randomized_data1, "randomized_",filename,sep="")
    # write.csv(table_shifted, file = table_final_name, row.names = FALSE) 
    if(param.mode.savePlot == TRUE){dev.off()}
  }
  
  # if(f1_rate < 1.0 || f2_rate < 1.0 || f3_rate < 1.0){
  
  if(mean(data_rate[c(2,3,4,5,6,7,9,10),2]) < 1.0){
    param.coef.v4 <- param.coef.v4 * 1.1
    cat("final param.coef.v4 is ", param.coef.v4, "\n")
    
  }else{
    
    break
  }
}








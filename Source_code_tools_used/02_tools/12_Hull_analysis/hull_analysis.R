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
# source("C:/Users/Chijung Jung/source/R_project/lib/functions.R")
source("~/Research/tool_project_swarm_safety/lib/functions.R") # Linux version
source("~/Research/tool_project_swarm_safety/Preprocessing_R/possible_space/possible_space.R") # Linux version

set.seed(1)


##############
# configurations: standard: 0.03 / 2
##############
param.mode.savePlot <- TRUE
param.dist_criteria <- 0.02
param.neighborNum_criteria <- 2
param.required_subset_size_rate <- 0.7
param.delta <- 0.1


##############
# Reading data
##############
datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_01_input_regular_01")

endLoop <- 1
if(param.mode.savePlot == TRUE) {endLoop <- length(datalist)}


for(i in 1: endLoop){   #length(datalist)){
  
  ##############
  # configurations: initialization
  ##############
  param.dist_criteria <- 0.02
  param.neighborNum_criteria <- 2
  param.required_subset_size_rate <- 0.7
  param.delta <- 0.1
  
  # i = 1
  filename <- datalist[i]
  #if(param.mode.savePlot == TRUE) {filename <- datalist[i]}
  #else{filename <- datalist[29]}
  
  directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/02_01_output_plot/",filename,".png",sep="" )
  if(param.mode.savePlot == TRUE) {png(directory, width = 500, height = 500, units = "px")}
  
  csvname = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_01_input_regular_01/",filename,sep="" )
  data_raw <- read.csv(file = csvname, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)
  
  # data_raw2 <- subset(data_raw, data_raw[,1]!="#DIV/0!")
  # preprocessed_csvname = paste(csvname,"_preprocessed.csv",sep="")
  # write.csv(data_raw2, file = preprocessed_csvname, row.names = FALSE)

  # preprocessed_data <- read.csv(file = preprocessed_csvname, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)
  
  
  
  # cat("[sys][log]rate(nocrash/total):",filename," | ", nrow(data_raw2[i]), "\n" )
  

  ################
  # Pre-processing
  ################
  
  f1_sp <- data_raw[,c(3:4)] #f1.x, f1.y
  f2_sp <- data_raw[,c(5:6)] #f2.x, f2.y
  f3_sp <- data_raw[,c(7:8)] #f3.x, f3.y
  f1_sp <- f1_sp[rowSums((is.na(f1_sp))) != ncol(f1_sp),]
  f2_sp <- f2_sp[rowSums((is.na(f2_sp))) != ncol(f2_sp),]
  f3_sp <- f3_sp[rowSums((is.na(f3_sp))) != ncol(f3_sp),]
  
  #########################
  # to find out outlier
  # repeat until the number of elements of new area(in new layer) becomes <param.required_subset_size_rate> of original(input) sample
  #########################
  
  repeat{
    
    f1_sp_non_outlier_index <- fct.make_non_outlier_lst(param.dist_criteria, param.neighborNum_criteria, f1_sp)
    f1_sp_after_prunned <- f1_sp[f1_sp_non_outlier_index, ]
    
    f2_sp_non_outlier_index <- fct.make_non_outlier_lst(param.dist_criteria, param.neighborNum_criteria, f2_sp)
    f2_sp_after_prunned <- f2_sp[f2_sp_non_outlier_index, ]
    
    f3_sp_non_outlier_index <- fct.make_non_outlier_lst(param.dist_criteria, param.neighborNum_criteria, f3_sp)
    f3_sp_after_prunned <- f3_sp[f3_sp_non_outlier_index, ]
    
    current_subset_size_rate <- nrow(f1_sp_after_prunned) / nrow(f1_sp) #standard is f1
    
    if(current_subset_size_rate < param.required_subset_size_rate){
      #parameter update
      param.dist_criteria <- param.dist_criteria + param.delta
      #param.neighborNum_criteria <- param.neighborNum_criteria + 1 #Not used
      # cat("[log]Plus")
    # }else if(current_subset_size_rate > param.required_subset_size_rate + 0.1){
    #   
    #   param.dist_criteria <- param.dist_criteria - param.delta
    #   cat("[log]Minus")
    }else{
      break
    }
  }
  # cat("[sys][log]final param.dist_criteria for [",filename,"]: ",param.dist_criteria, "\n" )
  
  
  f1_sp_after_prunned_mean <- c(mean(f1_sp_after_prunned[[1]]), mean(f1_sp_after_prunned[[2]]))
  f2_sp_after_prunned_mean <- c(mean(f2_sp_after_prunned[[1]]), mean(f2_sp_after_prunned[[2]]))
  f3_sp_after_prunned_mean <- c(mean(f3_sp_after_prunned[[1]]), mean(f3_sp_after_prunned[[2]]))
  
  f1_sp_after_prunned_var <- c(var(f1_sp_after_prunned[[1]]), var(f1_sp_after_prunned[[2]]))
  f2_sp_after_prunned_var <- c(var(f2_sp_after_prunned[[1]]), var(f2_sp_after_prunned[[2]]))
  f3_sp_after_prunned_var <- c(var(f3_sp_after_prunned[[1]]), var(f3_sp_after_prunned[[2]]))
  
  cat("[log] ",filename," ",param.dist_criteria ," ", current_subset_size_rate,
      "subset's mean: ",f1_sp_after_prunned_mean," ",
      f2_sp_after_prunned_mean," ",
      f3_sp_after_prunned_mean," ",
      " var: ",f1_sp_after_prunned_var," ",
      f2_sp_after_prunned_var," ",
      f3_sp_after_prunned_var, "\n")
  
  
  
  #plotting
  
  plotname <- paste(filename," with ",param.required_subset_size_rate,"(",param.dist_criteria,",",param.neighborNum_criteria,")",sep="" )
  
  plot(c(f1_sp[,1],f2_sp[,1],f3_sp[,1]),c(f1_sp[,2],f2_sp[,2],f3_sp[,2]), pch = 18, xlab="x", ylab="y", xlim = c(-1.2, 0.4), ylim = c(-0.6, 0.8), main = plotname)
  
  #temp
  # plot(f1_sp, col = "blue", pch = 18, xlab="x", ylab="y", main = plotname)
  # plot(f2_sp, col = "brown", pch = 18, xlab="x", ylab="y", main = plotname)
  # plot(f3_sp, col = "orange", pch = 18, xlab="x", ylab="y", main = plotname)
  ###
  
  points(f1_sp, col = "blue", pch = 18)
  points(f2_sp, col = "brown", pch = 18)
  points(f3_sp, col = "orange", pch = 18)
  
  
  points(f1_sp_after_prunned, pch = 18, col = "blue")
  points(f2_sp_after_prunned, pch = 18, col = "brown")
  points(f3_sp_after_prunned, pch = 18, col = "orange")
  
  # cat("[sys][log]the number of inner points (except outliers):",nrow(f1_sp_after_prunned), "\n" )
  
  
  #############################
  # Figuring out centered Point
  # (X) center of gravity
  # (O) mean of whole data
  #############################
  
  f1_sp_mean <- c(mean(f1_sp[[1]]), mean(f1_sp[[2]]))
  f2_sp_mean <- c(mean(f2_sp[[1]]), mean(f2_sp[[2]]))
  f3_sp_mean <- c(mean(f3_sp[[1]]), mean(f3_sp[[2]]))
  
  #plotting
  points(f1_sp_mean[1], f1_sp_mean[2], col = "red")
  points(f2_sp_mean[1], f2_sp_mean[2], col = "red")
  points(f3_sp_mean[1], f3_sp_mean[2], col = "red")
  
  
  
  ##############
  # Concave hull
  #polygons <- concaveman(test_target)
  ##############
  
  
  
  ##############
  # Convex hull
  # refer: https://astrostatistics.psu.edu/datasets/R/html/graphics/html/chull.html
  ##############
  
  #making a line: before prunned
  f1_sp_c_hull_index <- fct.make_convex_hull(f1_sp)
  f2_sp_c_hull_index <- fct.make_convex_hull(f2_sp)
  f3_sp_c_hull_index <- fct.make_convex_hull(f3_sp)
  
  f1_sp_c_hull <- f1_sp[f1_sp_c_hull_index, ]
  f2_sp_c_hull <- f2_sp[f2_sp_c_hull_index, ]
  f3_sp_c_hull <- f3_sp[f3_sp_c_hull_index, ]
  
  # plotting
  lines(f1_sp_c_hull, type = "l", lty = 2, col = "blue") 
  lines(f2_sp_c_hull, type = "l", lty = 2, col = "brown") 
  lines(f3_sp_c_hull, type = "l", lty = 2, col = "orange") 
  
  
  #making a line: after prunned
  f1_sp_after_prunned_c_hull_index <- fct.make_convex_hull(f1_sp_after_prunned)
  f2_sp_after_prunned_c_hull_index <- fct.make_convex_hull(f2_sp_after_prunned)
  f3_sp_after_prunned_c_hull_index <- fct.make_convex_hull(f3_sp_after_prunned)
  
  f1_sp_after_prunned_c_hull <- f1_sp_after_prunned[f1_sp_after_prunned_c_hull_index, ]
  f2_sp_after_prunned_c_hull <- f2_sp_after_prunned[f2_sp_after_prunned_c_hull_index, ]
  f3_sp_after_prunned_c_hull <- f3_sp_after_prunned[f3_sp_after_prunned_c_hull_index, ]
  
  # plotting
  lines(f1_sp_after_prunned_c_hull, type = "l", lty = 1, col = "blue")
  lines(f2_sp_after_prunned_c_hull, type = "l", lty = 1, col = "brown")
  lines(f3_sp_after_prunned_c_hull, type = "l", lty = 1, col = "orange")
  
  # drawing possible space
  theta.1 <- 0.367173833818219 *2 
  fct.figureout_possible_space('part_of', theta.1)
  
  theta.2 <- -0.367173833818219 *2
  fct.figureout_possible_space('part_of', theta.2)
  
  ####################
  # # scaling with 00%
  ####################
  # scaled_f1_sp_c_hull <- f1_sp_c_hull
  # zeroPoint <- f1_sp_mean
  # 
  # 
  # for(index_i in 1:nrow(f1_sp_c_hull)){
  #   zeroTof1_sp <- c(f1_sp_c_hull[index_i,1] - zeroPoint[1], f1_sp_c_hull[index_i,2] - zeroPoint[2])
  #   zeroTof1_sp
  # 
  #   scale_param = 0.5
  #   scaled_f1_sp_c_hull[index_i,] <- zeroPoint + scale_param * zeroTof1_sp
  # 
  # }
  # #plotting
  # lines(scaled_f1_sp_c_hull, col = "black", lty = 2)
  
  #TODO
  ####################
  # check whether new area includes 00% of points
  ####################
  
   
  # index_list_inner = NULL
  # 
  # for(index_points in 1: nrow(f1_sp)){
  #   for(index_c_hull in 2: nrow(f1_sp_c_hull)-1){
  #     print(index_c_hull)
  #     line_01_start <- zeroPoint
  #     line_01_end <- f1_sp[index_points,] 
  #     line_02_start <- scaled_f1_sp_c_hull[index_c_hull,]
  #     line_02_end <- scaled_f1_sp_c_hull[index_c_hull+1,]
  #     
  #     intersection_point <- line.line.intersection(line_01_start, line_01_end, line_02_start, line_02_end)
  #     if (intersection_point[1] != Inf){
  #       print("inner point!")
  #       index_list_inner = c(index_list_inner, index_points)
  #     }    
  # 
  #   }  
  # }
  # 
  # inner_points_list_f1 <- f1_sp[index_points,]
  # plot(inner_points_list_f1, col = "red")
  
  
  
  
  
  ##############
  # fitting to ellipse
  ##############
  
  # #making a ellipse
  # f1_ellipTaubin <- EllipseFitByTaubin(f1_sp_c_hull)
  # f1_ellipTaubinG <- AtoG(f1_ellipTaubin)$ParG
  # f1_xyTaubin<-calculateEllipse(f1_ellipTaubinG[1], f1_ellipTaubinG[2], f1_ellipTaubinG[3],
  #                               f1_ellipTaubinG[4], 180/pi*f1_ellipTaubinG[5])
  # 
  # f2_ellipTaubin <- EllipseFitByTaubin(f2_sp_c_hull)
  # f2_ellipTaubinG <- AtoG(f2_ellipTaubin)$ParG
  # f2_xyTaubin<-calculateEllipse(f2_ellipTaubinG[1], f2_ellipTaubinG[2], f2_ellipTaubinG[3],
  #                               f2_ellipTaubinG[4], 180/pi*f2_ellipTaubinG[5])
  # 
  # f3_ellipTaubin <- EllipseFitByTaubin(f3_sp_c_hull)
  # f3_ellipTaubinG <- AtoG(f3_ellipTaubin)$ParG
  # f3_xyTaubin<-calculateEllipse(f3_ellipTaubinG[1], f3_ellipTaubinG[2], f3_ellipTaubinG[3],
  #                               f3_ellipTaubinG[4], 180/pi*f3_ellipTaubinG[5])
  # # plotting
  # lines(f1_xyTaubin[,1],f1_xyTaubin[,2],type='l', col='blue', lty=2);par(new=TRUE)
  # lines(f2_xyTaubin[,1],f2_xyTaubin[,2],type='l', col='brown', lty=2);par(new=TRUE)
  # lines(f3_xyTaubin[,1],f3_xyTaubin[,2],type='l', col='orange', lty=2);par(new=TRUE)
  
  

  #TODO
  #center of ellipse
  
  #TODO
  #centroid of convex hull
  
  ############
  # Plotting
  # refer: https://www.r-bloggers.com/r-plot-function-the-options/
  # refer: https://www.r-graph-gallery.com/6-graph-parameters-reminder.html
  ############
  
  if(param.mode.savePlot == TRUE){dev.off()}
    
}





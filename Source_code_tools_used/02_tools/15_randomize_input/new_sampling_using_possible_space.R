##############
# Initializing
# tips: ctrl + shft + c: comment selected lines
# refer for plotting: https://www.statmethods.net/advgraphs/parameters.html
##############

rm(list = ls())
# install.packages("plyr")
# install.packages("readr")
# install.packages("conicfit")
# install.packages("geometry")

install.packages("retistruct")
install.packages("mgcv")
# install.packages("pracma")


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
source("~/Research/tool_project_swarm_safety/Preprocessing_R/possible_space/possible_space.R") # Linux version

set.seed(1)


##############
# configurations
##############
param.culumn_O_remove <- c(16,17,20,21) # <-  1stO.x     1stO.y     2ndO.x   2ndO.y
param.culumn_etc_remove <- c(1:7)
param.mode.savePlot = TRUE
mode.remove_close_coordinates = FALSE
# directory for input 
# base_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/00_00_randomtesting/",sep="" )
csv_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing/pre/",sep="" )

# base directory
base_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/00_00_randomtesting/",sep="" )
# directory for input 
# input_directory = paste(base_directory,"input/",sep="" )
# input_directory_aligned_data = paste(base_directory,"input/aligned/",sep="" )

# directory for output
output_directory_randomized_data = paste(base_directory,"output/randomized/",sep="" )
output_directory_randomized_data = paste(output_directory_randomized_data,"1000/",sep="" )
# output_directory_aligned_data = paste(base_directory,"output/aligned/",sep="" )

##############
# Reading data
# refer: https://lightblog.tistory.com/13
# factor, refer: https://rfriend.tistory.com/32
# which, refer: http://egloos.zum.com/entireboy/v/4837061
##############
datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing")

i <- 1
filename <- datalist[i]


csvname = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing/",filename,sep="" )
data_raw <- read.csv(file = csvname, header = FALSE, fileEncoding="UTF-8-BOM", as.is = 1)


colnames(data_raw) <- c("rollback", "rand_seed", "rand_seed", "modi_param", "modi_param", "vari", "from", "modi_start", "sim", "recog_time", "version", 
                        "l.x", "l.y", "f1.x", "f1.y", "f2.x", "f2.y", "f3.x", "f3.y", "1stO.x", "1stO.y", "3rdO.x", "3rdO.y", "2ndO.x", "2ndO.y",  
                        "l_g.x", "l_g.y", "f1_g.x", "f1_g.y", "f2_g.x", "f2_g.y", "f3_g.x", "f3_g.y", 
                        "crash", "who", "with", "when", "trapped")


# remove unrelevant data column

data_raw_preproc_1 <- data_raw[, -c(2, 4, 7, 9)] 
data_raw_preproc_1 <- cbind(data_raw_preproc_1, data_raw_preproc_1$modi_start)

# remove version -1, -3 and -4 data
data_raw_preproc_1 <- data_raw_preproc_1[data_raw_preproc_1$version==-2,]

# leader aligned
new_l.x <- as.numeric(as.matrix(data_raw_preproc_1$l.x)) - data_raw_preproc_1$'3rdO.x'
new_l.y <- as.numeric(as.matrix(data_raw_preproc_1$l.y)) - data_raw_preproc_1$'3rdO.y'

data_raw_preproc_2 <- cbind(data_raw_preproc_1, new_l.x, new_l.y)



# follower aligned
new_f1.x <- as.numeric(as.matrix(data_raw_preproc_1$f1.x)) - as.numeric(as.matrix(data_raw_preproc_1$l.x))
new_f1.y <- as.numeric(as.matrix(data_raw_preproc_1$f1.y)) - as.numeric(as.matrix(data_raw_preproc_1$l.y))

new_f2.x <- as.numeric(as.matrix(data_raw_preproc_1$f2.x)) - as.numeric(as.matrix(data_raw_preproc_1$l.x))
new_f2.y <- as.numeric(as.matrix(data_raw_preproc_1$f2.y)) - as.numeric(as.matrix(data_raw_preproc_1$l.y))

new_f3.x <- as.numeric(as.matrix(data_raw_preproc_1$f3.x)) - as.numeric(as.matrix(data_raw_preproc_1$l.x))
new_f3.y <- as.numeric(as.matrix(data_raw_preproc_1$f3.y)) - as.numeric(as.matrix(data_raw_preproc_1$l.y))


data_raw_preproc_2 <- cbind(data_raw_preproc_2, new_f1.x, new_f1.y, new_f2.x, new_f2.y, new_f3.x, new_f3.y)



# divide
# 알로 쪼개고
# 롤백 버전별로 쪼개고
# 0.2 2.0으로 쪼갠다


###############
####       HERE
###############

parameter_target = 'r'
target_param = paste("[", parameter_target,"]", sep="")#<--- HERE
coef_param = 2.0 #<--- HERE
rollback_ver = 160 #<--- fixed
mode_set = c('f1', 'f2', 'f3') # <--- HERE


for(mode in mode_set){
  
  # mode <- 'f1'
  r.integrated <- data_raw_preproc_2[data_raw_preproc_2$modi_param==target_param,]
  r.integrated_rb_100 <- r.integrated[r.integrated$rollback==rollback_ver,]
  r.integrated_rb_100_02 <- r.integrated_rb_100[r.integrated_rb_100$vari=="x[0.2]",]
  r.integrated_rb_100_20 <- r.integrated_rb_100[r.integrated_rb_100$vari=="x[2.0]",]
  
  target_origin <- r.integrated[r.integrated$rollback==0,]
  target_origin_02 <- target_origin[target_origin$vari=="x[0.2]",]
  target_origin_20 <- target_origin[target_origin$vari=="x[2.0]",]
  
  ################
  ### set the target_table
  
  if(coef_param == 0.2){
    target_table <- r.integrated_rb_100_02
    target_to_compare <- target_origin_02
  }else if(coef_param == 2.0){
    target_table <- r.integrated_rb_100_20
    target_to_compare <- target_origin_20
  }
  
  
  
  
  outputplotdir <- paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/02_01_output_plot/",filename,target_param,coef_param,mode,".png",sep="" )
  if(param.mode.savePlot == TRUE) {png(outputplotdir, width = 500, height = 500, units = "px")}
  
  ################
  
  
  plot(target_table$new_l.x, target_table$new_l.y)
  dist_l <- sqrt((target_table$new_l.x)^2+(target_table$new_l.y)^2)
  # max(dist_l)
  # min(dist_l)
  # 여기서 아웃라이어를 걸러줘야돼
  # 이건 스플릿 한다음에 해야겠네, 자연스럽게 통계량도 그 이후에 구해야겠다.
  # 기준 디스턴스 안에 없으면 0, 0으로 만들자. 아니야 지우자
  
  ###############
  ####       HERE
  ###############
  # for f1
  
  contribution_dist = max(dist_l) #0.3 #r x2.0
  
  
  
  if(mode == 'f1'){
    # for f1
    # list_over_dist_f1_l <- sqrt((target_table$new_f1.x)^2 + (target_table$new_f1.y)^2) > contribution_dist
    # list_over_dist_f1_f2 <- sqrt((target_table$f1.x - target_table$f2.x)^2 + (target_table$f1.y - target_table$f2.y)^2) > contribution_dist
    # list_over_dist_f1_f3 <- sqrt((target_table$f1.x - target_table$f3.x)^2 + (target_table$f1.y - target_table$f3.y)^2) > contribution_dist
    # det <- ((list_over_dist_f1_l * list_over_dist_f1_f2 * list_over_dist_f1_f3) - 1 ) * -1  
    # prunned_f1 <- target_table[as.logical(det), ]
    # list_x <- prunned_f1$new_f1.x
    # list_y <- prunned_f1$new_f1.y
    
    list_x <- target_table$new_f1.x
    list_y <- target_table$new_f1.y
    
    table_for_number <- target_table$new_f1.x
  }else if(mode == 'f2'){
    #for f2
    # list_over_dist_f2_l <- sqrt((target_table$new_f2.x)^2 + (target_table$new_f2.y)^2) > contribution_dist
    # list_over_dist_f2_f1 <- sqrt((target_table$f2.x - target_table$f1.x)^2 + (target_table$f2.y - target_table$f1.y)^2) > contribution_dist
    # list_over_dist_f2_f3 <- sqrt((target_table$f2.x - target_table$f3.x)^2 + (target_table$f2.y - target_table$f3.y)^2) > contribution_dist
    # det <- ((list_over_dist_f2_l * list_over_dist_f2_f1 * list_over_dist_f2_f3) - 1 ) * -1  
    # prunned_f1 <- target_table[as.logical(det), ]
    # list_x <- prunned_f1$new_f2.x
    # list_y <- prunned_f1$new_f2.y
    list_x <- target_table$new_f2.x
    list_y <- target_table$new_f2.y
    
    table_for_number <- target_table$new_f2.x
  }else if(mode == 'f3'){
    #for f3
    # list_over_dist_f3_l <- sqrt((target_table$new_f3.x)^2 + (target_table$new_f3.y)^2) > contribution_dist
    # list_over_dist_f3_f1 <- sqrt((target_table$f3.x - target_table$f1.x)^2 + (target_table$f3.y - target_table$f1.y)^2) > contribution_dist
    # list_over_dist_f3_f2 <- sqrt((target_table$f3.x - target_table$f2.x)^2 + (target_table$f3.y - target_table$f2.y)^2) > contribution_dist
    # det <- ((list_over_dist_f3_l * list_over_dist_f3_f1 * list_over_dist_f3_f2) - 1 ) * -1
    # prunned_f1 <- target_table[as.logical(det), ]
    # list_x <- prunned_f1$new_f3.x
    # list_y <- prunned_f1$new_f3.y
    
    list_x <- target_table$new_f3.x
    list_y <- target_table$new_f3.y
    
    table_for_number <- target_table$new_f3.x
  }else if(mode == 'l'){
    # list_over_dist_l_f1 <- sqrt((target_table$new_l.x)^2 + (target_table$new_l.y)^2) > contribution_dist
    # list_over_dist_l_f2 <- sqrt((target_table$l.x - target_table$f1.x)^2 + (target_table$f3.y - target_table$f1.y)^2) > contribution_dist
    # list_over_dist_l_f3 <- sqrt((target_table$f3.x - target_table$f2.x)^2 + (target_table$f3.y - target_table$f2.y)^2) > contribution_dist
    # 
    # det <- ((list_over_dist_f3_l * list_over_dist_f3_f1 * list_over_dist_f3_f2) - 1 ) * -1
    # 
    # prunned_f1 <- target_table[as.logical(det), ]
    list_x <- target_table$new_l.x
    list_y <- target_table$new_l.y
    
    table_for_number <- target_table$l.x
  }
  
  
  
  
  
  
  
  
  # 이 디스턴스는 컨트리뷰션 스코어에서 따오고
  
  # dist_new_l <- sqrt(prunned_f1$new_l.x^2 + prunned_f1$new_l.y^2)
  
  # theta_new_l <- fct.find_theta_using_columns(prunned_f1$new_l.x, prunned_f1$new_l.y, 0, 0)
  
  
  dist_new <- sqrt(list_x^2 + list_y^2)
  
  theta_new <- fct.find_theta_using_columns(list_x, list_y, 0, 0)
  
  
  
  
  
  
  ##############################################
  # call the hull part
  ##############################################
  polygon_table.1 <- NULL
  theta <- 0.367173833818219 *2
  for (poly_idx in 0:8){
    polygon_table.1 <- rbind(polygon_table.1, fct.figureout_possible_space('independent', theta  - poly_idx * 0.25 * (theta), mode))
    
  }
  
  # points(polygon_table.1)
  
  ###########
  
  
  
  meuse_sf = st_as_sf(polygon_table.1, coords = c("polygon.x", "polygon.y"), crs = 4326)
  
  hulls <- concaveman(meuse_sf, concavity = 2, length_threshold = 1)
  
  result_possible_space <- lapply(as(hulls, "Spatial")@polygons,function(p) data.frame(p@Polygons[[1]]@coords))
  final_res_coord <- result_possible_space[[1]]
  
  
  
  
  
  ###############
  ###############
  ###############
  # Expand! Here, adjust max & min values
  dist_coef <- 1.0
  theta_coef <- 1.0
  
  result_gen <- fct.gen_with_bound(table_for_number, dist_coef, theta_coef, dist_new, theta_new)
  repeat{
    result_gen <- rbind(result_gen, fct.gen_with_bound(table_for_number, dist_coef, theta_coef, dist_new, theta_new))
    
    #prunning  
    is_result_inside <- inpolygon(result_gen[,1], result_gen[,2], final_res_coord$V1, final_res_coord$V2, boundary = TRUE)   # TRUE
    
    result_gen <- result_gen[is_result_inside,]
    
    if(nrow(result_gen) > 3000){
      break
    }
  }
  
  result_gen <- result_gen[1:3000,]
  
  
  # normalized & avoiding
  
  result <- fct.gen_avoiding_possible_space(2000, final_res_coord, result_gen[,1], result_gen[,2])
  plot(result, col = 'green', pch = 19)
  
  
  result_final <- rbind(result_gen, result)
  result_final <- result_final[1:5000,]
  ##############################################
  # prunning part: prune out if data point is out of the hull
  ##############################################
  
  # is_result_inside <- inpolygon(result_gen[,1], result_gen[,2], final_res_coord$V1, final_res_coord$V2, boundary = TRUE)   # TRUE
  
  # # prunning
  # dist_threshold_green <- 2 * ( max(dist_new) - min(dist_new) ) / as.integer(sqrt(length(table_for_number)))
  # 
  # combination <- rbind(result_gen, cbind(list_x, list_y))
  # result_min_dist <- NULL
  # 
  # for(idx_result in 1:nrow(result)){
  #   
  #   
  #   temp_dist <- sqrt((result[idx_result,1]  - combination[,1])^2 + (result[idx_result,2] - combination[,2])^2)
  #   
  #   min_dist <- min(temp_dist)
  #   
  #   result_min_dist <- c(result_min_dist, min_dist)
  #   
  # }
  
  # result_new <- cbind(result, result_min_dist)
  
  result_new <- result
  
  # 잘라내기, 이건 위의 경우에서 더 많이 뽑혔을때 잘라내는 것으로 지금은 필요없다.
  # result_new_sorted <- result_new[order(result_new[,2]),]
  # 
  # prunned_result <- result_new_sorted[c(1:length(table_for_number)),]
  
  plot(result_new[,1], result_new[,2], col = 'green', pch = 19)
  
  points(result_gen, col = 'blue', pch = 19)
  
  
  # find max & min as lines
  
  max.special_point.x <- - max(dist_new) * cos(max(theta_new))
  max.special_point.y <- - max(dist_new) * sin(max(theta_new)) 
  
  min.special_point.x <- - min(dist_new) * cos(min(theta_new))
  min.special_point.y <- - min(dist_new) * sin(min(theta_new)) 
  
  lines(c(0, max.special_point.x), c(0, max.special_point.y), col = 'red')
  lines(c(0, min.special_point.x), c(0, min.special_point.y), col = 'blue')
  
  
  
  
  # plot original
  
  if(mode == 'f1'){
    points(target_table$new_f1.x, target_table$new_f1.y, pch = '-')  
  }else if(mode == 'f2'){
    points(target_table$new_f2.x, target_table$new_f2.y, pch = '-')
  }else if(mode == 'f3'){
    points(target_table$new_f3.x, target_table$new_f3.y, pch = '-')
  }
  
  # prunned points
  points(list_x, list_y, col = 'red', pch = '+')
  if(param.mode.savePlot == TRUE){dev.off()}
  
  
  
  
  ##############################################
  # data post processing
  ##############################################
  
  
  temp_new_data_1000 <- target_table
  
  repeat{
    temp_new_data_1000 <- rbind(temp_new_data_1000, target_table)
    
    if(nrow(temp_new_data_1000) >= 5000){
      break
    }
  }
  
  # 1000개 까지만 딱 짜른다
  temp_new_data_1000 <- temp_new_data_1000[1:5000,]
  
  
  # return to original place by plus leader's coordinates
  
  if(mode == 'f1'){
    returned_new_f1.x <- as.numeric(as.matrix(result_final[,1] ) ) + as.numeric(as.matrix(temp_new_data_1000$l.x))
    returned_new_f1.y <- as.numeric(as.matrix(result_final[,2] ) ) + as.numeric(as.matrix(temp_new_data_1000$l.y))  
  }else if(mode == 'f2'){
    returned_new_f2.x <- as.numeric(as.matrix(result_final[,1] ) ) + as.numeric(as.matrix(temp_new_data_1000$l.x))
    returned_new_f2.y <- as.numeric(as.matrix(result_final[,2] ) ) + as.numeric(as.matrix(temp_new_data_1000$l.y))
  }else if(mode == 'f3'){
    returned_new_f3.x <- as.numeric(as.matrix(result_final[,1] ) ) + as.numeric(as.matrix(temp_new_data_1000$l.x))
    returned_new_f3.y <- as.numeric(as.matrix(result_final[,2] ) ) + as.numeric(as.matrix(temp_new_data_1000$l.y))
  }
  
  
}



##############################################
# save as csv fils part
##############################################
temp_new_data_1000$f1.x <- returned_new_f1.x
temp_new_data_1000$f1.y <- returned_new_f1.y

temp_new_data_1000$f2.x <- returned_new_f2.x
temp_new_data_1000$f2.y <- returned_new_f2.y

temp_new_data_1000$f3.x <- returned_new_f3.x
temp_new_data_1000$f3.y <- returned_new_f3.y
  

dist_l_f1 <- sqrt((as.numeric(as.matrix(temp_new_data_1000$l.x)) - temp_new_data_1000$f1.x)^2+(as.numeric(as.matrix(temp_new_data_1000$l.y)) - temp_new_data_1000$f1.y)^2)
dist_l_f2 <- sqrt((as.numeric(as.matrix(temp_new_data_1000$l.x)) - temp_new_data_1000$f2.x)^2+(as.numeric(as.matrix(temp_new_data_1000$l.y)) - temp_new_data_1000$f2.y)^2)
dist_l_f3 <- sqrt((as.numeric(as.matrix(temp_new_data_1000$l.x)) - temp_new_data_1000$f3.x)^2+(as.numeric(as.matrix(temp_new_data_1000$l.y)) - temp_new_data_1000$f3.y)^2)
dist_f1_f2 <- sqrt((temp_new_data_1000$f1.x - temp_new_data_1000$f2.x)^2+(temp_new_data_1000$f1.y - temp_new_data_1000$f2.y)^2)
dist_f1_f3 <- sqrt((temp_new_data_1000$f1.x - temp_new_data_1000$f3.x)^2+(temp_new_data_1000$f1.y - temp_new_data_1000$f3.y)^2)
dist_f2_f3 <- sqrt((temp_new_data_1000$f2.x - temp_new_data_1000$f3.x)^2+(temp_new_data_1000$f2.y - temp_new_data_1000$f3.y)^2)

min_dist <- NULL 

for(ind_i in 1:length(dist_l_f1)){
  temp_min <- min(dist_l_f1[ind_i], dist_l_f2[ind_i], dist_l_f3[ind_i], dist_f1_f2[ind_i], dist_f1_f3[ind_i], dist_f2_f3[ind_i])
  min_dist <- c(min_dist, temp_min)
}

if(mode.remove_close_coordinates == TRUE){
  temp_new_data_1000 <- temp_new_data_1000[min_dist > 0.1,]  
}

temp_new_data_1000 <- temp_new_data_1000[1:5000,]



###
# put ran_gen_leader here
###
library(stringr)
temp_new_data_1000$rand_seed <- as.numeric(gsub("[^0-9A-Za-z///' ]","" , temp_new_data_1000$rand_seed ,ignore.case = TRUE))
temp_new_data_1000$modi_param <- gsub("[^0-9A-Za-z///' ]","" , temp_new_data_1000$modi_param ,ignore.case = TRUE)
temp_new_data_1000$vari <- gsub("(?!\\.)[[:punct:]]", "", temp_new_data_1000$vari, perl=TRUE)
temp_new_data_1000$vari <- as.numeric(gsub("x", "", temp_new_data_1000$vari, perl=TRUE))
temp_new_data_1000$modi_start <- as.numeric(gsub("[^0-9A-Za-z///' ]","" , temp_new_data_1000$modi_start ,ignore.case = TRUE))
temp_new_data_1000$recog_time <- as.numeric(gsub("[^0-9A-Za-z///' ]","" , temp_new_data_1000$recog_time ,ignore.case = TRUE))

temp_new_data_1000$version <- as.numeric(temp_new_data_1000$version)
temp_new_data_1000$l.x <- as.numeric(as.matrix(temp_new_data_1000$l.x))


# 3. write into file
if(coef_param == 2.0){
  coef_param_temp = '2.0'
}else if(coef_param == 0.2){
  coef_param_temp = '0.2'
}
output_directory_randomized_data1 <- paste(output_directory_randomized_data, parameter_target, "/", sep="")
output_filename <- paste(parameter_target,"_x",coef_param_temp,"_rollback_",rollback_ver ,sep="")
  
table_final_name = paste(output_directory_randomized_data1, "randomized_",output_filename,".csv",sep="")
write.csv(temp_new_data_1000, file = table_final_name, row.names = FALSE) 






########
########
########
########
########
########
######## temp below
for(charac in 1:length(crash_list)){
  
  
  outputplotdir2 <- paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/02_01_output_plot/",filename,target_param,coef_param,mode,"_",charac,".png",sep="" )
  if(param.mode.savePlot == TRUE) {png(outputplotdir2, width = 500, height = 500, units = "px")}
  
  
  aligned_again_f1.x <- temp_new_data_1000$f1.x - as.numeric(as.matrix(temp_new_data_1000$l.x))
  aligned_again_f1.y <- temp_new_data_1000$f1.y - as.numeric(as.matrix(temp_new_data_1000$l.y))
  
  aligned_again_f2.x <- temp_new_data_1000$f2.x - as.numeric(as.matrix(temp_new_data_1000$l.x))
  aligned_again_f2.y <- temp_new_data_1000$f2.y - as.numeric(as.matrix(temp_new_data_1000$l.y))
  
  aligned_again_f3.x <- temp_new_data_1000$f3.x - as.numeric(as.matrix(temp_new_data_1000$l.x))
  aligned_again_f3.y <- temp_new_data_1000$f3.y - as.numeric(as.matrix(temp_new_data_1000$l.y))
  
  
  plot(aligned_again_f1.x, aligned_again_f1.y, col = 'blue', pch = 3, xlim = c(-1.2, 0.7), ylim = c(-0.8,1.0))
  points(aligned_again_f2.x, aligned_again_f2.y, col = 'brown', pch = 4)
  points(aligned_again_f3.x, aligned_again_f3.y, col = 'orange', pch = 8)
  
  
  
  all_new_new_f1.x <- temp_new_data_1000[crash_list,]$f1.x - temp_new_data_1000[crash_list,]$l.x
  all_new_new_f1.y <- temp_new_data_1000[crash_list,]$f1.y - temp_new_data_1000[crash_list,]$l.y
  
  all_new_new_f2.x <- temp_new_data_1000[crash_list,]$f2.x - temp_new_data_1000[crash_list,]$l.x
  all_new_new_f2.y <- temp_new_data_1000[crash_list,]$f2.y - temp_new_data_1000[crash_list,]$l.y
  
  all_new_new_f3.x <- temp_new_data_1000[crash_list,]$f3.x - temp_new_data_1000[crash_list,]$l.x
  all_new_new_f3.y <- temp_new_data_1000[crash_list,]$f3.y - temp_new_data_1000[crash_list,]$l.y
  
  points(0, 0, col = 'red', pch = 17, xlim = c(-1.0, 1.5), ylim = c(-1.5, 2.0))

  points(all_new_new_f1.x[charac], all_new_new_f1.y[charac], col = 'blue', pch = 17, xlim = c(-1.0, 1.5), ylim = c(-1.5, 2.0))
  points(all_new_new_f2.x[charac], all_new_new_f2.y[charac], col = 'brown', pch = 17, xlim = c(-1.0, 1.5), ylim = c(-1.5, 2.0))
  points(all_new_new_f3.x[charac], all_new_new_f3.y[charac], col = 'orange', pch = 17, xlim = c(-1.0, 1.5), ylim = c(-1.5, 2.0))
  
  lines(c(all_new_new_f1.x[charac], 0), c(all_new_new_f1.y[charac], 0))
  lines(c(all_new_new_f2.x[charac], 0), c(all_new_new_f2.y[charac], 0))
  lines(c(all_new_new_f1.x[charac], all_new_new_f3.x[charac]), c(all_new_new_f1.y[charac], all_new_new_f3.y[charac]))
  lines(c(all_new_new_f2.x[charac], all_new_new_f3.x[charac]), c(all_new_new_f2.y[charac], all_new_new_f3.y[charac]))
  if(param.mode.savePlot == TRUE){dev.off()}
}

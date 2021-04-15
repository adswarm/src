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

fct.mySampler <-function(n, m.x, m.y, s.x, s.y, bound){
  # n <- 1000
  # m <- 0
  # s <- 1
  
  samp.x <- rnorm(n, m.x, s.x)
  samp.y <- rnorm(n, m.y, s.y)
  
  samp.coor <- data.frame(samp.x, samp.y)
  
  det2 <- samp.coor$samp.y > -2.5
  samp.coor <- samp.coor[det2, ]
  
  return(samp.coor)
  
}

fct.myTrimmer <-function(n, m.x, m.y, s.x, s.y, bound){
  # n <- 1000
  # m <- 0
  # s <- 1
  enough_n <- 3 * n
  
  samp.x <- rnorm(enough_n, m.x, s.x)
  samp.y <- rnorm(enough_n, m.y, s.y)
  
  samp.coor <- data.frame(samp.x, samp.y)
  det <- (samp.coor$samp.x - m.x)^2 + (samp.coor$samp.y - m.y)^2 <= bound^2
  
  innercircle.coor <- samp.coor[det,]
  
  det2 <- innercircle.coor$samp.y > -2.5
  innercircle.coor <- innercircle.coor[det2, ]
  
  return(innercircle.coor[1:n,])
  
}

fct.myTrimmer_uniform <-function(n, m.x, m.y, bound){
  # n <- 1000
  # m <- 0
  # s <- 1
  enough_n <- 3 * n
  
  samp.x <- runif(enough_n, m.x - bound, m.x + bound)
  samp.y <- runif(enough_n, m.y - bound, m.y + bound)
  
  samp.coor <- data.frame(samp.x, samp.y)
  det <- (samp.coor$samp.x - m.x)^2 + (samp.coor$samp.y - m.y)^2 <= bound^2
  innercircle.coor <- samp.coor[det,]
  
  det2 <- innercircle.coor$samp.y > -2.5
  innercircle.coor <- innercircle.coor[det2, ]
  
  return(innercircle.coor[1:n,])
  
}

########

##############
# configurations
##############
param.culumn_O_remove <- c(16,17,20,21) # <-  1stO.x     1stO.y     2ndO.x   2ndO.y
param.culumn_etc_remove <- c(1:7)
param.mode.savePlot = TRUE
mode.remove_close_coordinates = FALSE
# directory for input 
# base_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/00_00_randomtesting/",sep="" )

output_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/1st_alg_safety_dist_3.0/input_gen/output/",sep="" )


# base directory
# base_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/00_00_randomtesting/",sep="" )
# directory for input 
# input_directory = paste(base_directory,"input/",sep="" )
# input_directory_aligned_data = paste(base_directory,"input/aligned/",sep="" )

# directory for output
# output_directory_randomized_data = paste(base_directory,"output/randomized/",sep="" )
output_directory_randomized_data = paste(output_directory,"1000/",sep="" )
# output_directory_aligned_data = paste(base_directory,"output/aligned/",sep="" )

##############
# Reading data
# refer: https://lightblog.tistory.com/13
# factor, refer: https://rfriend.tistory.com/32
# which, refer: http://egloos.zum.com/entireboy/v/4837061
##############
# datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing")
datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/1st_alg_safety_dist_3.0/input_gen/input")
datalist
i <- 1
filename <- datalist[i]
filename


csvname = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/1st_alg_safety_dist_3.0/input_gen/input/",filename,sep="" )
data_raw <- read.csv(file = csvname, header = FALSE, fileEncoding="UTF-8-BOM", as.is = 1)

data_raw <- na.omit(data_raw)


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

parameter_target = 'i' # fixed for now
target_param = paste("[", parameter_target,"]", sep="")#<--- fixed
coef_param = 2.0 #<--- fixed
rollback_ver = 0 #<--- fixed
mode_set = c('f1', 'f2', 'f3') # <--- HERE


# for(mode in mode_set){

r.integrated <- data_raw_preproc_2[data_raw_preproc_2$modi_param==target_param,]
r.integrated_rb_100 <- r.integrated[r.integrated$rollback==rollback_ver,]
r.integrated_rb_100_02 <- r.integrated_rb_100[r.integrated_rb_100$vari=="x[0.2]",]
r.integrated_rb_100_20 <- r.integrated_rb_100[r.integrated_rb_100$vari=="x[2.000000]",]

target_origin <- r.integrated[r.integrated$rollback==0,]
target_origin_02 <- target_origin[target_origin$vari=="x[0.2]",]
target_origin_20 <- target_origin[target_origin$vari=="x[2.000000]",]

################
### set the target_table

if(coef_param == 0.2){
  target_table <- r.integrated_rb_100_02
  target_to_compare <- target_origin_02
}else if(coef_param == 2.0){
  target_table <- r.integrated_rb_100_20
  target_to_compare <- target_origin_20
}




# outputplotdir <- paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/02_01_output_plot/",filename,target_param,coef_param,mode,".png",sep="" )
# if(param.mode.savePlot == TRUE) {png(outputplotdir, width = 500, height = 500, units = "px")}

################

length(target_table$l.x)
# plot(target_table$f1.x, target_table$f1.y)



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# leader
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

number_gen_whole <- 30000

# load data
l.data_x <- target_table$l.x
l.data_y <- target_table$l.y

# make data frame
l.df2 = data.frame(l.data_x, l.data_y)  

colnames(l.df2) <- c('x', 'y')
l.temp_CEPlevel <- 0.9
(l.cep <- getCEP(l.df2, CEPlevel=l.temp_CEPlevel, accuracy=FALSE,
               dstTarget=10, conversion='m2mm',
               type=c('Rayleigh')))
l.center_x <- l.cep$ctr[1]
l.center_y <- l.cep$ctr[2]
l.center_r <- l.cep$CEP$CEP0.9['unit', 'Rayleigh']




number_gen.l <- number_gen_whole
mean.l.x <- l.center_x
mean.l.y <- l.center_y
sd.l.x <- sd(l.data_x)# * 1.1
sd.l.y <- sd(l.data_y)# * 1.1

l.radius <- l.center_r

# this guy shouldn't use bound
l.coor <- fct.mySampler(number_gen.l, mean.l.x, mean.l.y, sd.l.x, sd.l.y, l.radius)
# plot(l.coor, xlim = c(-2.0, 1.0), ylim = c(-3.0, -0.0))
# l.coor2 <- fct.mySampler(number_gen.l, mean.l.x, mean.l.y, 2 * sd.l.x, 2 * sd.l.y, l.radius)



# Unif in possible space
# number_gen.l.2 <- number_gen_whole - number_gen.l
# 
# l.temp_CEPlevel.2 <- 0.999
# (l.cep.2 <- getCEP(l.df2, CEPlevel=l.temp_CEPlevel.2, accuracy=FALSE,
#                  dstTarget=10, conversion='m2mm',
#                  type=c('Rayleigh')))
# l.center_x.2 <- l.cep.2$ctr[1]
# l.center_y.2 <- l.cep.2$ctr[2]
# l.center_r.2 <- l.cep.2$CEP$CEP0.999['unit', 'Rayleigh']
# 
# mean.l.x.2 <- l.center_x.2
# mean.l.y.2 <- l.center_y.2
# l.radius.2 <- l.center_r.2
# 
# l.coor2 <- fct.mySampler(number_gen.l.2, mean.l.x.2, mean.l.y.2, sd.l.x, sd.l.y, l.radius.2)



# l.center_r.2 <- abs(min(l.data_x) - l.center_x)

# number_gen.l.2 <- number_gen_whole - number_gen.l
# mean.l.x.2 <- min(l.data_x) + abs(0.5 * (max(l.data_x) - min(l.data_x)))
# mean.l.y.2 <- min(l.data_y) + abs(0.5 * (max(l.data_y) - min(l.data_y)))
# l.radius.2 <- l.center_r.2
# 
# l.coor2 <- fct.mySampler(number_gen.l.2, mean.l.x.2, mean.l.y.2, sd.l.x, sd.l.y, l.radius.2)

# l.coor2 <- fct.myTrimmer_uniform(number_gen.l.2, mean.l.x.2, mean.l.y.2, l.radius.2)



commonTheme = list(labs(color="Density",fill="Density",
                        x="x",
                        y="y"),
                   theme_bw(),
                   theme(legend.position=c(0,1),
                         legend.justification=c(0,1)))

ggplot(data=l.df2,aes(x, y ) ) +
  xlim(-2.0, 1.0) +
  ylim(-3.0, -0.0) +
  geom_density2d(aes(colour=..level..)) +
  scale_colour_gradient(low="green",high="red") +
  geom_point() +
  annotate("path",
           x=l.center_x+l.center_r*cos(seq(0,2*pi,length.out=100)),
           y=l.center_y+l.center_r*sin(seq(0,2*pi,length.out=100))) + 
  annotate("point", x = l.center_x, y = l.center_y, colour = "red", pch = 17) +
  annotate("point", x = l.coor$samp.x, y = l.coor$samp.y, colour = "blue", pch = 8) +
  # annotate("point", x = l.coor2$samp.x, y = l.coor2$samp.y, colour = "red", pch = 8) +
  commonTheme

outputplotdir2 <- paste(output_directory,filename,target_param,coef_param,"l",".png",sep="" )
ggsave(outputplotdir2) # refer: https://ggplot2.tidyverse.org/reference/ggsave.html 

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# follower
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  

for (mode in c('f1','f2','f3')){
  
  # load data
  if(mode == 'f1'){
    data_x <- target_table$f1.x
    data_y <- target_table$f1.y
  }else if(mode == 'f2'){
    data_x <- target_table$f2.x
    data_y <- target_table$f2.y
  }else if(mode == 'f3'){
    data_x <- target_table$f3.x
    data_y <- target_table$f3.y
  }
  
  
  # make data frame
  df2 = data.frame(data_x, data_y)  
  
  colnames(df2) <- c('x', 'y')
  temp_CEPlevel <- 0.9
  (cep <- getCEP(df2, CEPlevel=temp_CEPlevel, accuracy=FALSE,
                 dstTarget=10, conversion='m2mm',
                 type=c('Rayleigh')))
  center_x <- cep$ctr[1]
  center_y <- cep$ctr[2]
  center_r <- cep$CEP$CEP0.9['unit', 'Rayleigh']
  
  # CEP
  number_gen.f <- number_gen_whole * 0.99
  mean.f.x <- center_x
  mean.f.y <- center_y
  sd.f.x <- sd(data_x)
  sd.f.y <- sd(data_y)
  
  f.radius <- center_r
  
  f.coor <- fct.myTrimmer(number_gen.f, mean.f.x, mean.f.y, sd.f.x, sd.f.y, f.radius)
  
  # plot(f.coor, col = "blue", xlim = c(-2.0, 1.0), ylim = c(-2.5, 1.0))
  
  
  
  # Unif in possible space
  number_gen.f.2 <- number_gen_whole - number_gen.f
  mean.f.x.2 <- 0.0 #fixed
  mean.f.y.2 <- 0.0 #fixed
  
  
  if(mode == 'f3'){
    from_restriction <- 1.0 #fixed
  }else{
    from_restriction <- 0.8 #fixed
  }
  
  f.radius.2 <- 0.5 * abs(min(l.coor$samp.x) - max(l.coor$samp.x)) + from_restriction
  f.coor2 <- fct.myTrimmer_uniform(number_gen.f.2, l.center_x, l.center_y, f.radius.2)
  
  # below code is optional
  # f.coor2 <- fct.myTrimmer_uniform(number_gen.f.2, mean.f.x.2, mean.f.y.2, f.radius.2)
  
  plot(f.coor2, xlim = c(-2.0, 1.0), ylim = c(-2.5, 1.0))
  
  
  # should be aligned again based on the leader's coordinates
  # aligned_f.p_s.x <- f.coor2$samp.x + l.coor$samp.x[(nrow(l.coor)-nrow(f.coor2) + 1):nrow(l.coor)]
  # aligned_f.p_s.y <- f.coor2$samp.y + l.coor$samp.y[(nrow(l.coor)-nrow(f.coor2) + 1):nrow(l.coor)]

  # points(aligned_f.p_s.x, aligned_f.p_s.y, col = 'red')
  

  # plotting
  
  ggplot(data=df2,aes(x, y ) ) +
    xlim(-2.0, 1.0) +
    ylim(-3.0, -0.0) +
    geom_density2d(aes(colour=..level..)) +
    scale_colour_gradient(low="green",high="red") +
    geom_point() +
    annotate("path",
             x=center_x+center_r*cos(seq(0,2*pi,length.out=100)),
             y=center_y+center_r*sin(seq(0,2*pi,length.out=100))) + 
    annotate("point", x = center_x, y = center_y, colour = "red", pch = 17) +
    annotate("point", x = f.coor$samp.x, y = f.coor$samp.y, colour = "blue", pch = 8) +
    annotate("point", x = f.coor2$samp.x, y = f.coor2$samp.y, colour = "green", pch = 8) +
    # annotate("point", x = aligned_f.p_s.x, y = aligned_f.p_s.y, colour = "red", pch = 8) + 
    commonTheme
  
  outputplotdir2 <- paste(output_directory,filename,target_param,coef_param,mode,".png",sep="" )
  ggsave(outputplotdir2) # refer: https://ggplot2.tidyverse.org/reference/ggsave.html 

  # save data
  if(mode == 'f1'){
    CEP_f1 <- rbind(f.coor, f.coor2)
  }else if(mode == 'f2'){
    CEP_f2 <- rbind(f.coor, f.coor2)
  }else if(mode == 'f3'){
    CEP_f3 <- rbind(f.coor, f.coor2)
  }
  
}    

  
###
# make the format fitting to 5000 data
###
CEP_target_table <- NULL
for(repead_idx in 1: 50000){
  CEP_target_table <- rbind(CEP_target_table, target_table)
  if(nrow(CEP_target_table)>number_gen_whole){
    break
  }
}
CEP_target_table <- CEP_target_table[1:number_gen_whole,]
nrow(CEP_target_table)

###
# input the generated data into format
###
# CEP_target_table$l.x <- l.coor$samp.x
# CEP_target_table$l.y <- l.coor$samp.y
# 
# CEP_target_table$f1.x <- CEP_f1$samp.x
# CEP_target_table$f1.y <- CEP_f1$samp.y
# 
# CEP_target_table$f2.x <- CEP_f2$samp.x
# CEP_target_table$f2.y <- CEP_f2$samp.y
# 
# CEP_target_table$f3.x <- CEP_f3$samp.x
# CEP_target_table$f3.y <- CEP_f3$samp.y

mode_switch = 1
# ALIGNED BASED ON LEADER
if(mode_switch == 1){
  
  CEP_target_table$f1.x <- CEP_f1$samp.x + ( CEP_target_table$l.x - l.coor$samp.x)
  CEP_target_table$f1.y <- CEP_f1$samp.y + ( CEP_target_table$l.y - l.coor$samp.y)
  
  CEP_target_table$f2.x <- CEP_f2$samp.x + ( CEP_target_table$l.x - l.coor$samp.x)
  CEP_target_table$f2.y <- CEP_f2$samp.y + ( CEP_target_table$l.y - l.coor$samp.y)
  
  CEP_target_table$f3.x <- CEP_f3$samp.x + ( CEP_target_table$l.x - l.coor$samp.x)
  CEP_target_table$f3.y <- CEP_f3$samp.y + ( CEP_target_table$l.y - l.coor$samp.y)
  
}else if(mode_switch == 2){
  
  CEP_target_table$l.x <- l.coor$samp.x
  CEP_target_table$l.y <- l.coor$samp.y
  
  CEP_target_table$f1.x <- CEP_f1$samp.x
  CEP_target_table$f1.y <- CEP_f1$samp.y
  
  CEP_target_table$f2.x <- CEP_f2$samp.x
  CEP_target_table$f2.y <- CEP_f2$samp.y
  
  CEP_target_table$f3.x <- CEP_f3$samp.x
  CEP_target_table$f3.y <- CEP_f3$samp.y
  
}


# FINALLY, prune out data 1) out of the square, 2) inter-distance <= 0.3
if(mode_switch == 1){
  
  CEP_target_table <- CEP_target_table[which(CEP_target_table$f1.y > -4.5),]
  CEP_target_table <- CEP_target_table[which(CEP_target_table$f2.y > -4.5),]
  CEP_target_table <- CEP_target_table[which(CEP_target_table$f3.y > -4.5),]

}
nrow(CEP_target_table)
# 2) inter-distance <= 0.3
if(1){
  dist_l_f1 <- sqrt((CEP_target_table$l.x - CEP_target_table$f1.x)^2 + (CEP_target_table$l.y - CEP_target_table$f1.y)^2)
  dist_l_f2 <- sqrt((CEP_target_table$l.x - CEP_target_table$f2.x)^2 + (CEP_target_table$l.y - CEP_target_table$f2.y)^2)
  dist_l_f3 <- sqrt((CEP_target_table$l.x - CEP_target_table$f3.x)^2 + (CEP_target_table$l.y - CEP_target_table$f3.y)^2)
  dist_f1_f2 <- sqrt((CEP_target_table$f1.x - CEP_target_table$f2.x)^2 + (CEP_target_table$f1.y - CEP_target_table$f2.y)^2)
  dist_f1_f3 <- sqrt((CEP_target_table$f1.x - CEP_target_table$f3.x)^2 + (CEP_target_table$f1.y - CEP_target_table$f3.y)^2)
  dist_f2_f3 <- sqrt((CEP_target_table$f2.x - CEP_target_table$f3.x)^2 + (CEP_target_table$f2.y - CEP_target_table$f3.y)^2)
  
  min_dist <- dist_l_f1
  # min_dist <- min(dist_l_f1, dist_l_f2, dist_l_f3, dist_f1_f2, dist_f1_f3, dist_f2_f3)
  
  for(idx in 0:length(dist_l_f1)){
    
    min_dist[idx] <- min(dist_l_f1[idx], dist_l_f2[idx], dist_l_f3[idx], dist_f1_f2[idx], dist_f1_f3[idx], dist_f2_f3[idx])
    
  }
  
  
  CEP_target_table <- CEP_target_table[which(min_dist > 0.3),]
  
}


nrow(CEP_target_table)

CEP_target_table <- CEP_target_table[1:10000,]

# this process can yield the exception

###
# Prune out weird things
###
library(stringr)
CEP_target_table$rand_seed <- as.numeric(gsub("[^0-9A-Za-z///' ]","" , CEP_target_table$rand_seed ,ignore.case = TRUE))
CEP_target_table$modi_param <- gsub("[^0-9A-Za-z///' ]","" , CEP_target_table$modi_param ,ignore.case = TRUE)
CEP_target_table$vari <- gsub("(?!\\.)[[:punct:]]", "", CEP_target_table$vari, perl=TRUE)
CEP_target_table$vari <- as.numeric(gsub("x", "", CEP_target_table$vari, perl=TRUE))
CEP_target_table$modi_start <- as.numeric(gsub("[^0-9A-Za-z///' ]","" , CEP_target_table$modi_start ,ignore.case = TRUE))
CEP_target_table$recog_time <- as.numeric(gsub("[^0-9A-Za-z///' ]","" , CEP_target_table$recog_time ,ignore.case = TRUE))

CEP_target_table$version <- as.numeric(CEP_target_table$version)
CEP_target_table$l.x <- as.numeric(as.matrix(CEP_target_table$l.x))



########
######## writing
# 3. write into file
if(coef_param == 2.0){
  coef_param_temp = '2.0'
}else if(coef_param == 0.2){
  coef_param_temp = '0.2'
}
output_directory_randomized_data1 <- paste(output_directory_randomized_data, parameter_target, "/", sep="")
output_filename <- paste(parameter_target,"_x",coef_param_temp,"_rollback_",rollback_ver ,sep="")

table_final_name = paste(output_directory_randomized_data1, "randomized_",output_filename,".csv",sep="")
write.csv(CEP_target_table, file = table_final_name, row.names = FALSE) 


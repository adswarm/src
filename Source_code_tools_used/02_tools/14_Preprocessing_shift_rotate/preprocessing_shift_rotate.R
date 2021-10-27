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

set.seed(1)


##############
# configurations
##############
param.culumn_O_remove <- c(16,17,20,21) # <-  1stO.x     1stO.y     2ndO.x   2ndO.y
param.culumn_etc_remove <- c(1:7)

# directory for input 
# base_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/00_00_randomtesting/",sep="" )
csv_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing/pre/",sep="" )

##############
# Reading data
# refer: https://lightblog.tistory.com/13
# factor, refer: https://rfriend.tistory.com/32
# which, refer: http://egloos.zum.com/entireboy/v/4837061
##############
datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing")

i <- 4
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

# split by param.
r.integrated <- data_raw_preproc_1[data_raw_preproc_1$modi_param=='[r]',]
r.integrated.noNa <- na.omit(r.integrated)
fct.split_transform_write(r.integrated.noNa, 1, 12, csv_directory, "r", param.culumn_O_remove, param.culumn_etc_remove)

a.integrated <- data_raw_preproc_1[data_raw_preproc_1$modi_param=='[a]',]
fct.split_transform_write(a.integrated, csv_directory, "a", param.culumn_O_remove, param.culumn_etc_remove)

b.integrated <- data_raw_preproc_1[data_raw_preproc_1$modi_param=='[b]',]
fct.split_transform_write(b.integrated, csv_directory, "b", param.culumn_O_remove, param.culumn_etc_remove)

i.integrated <- data_raw_preproc_1[data_raw_preproc_1$modi_param=='[i]',]
fct.split_transform_write(i.integrated, csv_directory, "i", param.culumn_O_remove, param.culumn_etc_remove)


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
library(plotly)
# source("C:/Users/Chijung Jung/source/R_project/lib/functions.R")
source("~/Research/tool_project_swarm_safety/lib/functions.R") # Linux version

set.seed(1)



datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/3rd_alg/ran_gen_input/input")

# datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing")
datalist #seed_1_150_Ix2.0_new_restriction
i <- 1
filename <- datalist[i]
filename


# csvname = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing/",filename,sep="" )
csvname = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/3rd_alg/ran_gen_input/input/",filename,sep="" )

data_raw <- read.csv(file = csvname, header = FALSE, fileEncoding="UTF-8-BOM", as.is = 1)
nrow(data_raw)



fct.make_sphere = function(gen_nb, center_x, center_y, center_z, center_r){
  # center_x <- 144.6478
  # center_y <- 86.09045
  # center_z <- -11.33051
  # center_r <- 16.20963
  # 
  # gen_nb <- 100000
  
  gen.x <- runif(gen_nb, min = (center_x - center_r), max = (center_x + center_r))
  gen.y <- runif(gen_nb, min = (center_y - center_r), max = (center_y + center_r))
  gen.z <- runif(gen_nb, min = (center_z - center_r), max = (center_z + center_r))
  
  df <- data.frame(gen.x, gen.y, gen.z)
  
  det <- (gen.x - center_x)^2 + (gen.y - center_y)^2 + (gen.z - center_z)^2 < center_r^2
  
  df_trimmed <- df[det, ]
  
  return(df_trimmed)
  
  
}

output_filename <- "a4"

df_agent1 <- fct.make_sphere(1000, -1.2, -1.2, 0.8, 0.5) # <- raw value from the sim
df_agent2 <- fct.make_sphere(1000, 1.25, -1.25, 0.8, 0.5) # <- raw value from the sim
df_agent3 <- fct.make_sphere(1000, 0, 1.25, 1.75, 0.5) # <- raw value from the sim
df_agent4 <- fct.make_sphere(1000, 0, 1.25, 1.00, 0.5) # <- raw value from the sim

if(0){
  df_agent2
  fig1 <- plot_ly(df_agent2, x = ~gen.x, y = ~gen.y, z = ~gen.z, size = 1, type = "scatter3d")
  fig1
  
}
if(output_filename == "a1"){
  df_agent = df_agent1
}else if(output_filename == "a2"){
  df_agent = df_agent2
}else if(output_filename == "a3"){
  df_agent = df_agent3
}else if(output_filename == "a4"){
  df_agent = df_agent4
}

  
output_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/3rd_alg/ran_gen_input/output/",sep="" )

output_directory_randomized_data = output_directory#paste(output_directory_randomized_data,"1000/",sep="" )

# output_directory_randomized_data1 <- paste(output_directory_randomized_data, parameter_target, "/", sep="")
# output_filename <- paste(parameter_target,"_x",coef_param_temp,"_rollback_",rollback_ver ,sep="")

table_final_name = paste(output_directory_randomized_data, "randomized_",output_filename,".csv",sep="")
write.csv(df_agent, file = table_final_name, row.names = FALSE)

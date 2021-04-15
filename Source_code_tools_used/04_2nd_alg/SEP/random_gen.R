
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
source("~/Research/tool_project_swarm_safety/Preprocessing_R/possible_space/possible_space.R") # Linux version

set.seed(1)

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

# for agent2 (first drone)

# a1   18  x/y/z/norm/r:  145.0596   84.01725   -12.10435   168.0705   23.75571 
# a2   18  x/y/z/norm/r:  144.6478   86.09045   -11.33051   168.7096   16.20963 
# a3   18  x/y/z/norm/r:  144.7474   82.30505   -11.48442   166.9066   24.29293 

df_agent2 <- fct.make_sphere(100000, 144.6478, 86.09045, 11.33051, 16.20963) # <- raw value from the sim
df_agent2
fig1 <- plot_ly(df_agent2, x = ~gen.x, y = ~gen.y, z = ~gen.z, size = 1, type = "scatter3d")
fig1 


# obst
obst.x <- 150
obst.y <- 112.6

desired_dist_lb <- 18.75 + 10
desired_dist_ub <- 18.75 + 10 + 2

# consider lower bound
current_dist_lb <- sqrt((df_agent2$gen.x - obst.x)^2 + (df_agent2$gen.y - obst.y)^2)

current_dist_lb

det_agent2_lb <- current_dist_lb >= desired_dist_lb #&& current_dist <= desired_dist_ub

det_agent2_lb
 
df_agent2_trimmed_lb <- df_agent2[det_agent2_lb,]

nrow(df_agent2_trimmed_lb)

fig_lb <- plot_ly(df_agent2_trimmed_lb, x = ~gen.x, y = ~gen.y, z = ~gen.z, size = 1, type = "scatter3d")
fig_lb

# consider upper bound
current_dist_ub <- sqrt((df_agent2_trimmed_lb$gen.x - obst.x)^2 + (df_agent2_trimmed_lb$gen.y - obst.y)^2)

det_agent2_ub <- current_dist_ub <= desired_dist_ub #&& current_dist <= desired_dist_ub

det_agent2_ub

df_agent2_trimmed_ub <- df_agent2_trimmed_lb[det_agent2_ub,]

nrow(df_agent2_trimmed_ub)

fig_ub <- plot_ly(df_agent2_trimmed_ub, x = ~gen.x, y = ~gen.y, z = ~gen.z, size = 1, type = "scatter3d")
fig_ub

# this is what we got so far. something like a bended coin.

#########
# write as csv file
#########
output_dir <- "~/Research/tool_project_swarm_safety/Preprocessing_R/2nd_alg/SVM/output/"

output_filename <- paste(output_dir,"agent_1_ran_gen.csv" ,sep="")

write.csv(df_agent2_trimmed_ub, file = output_filename, row.names = FALSE) 





tag_ub <- df_agent2_trimmed_ub$gen.x * 0 + 2
df_agent2_trimmed_ub_tagged <- cbind(df_agent2_trimmed_ub, tag_ub)

####
# second_round
####

df_agent2.2 <- fct.make_sphere(100000, 144.6478, 86.09045, 11.33051, 16.20963 + 10 + 18.72)
df_agent2.2
# fig1 <- plot_ly(df_agent2, x = ~gen.x, y = ~gen.y, z = ~gen.z, size = 1, type = "scatter3d")
# fig1 


# obst
obst.x.2 <- obst.x#150
obst.y.2 <- obst.y#112.6

desired_dist_lb.2 <- desired_dist_lb #18.75 + 10
desired_dist_ub.2 <- desired_dist_ub #18.75 + 10 + 2

# consider lower bound
current_dist_lb.2 <- sqrt((df_agent2.2$gen.x - obst.x.2)^2 + (df_agent2.2$gen.y - obst.y.2)^2)

current_dist_lb.2

det_agent2_lb.2 <- current_dist_lb.2 >= desired_dist_lb.2 #&& current_dist <= desired_dist_ub

det_agent2_lb.2

df_agent2_trimmed_lb.2 <- df_agent2.2[det_agent2_lb.2,]

nrow(df_agent2_trimmed_lb.2)

# fig_lb <- plot_ly(df_agent2_trimmed_lb, x = ~gen.x, y = ~gen.y, z = ~gen.z, size = 1, type = "scatter3d")
# fig_lb

# consider upper bound
current_dist_ub.2 <- sqrt((df_agent2_trimmed_lb.2$gen.x - obst.x.2)^2 + (df_agent2_trimmed_lb.2$gen.y - obst.y.2)^2)

det_agent2_ub.2 <- current_dist_ub.2 <= desired_dist_ub.2 #&& current_dist <= desired_dist_ub

det_agent2_ub.2

df_agent2_trimmed_ub.2 <- df_agent2_trimmed_lb.2[det_agent2_ub.2,]

nrow(df_agent2_trimmed_ub.2)

# fig_ub <- plot_ly(df_agent2_trimmed_ub, x = ~gen.x, y = ~gen.y, z = ~gen.z, size = 1, type = "scatter3d")
# fig_ub

tag_ub.2 <- df_agent2_trimmed_ub.2$gen.x * 0 + 3
df_agent2_trimmed_ub_tagged.2 <- cbind(df_agent2_trimmed_ub.2, tag_ub.2)


colnames(df_agent2_trimmed_ub_tagged.2) <- colnames(df_agent2_trimmed_ub_tagged)




############
# df from alg2_sep.R
############

tag_df2 <- df2$x * 0 + 1
df2_tagged <- cbind(df2, tag_df2)
df2_tagged$gen.z <- -df2_tagged$gen.z
# colnames(df_agent2_trimmed_ub_tagged)
colnames(df2_tagged) <- colnames(df_agent2_trimmed_ub_tagged)


###
###
# combine
###
###

combined_data <- rbind(df_agent2_trimmed_ub_tagged,df_agent2_trimmed_ub_tagged.2, df2_tagged)
# colnames(df_agent2_trimmed_ub_tagged.2)

# plot_ly(df2, x = ~x, y = ~y, z = ~-z, size = 1, type = "scatter3d")

# fig1 <- add_trace(p = fig1, x = ~dd$x, y = ~dd$y, z = ~dd$z, type = "mesh3d", opacity = 0.01)



fig_final <- plot_ly(combined_data, x = ~gen.x, y = ~gen.y, z = ~gen.z, size = 1, color = ~tag_ub, colors = c('red', 'blue', 'green'), type = "scatter3d")
fig_final
nrow(combined_data)

rm(list = ls())

library(plot3D)
library(plotly)

data("volcano")


# filename = "case_02.csv"
filename = "case_01.csv"
csvname = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/1st_plautoe/input/",filename,sep="" )


# name_traj_part1 = paste(input_directory,"wp_part_04_trial_03_14_fail.csv",sep="" )
data <- read.csv(file = csvname, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)
x1 <- data[1,2:length(data)]
y1 <- data[2:length(data),1]



head(data, 5)

# persp3D(z = )

m <- as.matrix(data[2:length(data), 2:length(data)])
head(m, 5)

nrow(m)
length(x)
persp3D(z=m)
# volcano is a numeric matrix that ships with R
# fig <- plot_ly(x = ~x1, y = ~y1, z = ~m)

# when case 2
if (filename == "case_02.csv"){
  fig <- plot_ly(z = ~m, colors = colorRamp(c("red","navy", "blue", "green", "yellow")))  
}else{
  fig <- plot_ly(z = ~m, colors = colorRamp(c("navy", "blue", "green", "yellow")))  
}

fig <- fig %>% add_surface()



axx <- list(
  nticks = 4,
  range = c(19,29)
)

axy <- list(
  nticks = 4,
  range = c(19,29)
)

axz <- list(
  nticks = 4,
  range = c(0,0.3)
)

fig <- fig %>% layout(scene = list(xaxis=axx,yaxis=axy,zaxis=axz))





fig

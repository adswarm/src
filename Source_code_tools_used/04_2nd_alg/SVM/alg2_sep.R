################################################################################
################################################################################

# plotly 3d plot
rm(list = ls())

library(plotly)
library("shotGroups")
library("processx")
library()

data_dir <- "~/Research/tool_project_swarm_safety/Preprocessing_R/2nd_alg/SVM/input/"

datalist <- list.files(path = data_dir)
datalist
i <- 1 #"swarmlab_data_coord_3d.csv"
filename <- datalist[i]
filename
param.mode.savePlot <- TRUE

csvname = paste(data_dir,filename,sep="" )
data_raw <- read.csv(file = csvname, header = TRUE, fileEncoding="UTF-8-BOM", as.is = 1)
# data_raw

plot_ly(data_raw, x = ~east, y = ~north, z = ~-down, color = ~agent, size = 1, colors = c('red', 'blue', 'green'))
# fig <- fig %>% add_markers()
# fig <- fig %>% layout(scene = list(xaxis = list(title = 'Weight'),
#                                    yaxis = list(title = 'Gross horsepower'),
#                                    zaxis = list(title = '1/4 mile time')))

data_raw.agent1 <- data_raw[which(data_raw$agent == 1),]
data_raw.agent2 <- data_raw[which(data_raw$agent == 2),]
data_raw.agent3 <- data_raw[which(data_raw$agent == 3),]



for(mode.which in c('a1','a2','a3')){
  # for(range_idx in 1:130) { #0:8){
  mode.which <- 'a2'
  for(range_idx in 0:18) { #0:8){
    
    # mode.which <- 'l'
    # range_idx <- 199
    # range_idx <- 18
    range_idx <- 18
    range_start <- 1 #(10*range_idx) #1#
    range_end <- (10*(range_idx+1)) # range_idx # #
    
    
    if(mode.which == 'a1'){
      temp_data <- data_raw.agent1  
    }else if(mode.which == 'a2'){
      temp_data <- data_raw.agent2  
    }else if(mode.which == 'a3'){
      temp_data <- data_raw.agent3  
    }
    
    data_x <- temp_data$east[range_start:range_end]
    data_y <- temp_data$north[range_start:range_end]
    data_z <- temp_data$down[range_start:range_end]
    
    # cat(mode.which," ", range_idx," norm(mean): ", sqrt((mean(data_x))^2+(mean(data_y))^2), " norm(variance): ", sqrt((var(data_x))^2+(var(data_y))^2), "\n")
    # cat(mode.which," ", range_idx," norm(mean): ", sqrt((mean(data_x))^2+(mean(data_y))^2)," norm(variance): ", sqrt((var(data_x))^2+(var(data_y))^2), " var(x): ", var(data_x), " var(y): ", var(data_y), "\n")
    # cat(mode.which," ", range_idx," norm(mean): ", sqrt((mean(data_x))^2+(mean(data_y))^2)," norm(sd): ", sqrt((sd(data_x))^2+(sd(data_y))^2), " sd(x): ", sd(data_x), " sd(y): ", sd(data_y), "\n")
    # cat(mode.which," ", range_idx," mean(x): ", mean(data_x), " mean(y): ", mean(data_y), " norm: ", sqrt((mean(data_x))^2+(mean(data_y))^2))
    # cat(mode.which," ", range_idx," var(x): ", var(data_x), " var(y): ", var(data_y), " norm: ", sqrt((var(data_x))^2+(var(data_y))^2), "\n")
    df2 = data.frame(data_x, data_y, data_z)  
    
    # refer: https://stats.stackexchange.com/questions/31726/scatterplot-with-contour-heat-overlay
    
    
    colnames(df2) <- c('x', 'y', 'z')
    df2
    temp_CEPlevel <- 0.9
    (cep <- getCEP(df2, CEPlevel=temp_CEPlevel, accuracy=FALSE,
                   dstTarget=10, conversion='m2mm',
                   type=c('Rayleigh')))
    center_x <- cep$ctr[1]
    center_y <- cep$ctr[2]
    center_z <- cep$ctr[3]
    center_r <- cep$CEP$CEP0.9['unit', 'Rayleigh']
    
    temp_norm <- sqrt((center_x)^2+(center_y)^2+(center_z)^2)
    
    cat(mode.which," ", range_idx," x/y/z/norm/r: ",center_x," ",center_y," ",center_z," ",temp_norm," ",center_r,"\n")
    
    
    fig1 <- plot_ly(df2, x = ~x, y = ~y, z = ~-z, size = 1, type = "scatter3d")
    
    
    r <- center_r
    coord.x <- center_x
    coord.y <-center_y
    coord.z <- -center_z
    dd <- transform(expand.grid(theta=seq(0,pi,length=100),
                                phi=seq(0,2*pi,length=200)),
                    x = coord.x + r*sin(theta)*cos(phi),
                    y = coord.y + r*sin(theta)*sin(phi),
                    z = coord.z + r*cos(theta)) 
    
    
    fig1 <- add_trace(p = fig1, x = ~dd$x, y = ~dd$y, z = ~dd$z, type = "mesh3d", opacity = 0.01)
    
    fig1
    
    
    # Below code is not working now,
    # You have to do manually at least for now.
    
    outputplotdir <- paste("~/Research/tool_project_swarm_safety/Preprocessing_R/2nd_alg/SVM/output/",mode.which,"_",range_idx,".png",sep="" )
    # if(param.mode.savePlot == TRUE) {png(outputplotdir, width = 500, height = 500, units = "px")}
    
    # export(fig1, file = outputplotdir, selenium = 'webp')
    
    orca(fig1, outputplotdir) ##orca is the replace of export function
    
    # TODO: Error in orca(fig1, outputplotdir) : could not find function "orca"
    
    
    # if(param.mode.savePlot == TRUE){dev.off()}
  }
}







# refer: https://stackoverflow.com/questions/50412858/plotting-ellipse3d-in-r-plotly-with-surface-ellipse

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
library("shotGroups")
# source("C:/Users/Chijung Jung/source/R_project/lib/functions.R")
source("~/Research/tool_project_swarm_safety/lib/functions.R") # Linux version

set.seed(1)


##############
# configurations
##############
param.culumn_O_remove <- c(16,17,20,21) # <-  1stO.x     1stO.y     2ndO.x   2ndO.y
param.culumn_etc_remove <- c(1:7)
param.mode.savePlot <- TRUE
# directory for input 
# base_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/00_00_randomtesting/",sep="" )
csv_directory = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing/pre/",sep="" )

##############
# Reading data
# refer: https://lightblog.tistory.com/13
# factor, refer: https://rfriend.tistory.com/32
# which, refer: http://egloos.zum.com/entireboy/v/4837061
##############
datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/incremental/input")
# datalist <- list.files(path = "~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing")
datalist #seed_1_150_Ix2.0_new_restriction
i <- 1
filename <- datalist[i]
filename


# csvname = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/01_00_preprocessing/",filename,sep="" )
csvname = paste("~/Research/tool_project_swarm_safety/Preprocessing_R/incremental/input/",filename,sep="" )
data_raw <- read.csv(file = csvname, header = FALSE, fileEncoding="UTF-8-BOM", as.is = 1)
nrow(data_raw)

colnames(data_raw) <- c("l.x", "l.y", "f1.x", "f1.y", "f2.x", "f2.y", "f3.x", "f3.y")


plot(data_raw$l.x, data_raw$l.y, col = 'red', pch = 17, xlim = c(-1.5, 0.5), ylim = c(-2.5, -1.0))
points(data_raw$f1.x, data_raw$f1.y, col = 'blue', pch = 17)
points(data_raw$f2.x, data_raw$f2.y, col = 'brown', pch = 17)
points(data_raw$f3.x, data_raw$f3.y, col = 'orange', pch = 17)
 
nrow(data_raw)

library(MASS)
library(ggplot2)
param.mode.savePlot <- TRUE

for(mode.which in c('l','f1','f2','f3')){
  # for(range_idx in 1:130) { #0:8){
  for(range_idx in 0:18) { #0:8){
    
    mode.which <- 'f3'
    # range_idx <- 199
    range_idx <- 18
    outputplotdir <- paste("~/Research/tool_project_swarm_safety/Preprocessing_R/data/02_01_output_plot/contour_",mode.which,"_",range_idx,".png",sep="" )
    if(param.mode.savePlot == TRUE) {png(outputplotdir, width = 500, height = 500, units = "px")}
    range_start <- 1 #(10*range_idx) #1#
    range_end <- (10*(range_idx+1)) # range_idx # #
    
    if(mode.which == 'l'){
      data_x <- data_raw$l.x[range_start:range_end]
      data_y <- data_raw$l.y[range_start:range_end]
    }else if(mode.which == 'f1'){
      data_x <- data_raw$f1.x[range_start:range_end]
      data_y <- data_raw$f1.y[range_start:range_end]
    }else if(mode.which == 'f2'){
      data_x <- data_raw$f2.x[range_start:range_end]
      data_y <- data_raw$f2.y[range_start:range_end]
    }else if(mode.which == 'f3'){
      data_x <- data_raw$f3.x[range_start:range_end]
      data_y <- data_raw$f3.y[range_start:range_end]
    }
    # cat(mode.which," ", range_idx," norm(mean): ", sqrt((mean(data_x))^2+(mean(data_y))^2), " norm(variance): ", sqrt((var(data_x))^2+(var(data_y))^2), "\n")
    cat(mode.which," ", range_idx," norm(mean): ", sqrt((mean(data_x))^2+(mean(data_y))^2)," norm(variance): ", sqrt((var(data_x))^2+(var(data_y))^2), " var(x): ", var(data_x), " var(y): ", var(data_y), "\n")
    # cat(mode.which," ", range_idx," norm(mean): ", sqrt((mean(data_x))^2+(mean(data_y))^2)," norm(sd): ", sqrt((sd(data_x))^2+(sd(data_y))^2), " sd(x): ", sd(data_x), " sd(y): ", sd(data_y), "\n")
    # cat(mode.which," ", range_idx," mean(x): ", mean(data_x), " mean(y): ", mean(data_y), " norm: ", sqrt((mean(data_x))^2+(mean(data_y))^2))
    # cat(mode.which," ", range_idx," var(x): ", var(data_x), " var(y): ", var(data_y), " norm: ", sqrt((var(data_x))^2+(var(data_y))^2), "\n")
    df2 = data.frame(data_x, data_y)  
    
    # refer: https://stats.stackexchange.com/questions/31726/scatterplot-with-contour-heat-overlay
    
    
    if(param.mode.savePlot == TRUE){
      colnames(df2) <- c('x', 'y')
      commonTheme = list(labs(color="Density",fill="Density",
                              x="x",
                              y="y"),
                         theme_bw(),
                         theme(legend.position=c(0,1),
                               legend.justification=c(0,1)))
      
      (cep <- getCEP(df2, CEPlevel=0.1, accuracy=FALSE,
                     dstTarget=10, conversion='m2mm',
                     type=c('Rayleigh')))
      # refer: https://www.rdocumentation.org/packages/shotGroups/versions/0.7.5.1/topics/getCEP
      center_x <- cep$ctr[1]
      center_y <- cep$ctr[2]
      center_r <- cep$CEP$CEP0.1['unit', 'Rayleigh']
      
      # how to add
      # https://stackoverflow.com/questions/35974805/ggplot2-automatic-scaling-to-include-complete-contour-lines-in-geom-density-2d
      
       gg2<- ggplot(data=df2,aes(x, y ) ) +
        xlim(-1.5, 0.5) +
        ylim(-2.5, -1.0) +
        geom_density2d(aes(colour=..level..)) +
        scale_colour_gradient(low="green",high="red") +
        geom_point() +
        annotate("path",
                 x=center_x+center_r*cos(seq(0,2*pi,length.out=100)),
                 y=center_y+center_r*sin(seq(0,2*pi,length.out=100))) + 
        annotate("point", x = center_x, y = center_y, colour = "red", pch = 17) +
        commonTheme
      
       #gg3 <- gg1 + gg2
      
      cat(mode.which," ", range_idx," x/y/r: ",center_x," ",center_y," ",center_r,"\n")
      
      ggsave(outputplotdir) # refer: https://ggplot2.tidyverse.org/reference/ggsave.html  
    }
    
    if(param.mode.savePlot == TRUE){dev.off()}
  }
}



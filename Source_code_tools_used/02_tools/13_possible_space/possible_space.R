rm(list = ls())
source("~/Research/tool_project_swarm_safety/lib/functions.R") # Linux version
library(sf)
library(concaveman) #refer: https://gis.stackexchange.com/questions/302107/defining-convex-hull-of-clouds-of-points-using-r
#refer: https://stackoverflow.com/questions/26317854/how-to-retrieve-a-slot-coords-of-each-spatialppolygon-object


# functions
fct.formation <- function(which_f, x, y){
  
  if(which_f == 'f1'){
    formation.x <- x - 1 * 0.3 * sqrt(3) / 2 + -0 * 0.3 / 2
    formation.y <- y - 0 * 0.3 * sqrt(3) / 2 + 1 * 0.3 / 2    
  }else if(which_f == 'f2'){
    formation.x <- x - 1 * 0.3 * sqrt(3) / 2 + 0 * 0.3 / 2
    formation.y <- y - 0 * 0.3 * sqrt(3) / 2 - 1 * 0.3 / 2    
  }else if(which_f == 'f3'){
    formation.x <- x - 1 * 0.3 * sqrt(3)
    formation.y <- y - 0 * 0.3 * sqrt(3)
  }
  
  formation_point <- c(formation.x, formation.y)
  return(formation_point)
}
fct.g_t_1_space <- function(start_p_input, end_p_input, max_dif, col, assumption, theta){
  # browser()
  half_x.1 <- seq(start_p_input[1], start_p_input[1] - max_dif, length.out = 10)
  p_y.1 <-  sqrt(max_dif^2 - (half_x.1-start_p_input[1])^2) + start_p_input[2]
  n_y.1 <-  -(sqrt(max_dif^2 - (half_x.1-start_p_input[1])^2)) + start_p_input[2]
  
  p_y.1[is.nan(p_y.1)] <- start_p_input[2]
  n_y.1[is.nan(n_y.1)] <- start_p_input[2]
  
  
  x.1 = c(half_x.1, half_x.1)
  y.1 = c(p_y.1, n_y.1)
  # left half circle
  # lines(half_x.1, n_y.1)
  rotated_start_p_input <- fct.general_rotate(start_p_input[1], start_p_input[2], theta )
  rotated_left_harf_n <- fct.general_rotate(half_x.1, n_y.1, theta )
  
  # polygon(c(start_p_input[1], half_x.1, start_p_input[1]), c(start_p_input[2], n_y.1, start_p_input[2]), col=adjustcolor(col,alpha.f=0.2), border=NA)
  rotated_left_half_circle_n <- c(rotated_start_p_input[1], rotated_left_harf_n[1:10], rotated_start_p_input[1], rotated_start_p_input[2], rotated_left_harf_n[11:20], rotated_start_p_input[2])
  polygon(rotated_left_half_circle_n[1:12], rotated_left_half_circle_n[13:24], col=adjustcolor(col,alpha.f=0.2), border=NA)
  
  
  rotated_left_harf_p <- fct.general_rotate(half_x.1, p_y.1, theta )
  # lines(half_x.1, p_y.1)
  # polygon(c(start_p_input[1], half_x.1, start_p_input[1]), c(start_p_input[2], p_y.1, start_p_input[2]), col=adjustcolor(col,alpha.f=0.2), border=NA)
  rotated_left_half_circle_p <- c(rotated_start_p_input[1], rotated_left_harf_p[1:10], rotated_start_p_input[1], rotated_start_p_input[2], rotated_left_harf_p[11:20], rotated_start_p_input[2])
  polygon(rotated_left_half_circle_p[1:12], rotated_left_half_circle_p[13:24], col=adjustcolor(col,alpha.f=0.2), border=NA)
  
  
  
  
  half_x.2 <- seq(end_p_input[1], end_p_input[1] + max_dif, length.out = 10)
  p_y.2 <-  sqrt(max_dif^2 - (half_x.2-end_p_input[1])^2) + end_p_input[2]
  p_y.2[10] <- end_p_input[2]
  n_y.2 <-  -(sqrt(max_dif^2 - (half_x.2-end_p_input[1])^2)) + end_p_input[2]
  n_y.2[10] <- end_p_input[2]
  x.2 = c(half_x.2, half_x.2)
  y.2 = c(p_y.2, n_y.2)
  
  if(assumption == 'normal'){
    
    # right half circle
    # lines(half_x.2, p_y.2)
    right_half_circle_n.x <- c(end_p_input[1], half_x.2, end_p_input[1])
    right_half_circle_n.y <- c(end_p_input[2], n_y.2, end_p_input[2])
    
    rotated_right_half_circle_n <- fct.general_rotate(right_half_circle_n.x, right_half_circle_n.y, theta )
      
    polygon(rotated_right_half_circle_n[1:12], rotated_right_half_circle_n[13:24], col=adjustcolor(col,alpha.f=0.2), border=NA)
    # lines(half_x.2, n_y.2)
    
    right_half_circle_p.x <- c(end_p_input[1], half_x.2, end_p_input[1])
    right_half_circle_p.y <- c(end_p_input[2], p_y.2, end_p_input[2])
    
    rotated_right_half_circle_p <- fct.general_rotate(right_half_circle_p.x, right_half_circle_p.y, theta )
    
    polygon(rotated_right_half_circle_p[1:12], rotated_right_half_circle_p[13:24], col=adjustcolor(col,alpha.f=0.2), border=NA)
    
  }else if(assumption == 'assumption1'){
    # nothing
    # TODO
  }
  
  
  # up & down lines
  # lines(c(half_x.1[1], half_x.2[1]), c(p_y.1[1], p_y.2[1]))
  # lines(c(half_x.1[1], half_x.2[1]), c(n_y.1[1], n_y.2[1]))
  body.x <- c(half_x.1[1], half_x.2[1], half_x.2[1], half_x.1[1], half_x.1[1])
  body.y <- c(p_y.1[1], p_y.2[1], n_y.2[1], n_y.1[1], p_y.1[1])
  rotated_body <- fct.general_rotate(body.x, body.y, theta )
  
  polygon(rotated_body[1:5], rotated_body[6:10], col=adjustcolor(col,alpha.f=0.2), border=NA)
  
  
  polygon_coordinates <- data.frame(polygon.x = c(rotated_left_half_circle_n[1:12], rotated_left_half_circle_p[1:12], rotated_right_half_circle_n[1:12], rotated_right_half_circle_p[1:12]), polygon.y = c(rotated_left_half_circle_n[13:24], rotated_left_half_circle_p[13:24], rotated_right_half_circle_n[13:24], rotated_right_half_circle_p[13:24]))
  return(polygon_coordinates)
}


fct.figureout_possible_space <- function(mode, theta, which_follower){
  # param settings
  # parameters
  params.max_sp_dist <- 0.8
  params.maximum_dif_btw_goal_present_past <- 0.052
  params.max_dist_per_1tick <- 0.04
  
  # variables to fit
  # adjusted_start_point <- 0.168
  adjusted_start_point <- 0.0
  
  
  
  # leader's coordinates
  origin = c(0, 0)
  
  # 1) possible leader's g(t) space
  start_point = c(adjusted_start_point,0)
  end_point = c(0.5 * params.max_sp_dist, 0)
  
  # plotting canvas
  # below 1 line code is used when this function is excuted independently
  if(mode == 'independent'){
    plot(c(0,0.8), c(0,0), col = 'red', xlim = c(-1, 1.5), ylim = c(-1, 1), pch = 17)  
  }else if(mode == 'part_of'){
    points(c(0,0.8), c(0,0), col = 'red', xlim = c(-1, 1.5), ylim = c(-1, 1), pch = 17)
  }
  
  lines(c(start_point[1], end_point[1]), c(start_point[2], end_point[2]), col = 'red')
  
  
  
  # 2) possible current g(t) space: line
  f1_g_space_start_p = fct.formation('f1', start_point[1], start_point[2])
  f1_g_space_end_p = fct.formation('f1', end_point[1], end_point[2])
  # drawing line
  lines(c(start_point[1], f1_g_space_start_p[1]), c(start_point[2], f1_g_space_start_p[2]), lty = 2)
  lines(c(end_point[1], f1_g_space_end_p[1]), c(end_point[2], f1_g_space_end_p[2]), lty = 2)
  lines(c(f1_g_space_start_p[1], f1_g_space_end_p[1]), c(f1_g_space_start_p[2], f1_g_space_end_p[2]))
  
  
  
  
  # possible current g(t) space
  f2_g_space_start_p = fct.formation('f2', start_point[1], start_point[2])
  f2_g_space_end_p = fct.formation('f2', end_point[1], end_point[2])
  # drawing line
  # lines(c(f2_g_space_start_p[1], f2_g_space_end_p[1]), c(f2_g_space_start_p[2], f2_g_space_end_p[2]))
  
  # possible current g(t) space
  f3_g_space_start_p = fct.formation('f3', start_point[1], start_point[2])
  f3_g_space_end_p = fct.formation('f3', end_point[1], end_point[2])
  # drawing line
  # lines(c(f3_g_space_start_p[1], f3_g_space_end_p[1]), c(f3_g_space_start_p[2], f3_g_space_end_p[2]))
  
  
  
  
  
  # 3) possible g(t-1) space
  max_dif <- params.maximum_dif_btw_goal_present_past
  # fct.g_t_1_space(f1_g_space_start_p, f1_g_space_end_p, max_dif, 'green', 'normal')
  
  # possible sp(t-1) space
  max_dif.2 <- 0.5 * params.max_sp_dist
  
  # fct.g_t_1_space(f1_g_space_start_p, f1_g_space_end_p, max_dif.2, 'blue', 'normal', 0)
  # fct.g_t_1_space(f2_g_space_start_p, f2_g_space_end_p, max_dif.2, 'brown', 'normal', 0)
  # fct.g_t_1_space(f3_g_space_start_p, f3_g_space_end_p, max_dif.2, 'orange', 'normal', 0)
  # 
  # # t-1
  # points(f1_g_space_start_p[1] - 0.5 * params.max_sp_dist, f1_g_space_start_p[2], col = 'red')
  # points(f2_g_space_start_p[1] - 0.5 * params.max_sp_dist, f2_g_space_start_p[2], col = 'red')
  # points(f3_g_space_start_p[1] - 0.5 * params.max_sp_dist, f3_g_space_start_p[2], col = 'red')
  # 
  # # t-2
  # points(-0.04 + f1_g_space_start_p[1] - 0.5 * params.max_sp_dist, f1_g_space_start_p[2], col = 'red', pch = 2)
  # points(-0.04 + f2_g_space_start_p[1] - 0.5 * params.max_sp_dist, f2_g_space_start_p[2], col = 'red', pch = 2)
  # points(-0.04 + f3_g_space_start_p[1] - 0.5 * params.max_sp_dist, f3_g_space_start_p[2], col = 'red', pch = 2)
  # 
  # centroid.x <- 1/4 * (-0.04 * 3 + f1_g_space_start_p[1] - 0.5 * params.max_sp_dist + f2_g_space_start_p[1] - 0.5 * params.max_sp_dist + f3_g_space_start_p[1] - 0.5 * params.max_sp_dist)
  # points(centroid.x, f3_g_space_start_p[2], col = 'red', pch = '+')
  # 
  # points(centroid.x + 0.8, f3_g_space_start_p[2], col = 'red', pch = 4)
  
  # possible current sp(t) space
  max_dif.3 <- max_dif.2 + 2 * params.max_dist_per_1tick
  # the reason why "2 times" is that target drone can go opposite direction and leader drone can go right direction at the same time.
  max_dif.3 <- max_dif.2 + 2 * params.max_dist_per_1tick
  # theta <- pi * (1 / 6)
  # theta <- 0
  if(which_follower == 'f1'){
    result_this <- fct.g_t_1_space(f1_g_space_start_p, f1_g_space_end_p, max_dif.3, 'blue', 'normal', theta)
  }else if(which_follower == 'f2'){
    result_this <- fct.g_t_1_space(f2_g_space_start_p, f2_g_space_end_p, max_dif.3, 'brown', 'normal', theta)
  }else if(which_follower == 'f3'){
    result_this <- fct.g_t_1_space(f3_g_space_start_p, f3_g_space_end_p, max_dif.3, 'orange', 'normal', theta)
  }
  
  return(result_this)

}



### test
polygon_table.1 <- NULL
theta <- 0.367173833818219 *2
for (poly_idx in 0:8){
  polygon_table.1 <- rbind(polygon_table.1, fct.figureout_possible_space('independent', theta  - poly_idx * 0.25 * (theta), 'f1'))
  
}

# points(polygon_table.1)

###########


# for test
# meuse_sf = st_as_sf(polygon_table.1, coords = c("polygon.x", "polygon.y"), crs = 4326)
# 
# hulls <- concaveman(meuse_sf, concavity = 2, length_threshold = 1)
# 
# result_possible_space <- lapply(as(hulls, "Spatial")@polygons,function(p) data.frame(p@Polygons[[1]]@coords))
# final_res_coord <- result_possible_space[[1]]
# 
# 
# final_res_coord
# plot(polygon_table.1, pch = 20, cex = 1, reset = FALSE, axes = T)
# plot(hulls, add = TRUE, border = 'grey70', col = NA)

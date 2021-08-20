#!/usr/bin/env python
import numpy as np
import math
from numpy.linalg import norm
import matplotlib.pyplot as plt
from scipy.ndimage.morphology import distance_transform_edt as bwdist

# Potential Fields functions
def grid_map(obstacles, nrows=500, ncols=500):
    """ Obstacles dicretized map """
    grid = np.zeros((nrows, ncols));
    # rectangular obstacles
    for obstacle in obstacles:

        x1 = meters2grid(obstacle[0][1]); x2 = meters2grid(obstacle[2][1])
        
        y1 = meters2grid(obstacle[0][0]); y2 = meters2grid(obstacle[2][0])
        if x1 > x2: tmp = x2; x2 = x1; x1 = tmp
        if y1 > y2: tmp = y2; y2 = y1; y1 = tmp
        grid[x1:x2, y1:y2] = 1
    return grid

def meters2grid(pose_m, nrows=500, ncols=500):
    # [0, 0](m) -> [250, 250]
    # [1, 0](m) -> [250+100, 250]
    # [0,-1](m) -> [250, 250-100]
    if np.isscalar(pose_m):
        pose_on_grid = int( pose_m*100 + ncols/2 )

    else:
        pose_on_grid = np.array( np.array(pose_m)*100 + np.array([ncols/2, nrows/2]), dtype=int )
    return pose_on_grid
def grid2meters(pose_grid, nrows=500, ncols=500):
    # [250, 250] -> [0, 0](m)
    # [250+100, 250] -> [1, 0](m)
    # [250, 250-100] -> [0,-1](m)
    if np.isscalar(pose_grid):
        pose_meters = (pose_grid - ncols/2) / 100.0
    else:
        pose_meters = ( np.array(pose_grid) - np.array([ncols/2, nrows/2]) ) / 100.0
    return pose_meters

def writeFile(filename, contents):
    with open(str(filename), 'a') as f:
         f.write(str(contents) + '\n')

def original_combined_potential(obstacles_grid, goal, influence_radius=1, attractive_coef=1./700, repulsive_coef=200, nrows=500, ncols=500):
    """ Repulsive potential """ #original repulsive_coef=200
    
    goal = meters2grid(goal)

    d = bwdist(obstacles_grid==0)
    
    d2 = (d/100.) + 1 # Rescale and transform distances
    d0 = influence_radius + 1
    nu = repulsive_coef
    repulsive = nu*((1./d2 - 1./d0)**2)

    repulsive [d2 > d0] = 0
    
    """ Attractive potential """
    [x, y] = np.meshgrid(np.arange(ncols), np.arange(nrows))

    xi = attractive_coef
    attractive = xi * ( (x - goal[0])**2 + (y - goal[1])**2 ) # smaller thing is better
    
    """ Combine terms """
    total = attractive + repulsive
    return total, attractive, repulsive

def combined_potential(obstacles_grid, goal, d0_m_coef, influence_radius=1, attractive_coef=1./700, repulsive_coef=200, nrows=500, ncols=500):
    """ Repulsive potential """
    goal = meters2grid(goal)
    d = bwdist(obstacles_grid==0)
    d2 = (d/100.) + 1 # Rescale and transform distances
    d0 = influence_radius + 1

    nu = repulsive_coef
    repulsive = nu*((1./d2 - 1./d0)**2)
    repulsive [d2 > d0] = 0

    d0_m = influence_radius * d0_m_coef + 1
    repulsive_d0 = nu*((1./d2 - 1./d0_m)**2)
    repulsive_d0 [d2 > d0_m] = 0

    """ Attractive potential """
    [x, y] = np.meshgrid(np.arange(ncols), np.arange(nrows))
    xi = attractive_coef
    attractive = xi * ( (x - goal[0])**2 + (y - goal[1])**2 )

    """ Combine terms """
    total = attractive + repulsive
    return total, attractive, repulsive, d2, repulsive_d0


def gradient_planner (f, start, goal, maxiters=200):
    # gradient_planner : This function plans a path through a 2D
    # environment from a start to a destination based on the gradient of the
    # function f which is passed in as a 2D array. The two arguments
    # start_coords and end_coords denote the coordinates of the start and end
    # positions respectively in the array while max_its indicates an upper
    # bound on the number of iterations that the system can use before giving
    # up.
    # The output, route, is an array with 2 columns and n rows where the rows
    # correspond to the coordinates of the robot as it moves along the route.
    # The first column corresponds to the x coordinate and the second to the y coordinate

    [gy, gx] = np.gradient(-f);
    start_coords = meters2grid(start); end_coords = meters2grid(goal)
    route = np.array( [np.array(start_coords)] )
    dist_to_goal_array = []
    for i in range(maxiters):
        current_point = route[-1,:]
        current = grid2meters(current_point)
        plt.plot(current[0], current[1],'bo',color='red', markersize=2)
        plt.pause(0.01)
        dist_to_goal = norm(grid2meters(current_point)-grid2meters(end_coords))
        dist_to_goal_array.append(dist_to_goal)
        if len(dist_to_goal_array)==10 and abs(min(dist_to_goal_array) - max(dist_to_goal_array)) < 0.02:
        	print("Robot is stopped")
        	
        	break
        if dist_to_goal < 0.1: # [m]
            
            break
        iy, ix = np.array( current_point, dtype=int )
        vx = gx[ix, iy]
        vy = gy[ix, iy]
        dt = 1 / np.linalg.norm([vx, vy])
        next_point = current_point + dt*np.array( [vx, vy] )
        route = np.vstack( [route, next_point] )
    route = grid2meters(route)
    return route

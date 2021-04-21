#!/usr/bin/env python

"""
Autonumous navigation of robots formation with Layered path-planner:
- global planner: RRT
- local planner: Artificial Potential Fields
"""

import sys
import numpy as np
from numpy.linalg import norm
import matplotlib.pyplot as plt

from conf import *
from common import *
from tools import *
from rrt import *
from potential_fields import *
from new_tools import *

np.set_printoptions(threshold=np.inf, linewidth=np.inf)

# def pretend_local_planner(robot_id, goal, obstacles, params):
#     """
#     this is simple version of local_planner
#     < arg discribtion >
#     - robot_id is the id that indicated this drone.
#     - goal is the coordinates that this drone is supposed to be.
#     - obstacles includes moving_obstacles, wall, and other drones.
#     - params is set of parameters.
#     """
#     # for each drone
#     U_r = [][]
#     U_a = [][]
#     U_t = [][]
#     for x_each_cell in range(0: params.w_bound + 1): #x축 방향, y축 방향
#         for y_each_cell in range(0: params.w_bound + 1): #x축 방향, y축 방향 # for gradient, +1

#             x_target = robots[robot_id].sp[0] + 0.01 * ( -(w / 2.0) + x_each_cell)
#             y_target = robots[robot_id].sp[1] + 0.01 * ( -(w / 2.0) + y_each_cell)


#             closest_one = min(robots[0].distance_with_1stD[-1],
#                 robots[robot_id].distance_with_1stD[-1],
#                 robots[robot_id].distance_with_2ndD[-1],
#                 robots[robot_id].distance_with_3rdD[-1],
#                 robots[robot_id].distance_with_obs_btt[-1],
#                 robots[robot_id].distance_with_obs_dia[-1],
#                 robots[robot_id].distance_with_obs_ltr[-1],
#                 robots[robot_id].distance_with_obs_wall[-1]
#             )

#             d0 = params.influence_radius + 1
#             nu = params.repulsive_coef
#             if closest_one< d0 :
#                 U_r[x_each_cell][y_each_cell] = nu*((1./closest_one - 1./d0)**2)
#             else:
#                 U_r[x_each_cell][y_each_cell] = 0

#             xi = attractive_coef
#             U_a[x_each_cell][y_each_cell] = xi * ( (x - goal[0])**2 + (y - goal[1])**2 )

#             U_t[x_each_cell][y_each_cell] = U_r[x_each_cell][y_each_cell] + U_a[x_each_cell][y_each_cell] #one value

#     [gy, gx] = np.gradient(-U_t)


#     ax = np.mean(gx[1 : -2, 1 : -2])
#     ay = np.mean(gy[1 : -2, 1 : -2])
#     dt = 0.01 * params.drone_vel / norm([ax, ay]) if norm([ax, ay])!=0 else 0.01

#     robots[robot_id].sp += dt*np.array( [ax, ay] ) #+ 0.1*dt**2/2. * np.array( [ax, ay] )


# dynamic obstacles not needed
def move_obstacles(obs, params):
    # small cubes movement
    obs[-3] += np.array([0.015, 0.0]) * params.drone_vel
    obs[-2] += np.array([-0.005, 0.005]) * params.drone_vel / 2
    obs[-1] += np.array([0.0, 0.01]) * params.drone_vel / 2
    # obstacles[-1] += np.array([0.0, 0.008]) * params.drone_vel/2
    obstacles_ltr_record.append(obs[-3])
    obstacles_dia_record.append(obs[-2])
    obstacles_btt_record.append(obs[-1])
    return obs


# Metrics to measure (for postprocessing) # Is this for plotting? if so I don't need it.
class Metrics:
    def __init__(self):
        self.mean_dists_array = []
        self.max_dists_array = []
        self.centroid_path = [np.array([0,0])]
        self.centroid_path_length = 0
        self.robots = []
        self.vels_mean = []
        self.vels_max = []
        self.area_array = []
        self.cpu_usage_array = [] # [%]
        self.memory_usage_array = [] # [MiB]

        # TODO: this absolute path is very bad practice
        self.folder_to_save = '/home/rus/Desktop/'

metrics = Metrics()
arg_01 = 0

# Layered Motion Planning: RRT (global) + Potential Field (local) #core part, whole management
if __name__ == '__main__':
    # initializer()    ########################

    # arg_01 = int(sys.argv[2])
    params.rand_seed = int(sys.argv[2])
    print("seed_number: " + str(params.rand_seed) + "\n")
    writeFile(CONTR_PN, "\n")
    writeFile(CONTR_PN, "randomseed ["+str(params.rand_seed)+"]"+ " modified_value ["+str(float(sys.argv[3]))+"]")

    params.target_index = int(sys.argv[1])

    # load data

    data_robot1_sp_global = np.load("data/robot_1_sp_global.npy")
    data_robot2_sp_global = np.load("data/robot_2_sp_global.npy")
    data_robot3_sp_global = np.load("data/robot_3_sp_global.npy")
    data_robot4_sp_global = np.load("data/robot_4_sp_global.npy")

    data_robot1_sp = np.load("data/robot_1_sp.npy")
    data_robot2_sp = np.load("data/robot_2_sp.npy")
    data_robot3_sp = np.load("data/robot_3_sp.npy")
    data_robot4_sp = np.load("data/robot_4_sp.npy")

    data_obstacles = np.load("data/obstacles.npy")





    fig2D = plt.figure(figsize=(10,10)) #for background environment
    draw_map(OBSTACLES) #for background environment
    plt.plot(xy_start[0],xy_start[1],'bo',color='red', markersize=20, label='start') #for background environment
    plt.plot(xy_goal[0], xy_goal[1],'bo',color='green', markersize=20, label='goal') #for background environment

    P_long = rrt_path(OBSTACLES, xy_start, xy_goal, params) #SOLVER! focus on input and output! ******
    print('Path Shortenning...')
    P = ShortenPath(P_long, OBSTACLES, smoothiters=50) # P = [[xN, yN], ..., [x1, y1], [x0, y0]]

    traj_global = waypts2setpts(P, params)

    P = np.vstack([P, xy_start])
    plt.plot(P[:,0], P[:,1], linewidth=3, color='orange', label='Global planner path')
    plt.pause(0.5)

    sp_ind = 0
    robot1.route = np.array([traj_global[0,:]]) # So, this is the boss guy.
    robot1.sp = robot1.route[-1,:]


    followers_sp = formation(params.num_robots, leader_des=robot1.sp, v=np.array([0,-1]), l=params.interrobots_dist)
    #function call

    for i in range(len(followers_sp)): # for all followers
        robots[i+1].sp = followers_sp[i]
        robots[i+1].route = np.array([followers_sp[i]])

    # print('Start movement...')

    # putInInitialValue(followers_sp, robot1.sp) ########################
    simulation_tick = 1

    # writeIndex_dist_obs() ###################################
    write_index_contribution_others() ################################

    while True: # loop through all the setpoint from global planner trajectory, traj_global


        if simulation_tick == 160:
            if sys.argv[4] == "r":
                params.repulsive_coef = float(sys.argv[3]) * params.repulsive_coef# first trial
                print("["+str(simulation_tick)+"]params.repulsive_coef: "+str(params.repulsive_coef))
            elif sys.argv[4] == "a":
                params.attractive_coef = float(sys.argv[3]) * params.attractive_coef # second trial
                print("["+str(simulation_tick)+"]params.attractive_coef: "+str(params.attractive_coef))
            elif sys.argv[4] == "i":
                params.influence_radius = float(sys.argv[3]) * params.influence_radius # third trial
                print("["+str(simulation_tick)+"]params.influence_radius: "+str(params.influence_radius))
            elif sys.argv[4] == "d":
                params.interrobots_dist = float(sys.argv[3]) * params.interrobots_dist # 4th trial
                print("["+str(simulation_tick)+"]params.interrobots_dist: "+str(params.interrobots_dist))
            elif sys.argv[4] == "v":
                params.drone_vel = float(sys.argv[3]) * params.drone_vel # 5th trial
                print("["+str(simulation_tick)+"]params.drone_vel: "+str(params.drone_vel))
            elif sys.argv[4] == "b":
                params.w_bound = float(sys.argv[3]) * params.w_bound # 6th trial
                print("["+str(simulation_tick)+"]params.w_bound: "+str(params.w_bound))




        dist_to_goal = norm(robot1.sp - xy_goal)
        if dist_to_goal < params.goal_tolerance: # [m]
            print('Goal is reached')
            break
        ####################
        ### obstacles
        ####################

        if len(OBSTACLES)>2:
            OBSTACLES = move_obstacles(OBSTACLES, params)#data_obstacles[simulation_tick-1]#move_obstacles(obstacles, params, simulation_tick)

        # print("[log]temp shape obstacles: "+str(np.shape(obstacles)))
        # print("[log]temp obstacles: "+str(obstacles[-2]))

        # leader's setpoint from global planner
        ####################
        ### robot1.sp_global
        ####################
        robot1.sp_global = data_robot1_sp_global[simulation_tick-1] #traj_global[sp_ind,:]
        robot1.sp_global_record.append(robot1.sp_global) ##########################

        # contribution_others('for_leader', simulation_tick, followers_sp) ################################

        # correct leader's pose with local planner

        ####################
        ### robot1.sp
        ####################
        # robot1.new_local_planner(obstacles, params)
        robot1.sp = data_robot1_sp[simulation_tick-1]





        """ adding following robots in the swarm """
        # formation poses from global planner
        ####################
        ### robot2~4.sp_global
        ####################
        followers_sp_global = [data_robot2_sp_global[simulation_tick-1], data_robot3_sp_global[simulation_tick-1], data_robot4_sp_global[simulation_tick-1]]
        # followers_sp_global = formation(params.num_robots, robot1.sp_global, v=normalize(robot1.sp_global-robot1.sp), l=params.interrobots_dist)

        for i in range(len(followers_sp_global)):
            robots[i+1].sp_global = followers_sp_global[i]
            robots[i+1].sp_global_record.append(robots[i+1].sp_global) ##########################


        # print("[log]temp obstacles: "+str(obstacles[-2]))
        contribution_others('for_follower', simulation_tick, followers_sp) ################################

        ####################
        ### robot2~4.sp
        ####################

        robots[1].sp = data_robot2_sp[simulation_tick-1]
        robots[2].sp = data_robot3_sp[simulation_tick-1]
        robots[3].sp = data_robot4_sp[simulation_tick-1]

        for p in range(len(followers_sp)): # formation poses correction with local planner
            # robots repel from each other inside the formation
            # robots_obstacles_sp = [x for i,x in enumerate(followers_sp + [robot1.sp]) if i!=p] # all poses except the robot[p]
            # robots_obstacles = poses2polygons( robots_obstacles_sp ) # each drone is defined as a small cube for inter-robots collision avoidance
            # obstacles1 = np.array(obstacles + robots_obstacles) # combine exisiting obstacles on the map with other robots[for each i: i!=p] in formation
            # follower robot's position correction with local planner


            # robots[p+1].new_local_planner(obstacles1, params) #Here, attractive + repulsive
            followers_sp[p] = robots[p+1].sp


        # calculator_mainloop(obstacles1, robots_obstacles_sp)


        # centroid pose:
        centroid = 0
        for robot in robots: centroid += robot.sp / len(robots)
        metrics.centroid_path = np.vstack([metrics.centroid_path, centroid])
        # dists to robots from the centroid:
        dists = []
        for robot in robots:
            dists.append( norm(centroid-robot.sp) )
        # Formation size estimation
        metrics.mean_dists_array.append(np.mean(dists)) # Formation mean Radius #not needed
        metrics.max_dists_array.append(np.max(dists)) # Formation max Radius #not needed

        # Algorithm performance (CPU and memory usage)
        metrics.cpu_usage_array.append( cpu_usage() ) #not needed
        metrics.memory_usage_array.append( memory_usage() ) #not needed
        # print "CPU: ", cpu_usage()
        # print "Memory: ", memory_usage()

        # visualization #not needed
        # if params.visualize:
        #     plt.cla()
        #     visualize2D(simulation_tick, OBSTACLES)

        #     plt.draw()
        #     plt.pause(0.01)



        checker_crash(simulation_tick) ##########################

        checker_dist_obs(simulation_tick) ##########################
        # write_etc(simulation_tick) ##########################
        # checker_skip(simulation_tick, centroid) ###########

        simulation_tick += 1
        if sp_ind < traj_global.shape[0]-1 and norm(robot1.sp_global - centroid) < params.max_sp_dist: sp_ind += 1

# write_norm() ##########################
# calculator_new_score() ##########################
# calculator_new_score_considering_whole() ##########################
write_influence()

""" Flight data postprocessing """
if params.postprocessing: #not needed
    t_array = t_array[1:]
    metrics.t_array = t_array
    metrics.centroid_path = metrics.centroid_path[1:,:]
    metrics.centroid_path_length = path_length(metrics.centroid_path)
    for robot in robots: metrics.robots.append( robot )

    postprocessing(metrics, params, visualize=1)
    if params.savedata: save_data(metrics)

# close windows if Enter-button is pressed #not needed
# plt.draw()
# plt.pause(0.1)
# raw_input('Hit Enter to close')
# plt.close('all')
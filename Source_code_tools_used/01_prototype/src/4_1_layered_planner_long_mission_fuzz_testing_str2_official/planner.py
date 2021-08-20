#!/usr/bin/env python

"""
Autonumous navigation of robots formation with Layered path-planner:
- global planner: RRT
- local planner: Artificial Potential Fields
"""

import os
import sys
import time
import glob
import signal
import pickle
import shutil
import argparse
import itertools
import numpy as np
import matplotlib.pyplot as plt
import logging

from tqdm import tqdm
from numpy.linalg import norm

from conf import *
from common import *
from tools import *
from rrt import *
from potential_fields import *
from new_tools import *

np.set_printoptions(threshold=np.inf, linewidth=np.inf)

"""
USAGE:
    $ src/layered_planner/planner.py adswarm -k dcc
    $ src/layered_planner/planner.py adswarm -k random
    $ src/layered_planner/planner.py adswarm -k hardrun
"""

def exit_gracefully(original_sigint):
    def _exit_gracefully(signum, frame):
        signal.signal(signal.SIGINT, original_sigint)
        try:
            if sys.version_info[0] == 2:
                if raw_input("\nReally quit? (y/n)> ").lower().startswith('y'):
                    sys.exit(1)
            else:
                if input("\nReally quit? (y/n)> ").lower().startswith('y'):
                    sys.exit(1)
        except KeyboardInterrupt:
            print("Ok ok, quitting")
            sys.exit(1)
        signal.signal(signal.SIGINT, _exit_gracefully)
    return _exit_gracefully


def copy_obstacles(obs, modified):

    for obs_index in range(1, len(obs)):
        obs[obs_index] = copy.deepcopy(np.asarray(modified[obs_index]))

    return obs


"""
(CJ) Attack drone code: below
1. move_obstacles
2. targetting
3. vector transformation
"""

"""
make_target_coor fuction make the target coor following the physical rule.
INPUT: 1) goal (1*2 np.array), 2) vel_atk_drone (float or integer), 3) current_atk_coor (1*2 np.array)
OUTPUT: target_coor

So, control the goal!
"""


def make_target_coor(goal, vel_atk_drone, current_atk_coor):
    """
    goal + current_atk_coor -> direction vector
    direction vector + vel_atk_drone -> target_vector
    target_vector + current_atk_coor -> target_coor
    for example, vel_atk_drone = *** 4.0 m/s ***
    """
    direction_vector = goal - current_atk_coor

    target_coor = current_atk_coor + 0.01 * \
        vel_atk_drone * (direction_vector / norm(direction_vector))

    return target_coor


"""
Here, in move_obstacles, it just moves atk drone simply to the target coordination
Hence, it requires a function that can offer the realistic (physically) target following certain logic.

"""

# TODO: (Later) It should be divided into each atk drone's function (e.g., move_atk_drone_1(),...)
# TODO: Overlap the drone Icon!
# this moves only 1 atk_drone for now: obs[-3]


def move_obstacles(obs, params, special_target_1, special_target_2):
    temp_target_1 = copy.deepcopy(special_target_1)
    temp_target_2 = copy.deepcopy(special_target_2)

    temp_bit = params.obst_size_bit  # for the size of obstacle: default

    obs[-3] = [[temp_target_1[0], temp_target_1[1]], [temp_target_1[0] + temp_bit, temp_target_1[1]],
               [temp_target_1[0] + temp_bit, temp_target_1[1] + temp_bit], [temp_target_1[0], temp_target_1[1] + temp_bit]]
    # obs[-3] += np.array([-0.007, 0.0]) * params.drone_vel / 2
    # obs[-2] += np.array([-0.007, 0.0]) * params.drone_vel / 2
    obs[-2] = [[temp_target_2[0], temp_target_2[1]], [temp_target_2[0] + temp_bit, temp_target_2[1]],
               [temp_target_2[0] + temp_bit, temp_target_2[1] + temp_bit], [temp_target_2[0], temp_target_2[1] + temp_bit]]
    obs[-1] += np.array([0.005, 0.0]) * params.drone_vel / 2
    return obs

""" TODO: remove this
Spawn attack drones randomly in each zone
Zone 1: 0.3-0.4
Zone 2: 0.4-0.5
Zone 3: 0.5-0.6
"""

def spawn_attack_drone(target_coor, zone_idx, params):
    spawning_coor = copy.deepcopy(target_coor)
    zone_coef = 0
    sign_x = np.random.randint(2) * 2 - 1
    sign_y = np.random.randint(2) * 2 - 1
    print("sign_x: " + str(sign_x) + " sign_y: "+str(sign_y))

    if zone_idx == 1:
        zone_coef = 0.2

    elif zone_idx == 2:
        zone_coef = 0.3

    elif zone_idx == 3:
        zone_coef = 0.4

    rnd_x = sign_x * (float(np.random.rand(1)) * 0.1 + zone_coef)  # [0.1)
    rnd_y = sign_y * (float(np.random.rand(1)) * 0.1 + zone_coef)

    spawning_coor[0] += rnd_x
    spawning_coor[1] += rnd_y

    return spawning_coor


def ret_init_log(seed, mod_val, x, y):
    return "randomseed [%d] modified_value [%s] x[%f] from [%d]" \
        % (seed, mod_val, x, y)


def print_coef(tick, purpose, param):
    msg = "[%d] %s: %f" % (tick, COEF[purpose], param)
    print(msg)


def print_hdr(tick, p_tick):
    msg = "[%d] modification starts at: %d" % (tick, p_tick)
    print(msg)


def modify_obstacle(obs, x):
    modified_obs = [(
        obs[-x][0][0] + obs[-x][1][0] + obs[-x][2][0] + obs[-x][3][0])
        * 0.25,
        (obs[-x][0][1] + obs[-x][1][1] + obs[-x][2][1] + obs[-x][3][1])
        * 0.25]
    return modified_obs


def ret_boundary(val):
    # return min/med/max value
    min_val = val * 0.5
    max_val = val * 2
    med_val = (min_val + max_val) / 2

    return [min_val, med_val, max_val]


def ret_minmax(_param):
    # return array of min/med/max of each coef

    rep_arr = ret_boundary(_param.repulsive_coef)
    att_arr = ret_boundary(_param.attractive_coef)
    inf_arr = ret_boundary(_param.influence_radius)
    int_arr = ret_boundary(_param.interrobots_dist)
    dro_arr = ret_boundary(_param.drone_vel)
    wbo_arr = ret_boundary(_param.w_bound)

    return [rep_arr, att_arr, inf_arr, int_arr, dro_arr, wbo_arr]


def _ret_log(record, idx):
    _msg = str(-idx)

    for x in range(11):
        _msg += " " + str(record[-idx][x][0]) + " " + str(record[-idx][x][1])
    return _msg


def ret_log(record, idx, param, args, simul_tick):
    msg = "%d randomseed [%d] modified_value [%s] x[%f] \
from [%d] simul_tick [%d] " \
          % (args[5], args[1], args[3], args[2], args[4], simul_tick)
    msg += _ret_log(record, idx)
    msg += " " + str(param.crash)
    msg += " " + str(param.info_crashed_drone)
    msg += " " + str(param.info_crashed_obs)
    msg += " " + str(param.info_crashed_time)
    msg += " " + str(param.info_trapped_drone)
    return msg


def ret_crash_log(param, args, simul_tick, randometest_order):
    msg = "%d randomseed [%d] modified_value [%s] x[%f] \
from [%d] simul_tick [%d] " \
          % (args[5], args[1], args[3], args[2], args[4], simul_tick)
    msg += " " + str(param.crash)
    msg += " " + str(param.info_crashed_drone)
    msg += " " + str(param.info_crashed_obs)
    msg += " " + str(param.info_crashed_time)
    msg += " " + str(param.info_trapped_drone)
    msg += " " + str(param.info_crashed_dist)
    msg += " " + str(randometest_order)
    return msg

def fuzz_one(args, obstacle_type, feedback_type,  check_crash=False, manual_mode=False, param_setting='None', randometest_order=1):
    # Each run initialize parameters using below code.
    start_time = time.time()
    params = Params()

    # TODO: this is not good, but use temporaly
    p_target, p_seed, p_coef, p_purpose, p_tick, p_idx = args
    print("[log]args[p_target, p_seed, p_coef, p_purpose, p_tick, p_idx]: "+str(args))
    print("[log] xy_start: "+str(xy_start[-1]))

    params.rand_seed = p_seed
    params.target_index = p_target

    print("[log]seed_number: " + str(params.rand_seed) + "\n")
    if ATTACK_TARGET_MODE == 'random': random_attack_target_gen(params)

    if param_setting is 'record':
        print("[record]fuzz_one starts")
        # it can control each run to make it either 'pure' or 'partial replay'.
        # it depends on whether 'params.mode_replay = True and p_idx = 0' or not
        params.contribution = True

        if p_idx == 0:  # which means that it goes 'pure' sim.
            params.mode_replay = False                      # False, either is ok
            print("[record] 'pure' sim starts")
            # when mode_replay is False, it runs sim from the scrach for making pure trajectory.
        else:  # which means that it goes rollback sim.
            params.mode_replay = True                      # False, either is ok
            print("[record] 'rollback' sim starts")
            # when it is partial replay, it should be True.
        params.mode_stop_before_obs = False            # it should go to the goal
        params.crash_check_for_random_testing = False
        params.mode_randomtesting = False
        # if it is False, loading folder is set as 'fixed_pure'.
        params.mode_record_trajectory_replay = True
        params.already_written_allsp = False
        params.mode_defective = False
        # make sure sim is not ended after recording coordinates on all_sp.log
    else:
        print("err param setting is not defined by user.")
        sys.exit(1)

    robots = []

    for i in range(params.num_robots):
        robots.append(Robot(i+1))

    robot1 = robots[0]
    robot1.leader = True
    rbt = robot1

    global OBSTACLES
    OBSTACLES = copy.deepcopy(obstacle_type)

    obst_1 = []
    obst_2 = []
    obst_3 = []
    coord_record = []
    """
    rbt: robots
    args: p_target, p_seed, p_coef, p_purpose, p_tick, p_idx
    check_crash: check crash for each tick
    manual_mode: manually modify params coef?
    """

    '''[replay] declare variables '''
    # TODO: check and remove it
    if params.mode_record_trajectory_replay is True:
        com_robot_1_sp_global = []
        com_robot_2_sp_global = []
        com_robot_3_sp_global = []
        com_robot_4_sp_global = []
        com_robot_1_sp = []
        com_robot_2_sp = []
        com_robot_3_sp = []
        com_robot_4_sp = []
        com_obstacles = []
    fliped_coin = []

    msg = ret_init_log(p_seed, p_purpose, p_coef, p_tick)

    if params.contribution is True:
        writeFile(CONTR_PN, "\n" + msg)

    if params.all_sp_record_for_replay is True:
        writeFile(ALLSP_PN, msg + "\n" + HEADER)

    if params.visualize:
        draw_map(OBSTACLES)  # for background environment
        plt.plot(
            xy_start[-1][0], xy_start[-1][1], 'bo', color='red',
            markersize=20, label='start')  # for background environment
        plt.plot(
            xy_goal[0], xy_goal[1], 'bo', color='green',
            markersize=20, label='goal')  # for background environment

    '''[replay] loading data'''
    if params.mode_replay is True:

        simul_tick = int(p_tick)

        if params.mode_randomtesting is True:
            if p_coef == 2:
                temp_coef = '2.0'
            elif p_coef == 0.2:
                temp_coef = '0.2'
            folderNamePure = "for_randomtesting/" + \
                str(p_purpose)+"_x"+str(temp_coef)+"_rollback_" + str(p_idx)
        else:
            folderNamePure = "fixed_pure"

        print("[log] trajectory is from: "+folderNamePure)

        data_robot1_sp_global = np.load(
            REPLAY_DIR + "/" + str(folderNamePure) +
            "/" + str(params.rand_seed)
            + "/robot_1_sp_global_" + str(params.rand_seed) + ".npy")
        data_robot2_sp_global = np.load(
            REPLAY_DIR + "/" + str(folderNamePure) +
            "/" + str(params.rand_seed)
            + "/robot_2_sp_global_" + str(params.rand_seed) + ".npy")
        data_robot3_sp_global = np.load(
            REPLAY_DIR + "/" + str(folderNamePure) +
            "/" + str(params.rand_seed)
            + "/robot_3_sp_global_" + str(params.rand_seed) + ".npy")
        data_robot4_sp_global = np.load(
            REPLAY_DIR + "/" + str(folderNamePure) +
            "/" + str(params.rand_seed)
            + "/robot_4_sp_global_" + str(params.rand_seed) + ".npy")

        data_robot1_sp = np.load(
            REPLAY_DIR + "/" + str(folderNamePure) +
            "/" + str(params.rand_seed)
            + "/robot_1_sp_" + str(params.rand_seed) + ".npy")
        data_robot2_sp = np.load(
            REPLAY_DIR + "/" + str(folderNamePure) +
            "/" + str(params.rand_seed)
            + "/robot_2_sp_" + str(params.rand_seed) + ".npy")
        data_robot3_sp = np.load(
            REPLAY_DIR + "/" + str(folderNamePure) +
            "/" + str(params.rand_seed)
            + "/robot_3_sp_" + str(params.rand_seed) + ".npy")
        data_robot4_sp = np.load(
            REPLAY_DIR + "/" + str(folderNamePure) +
            "/" + str(params.rand_seed)
            + "/robot_4_sp_" + str(params.rand_seed) + ".npy")

        data_obstacles = np.load(
            REPLAY_DIR + "/fixed_obstacles/obstacles_for_1000tick.npy")  # fixed

        print('Path loading...')

        traj_global = data_robot1_sp_global

        sp_ind = simul_tick - 1

        # for sync and making npy for random sampling
        if params.mode_record_trajectory_replay is True:
            # In this way, history from the npy loaded can be used early history of this version again.

            for index_npy in range(0, simul_tick - 1):
                com_robot_1_sp_global.append(
                    copy.deepcopy(data_robot1_sp_global[index_npy]))
                com_robot_2_sp_global.append(
                    copy.deepcopy(data_robot2_sp_global[index_npy]))
                com_robot_3_sp_global.append(
                    copy.deepcopy(data_robot3_sp_global[index_npy]))
                com_robot_4_sp_global.append(
                    copy.deepcopy(data_robot4_sp_global[index_npy]))
                com_robot_1_sp.append(copy.deepcopy(data_robot1_sp[index_npy]))
                com_robot_2_sp.append(copy.deepcopy(data_robot2_sp[index_npy]))
                com_robot_3_sp.append(copy.deepcopy(data_robot3_sp[index_npy]))
                com_robot_4_sp.append(copy.deepcopy(data_robot4_sp[index_npy]))
                com_obstacles.append(copy.deepcopy(data_obstacles[index_npy]))

    else:
        simul_tick = 1

        # SOLVER. focus on input and output!
        P_long = rrt_path(OBSTACLES, xy_start[-1], xy_goal, params)
        print('Path Shortenning...')

        # P = [[xN, yN], ..., [x1, y1], [x0, y0]]
        P = ShortenPath(P_long, OBSTACLES, params, smoothiters=50)
        traj_global = waypts2setpts(P, params)
        P = np.vstack([P, xy_start[-1]])

        if params.visualize or "DEBUG" in os.environ:
            plt.plot(
                P[:, 0], P[:, 1], linewidth=3, color='orange',
                label='Global planner path')
            plt.pause(0.5)

        sp_ind = 0

    rbt.route = np.array([traj_global[0, :]])

    # rbt.sp = rbt.route[-1, :]

    # followers_sp = formation(
    #     params.num_robots, leader_des=rbt.sp, v=np.array([0, 1]),
    #     l=params.interrobots_dist)
    # adjust start position a little bit

    followers_sp = [[0, 0], [0, 0], [0, 0]]

    rbt.sp = copy.deepcopy(drone_01[-1])
    followers_sp[0] = copy.deepcopy(drone_02[-1])
    followers_sp[1] = copy.deepcopy(drone_03[-1])
    followers_sp[2] = copy.deepcopy(drone_04[-1])

    # print("[dbg]followers_sp: "+str(followers_sp))

    for i in range(len(followers_sp)):  # for all followers
        robots[i + 1].sp = followers_sp[i]
        robots[i + 1].route = np.array([followers_sp[i]])

    '''
    [replay]
    Insert coodinates of obstacles, robot1.sp, 2,3,4.sp and robot1.sp_global,2,3,4
    '''
    if params.mode_replay is True:

        if params.mode_randomtesting is True:
            # when random testing, we give 4 tick more for stabilization
            OBSTACLES = copy_obstacles(
                OBSTACLES, data_obstacles[simul_tick - 6])

            temp_index = 1
            # this is overwritten later
            rbt.sp_global = data_robot1_sp_global[temp_index]

            if p_coef == 2:
                temp_coef = '2.0'
            elif p_coef == 0.2:
                temp_coef = '0.2'
            filename = 'randomtesting/input/1000/randomized_' + \
                str(p_purpose)+'_x'+str(temp_coef) + \
                '_rollback_'+str(p_idx)+'.csv'
            print("[log] coordinates are from: "+filename)

            myFile = np.array(pd.read_csv(filename, sep=','))

            index_randomseed = 1  # fixed

            index_input = randometest_order

            if myFile[index_input][index_randomseed] is p_seed:
                rbt.sp[0] = myFile[index_input][7]
                rbt.sp[1] = myFile[index_input][8]  # 0 means the first low

                robots[1].sp[0] = myFile[index_input][9]
                robots[1].sp[1] = myFile[index_input][10]

                robots[2].sp[0] = myFile[index_input][11]
                robots[2].sp[1] = myFile[index_input][12]

                robots[3].sp[0] = myFile[index_input][13]
                robots[3].sp[1] = myFile[index_input][14]

                print("[log] coordinates are inserted when p_seed is : " +
                      str(myFile[index_input][index_randomseed]))

        else:

            OBSTACLES = copy_obstacles(
                OBSTACLES, data_obstacles[simul_tick - 2])

            rbt.sp_global = data_robot1_sp_global[simul_tick - 2]

            rbt.sp = data_robot1_sp[simul_tick - 2]

            followers_sp_global = \
                [data_robot2_sp_global[simul_tick - 2],
                 data_robot3_sp_global[simul_tick - 2],
                 data_robot4_sp_global[simul_tick - 2]]

            robots[1].sp = data_robot2_sp[simul_tick - 2]
            robots[2].sp = data_robot3_sp[simul_tick - 2]
            robots[3].sp = data_robot4_sp[simul_tick - 2]

        print("[log] coordinates data is loaded from npy at ["+str(simul_tick)+"]")

    for p in range(len(followers_sp)):
        followers_sp[p] = robots[p + 1].sp

    '''
    TODO: [random testing]
    Unlike the replay,
    This should read coordinates from not npy but csv
    Also, it's ok that only each sp is loaded.
    '''

    print('Start movement...')

    writeIndex_dist_obs(p_purpose, p_coef, p_tick, params)

    write_index_contribution_others()

    '''main simulation loop'''
    # loop through all the setpoint from global planner

    res_suc_fail = "Succeeded"
    writeFile(RES, res_suc_fail)

    for x in tqdm(range(MAX_TICK)):

        if "DEBUG" in os.environ:
            start_time = time.time()

        # default mode: modify coef, at the specified tick
        if simul_tick == p_tick and manual_mode is False:

            print_hdr(simul_tick, p_tick) # TODO

            if p_purpose == "r":
                params.repulsive_coef = p_coef * params.repulsive_coef
                print_coef(simul_tick, p_purpose, params.repulsive_coef)

            elif p_purpose == "a":
                params.attractive_coef = p_coef * params.attractive_coef
                print_coef(simul_tick, p_purpose, params.attractive_coef)

            elif p_purpose == "i":
                params.influence_radius = p_coef * params.influence_radius
                print_coef(simul_tick, p_purpose, params.influence_radius)

            elif p_purpose == "d":
                params.interrobots_dist = p_coef * params.interrobots_dist
                print_coef(simul_tick, p_purpose, params.interrobots_dist)

            elif p_purpose == "v":
                params.drone_vel = p_coef * params.drone_vel
                print_coef(simul_tick, p_purpose, params.drone_vel)

            elif p_purpose == "b":
                params.w_bound = p_coef * params.w_bound
                print_coef(simul_tick, p_purpose, params.w_bound)

        # otherwise, we fix manually
        else:
            pass

        dist_to_goal = norm(rbt.sp - xy_goal)
        # print("[dbg]dist_to_goal: "+str(dist_to_goal))
        if dist_to_goal < params.goal_tolerance:
            print('Goal is reached')

            # update the coordinates for next run
            fall_back = 3.5  # 3.5 when 1.0

            # drone_01.append(rbt.sp - [fall_back, 0])
            # drone_02.append(followers_sp[0] - [fall_back, 0])
            # drone_03.append(followers_sp[1] - [fall_back, 0])
            # drone_04.append(followers_sp[2] - [fall_back, 0])

            # xy_start.append(rbt.sp - [(fall_back-0.3), 0])
            # xy_start = rbt.sp - [fall_back, 0]
            # update_xy_start(rbt.sp - [fall_back, 0])

            # msg = " > Goal reached at %d ticks" % simul_tick
            elapsed_time = time.time() - start_time
            msg = "Goal reached: randomseed [%d] modified_value [%s] x[%f] from [%d] \
simul_tick [%d] with [%f] in zone_[%d] speedX [%f] obsSize [%f]" % \
                  (p_seed, p_purpose, p_coef, p_tick,
                   simul_tick, elapsed_time, zone_idx, temp_coef_atk_vel, params.obst_size_bit)

            writeFile(ATTACK_RES, msg)
            break

        if simul_tick == 147:
            robots[1].sp[0] += 0.05

        if simul_tick == 149:
            robots[1].sp[1] -= 0.05

        if simul_tick == 149:
            robots[1].sp[1] -= 0.05

        centroid = copy.deepcopy(robots[1].sp)

        if len(OBSTACLES) > 2:
            # change poses of some obstacles on the map
            """
            (CJ)
            Control the goal for attack drone 1
            Control the velocity of the attack drone

            Strategy a: to x-axis, in front of robots[3] by 0.2 m
            Strategy b: to x-axis, back of robots[3] by - 0.1 m
            Strategy c: move to center point precisely between robots[1] and robots[3]
            Strategy d: set the target as leader to move swarm north by + 0.2m
            Strategy e(new): move around based on centroid

            """
            strategy = ATTACK_STRATEGY
            fuzz_test = 'false'
            zone_idx = 0

            if strategy == 'a':
                target_i_1 = 3

                # below 2 line is for original attack
                goal_for_atk_1 = copy.deepcopy(robots[target_i_1].sp)
                # goal_for_atk_1[0] -= 0.3
                goal_for_atk_1[0] = 0.0 # TODO: current version is fixed like this shit
                goal_for_atk_1[1] = 2.0 # TODO: current version is fixed like this shit
                # TODO: set this attacker free
                params.victim_index_1 = target_i_1

                target_i_2 = params.attack_target # TODO: later re-organization is needed
                goal_for_atk_2 = copy.deepcopy(robots[target_i_2].sp)
                goal_for_atk_2[0] -= ATTACK_DISTANCE  # this is for strategy a
                params.victim_index_1 = target_i_2

            elif strategy == 'b':
                target_i_1 = 2
                dist_from_victim = 0.3
                # goal_for_atk_1 = copy.deepcopy(robots[target_i].sp)
                # goal_for_atk_1[0] += dist_from_victim  # this is for strategy b

                inverse_direction_vec_victim_1 = robots[target_i_1].sp - \
                    robots[target_i_1].sp_global

                goal_for_atk_1 = robots[target_i_1].sp + dist_from_victim * \
                    inverse_direction_vec_victim_1 / \
                    norm(inverse_direction_vec_victim_1)

                goal_for_atk_1[0] = 0.0
                goal_for_atk_1[1] = 2.4

                params.victim_index_1 = target_i_1

                target_i_2 = params.attack_target

                inverse_direction_vec_victim_2 = robots[target_i_2].sp - \
                    robots[target_i_2].sp_global

                goal_for_atk_2 = robots[target_i_2].sp + dist_from_victim * \
                    inverse_direction_vec_victim_2 / \
                    norm(inverse_direction_vec_victim_2)

                params.victim_index_2 = target_i_2

            elif strategy == 'c':
                goal_for_atk_1 = copy.deepcopy(
                    0.5 * (robots[3].sp + robots[1].sp))

                goal_for_atk_1[0] = 0.0
                goal_for_atk_1[1] = 3.0

                # goal_for_atk_2 = copy.deepcopy(
                #     0.5 * (robots[0].sp + robots[1].sp))
                goal_for_atk_2 = robots[0].sp + \
                    0.50 * (robots[1].sp - robots[0].sp)

            elif strategy == 'd':
                min_y_target = np.array([2.5, 2.5])  # the right upper corner
                # max_y_target_2 = np.array([2.5, 2.5])  # the right upper corner
                # the right upper corner
                min_y_target_1 = np.array([2.5, 2.5])  # the left to right
                # min_y_target_1 = np.array([-2.5, 2.5]) # the right to left
                max_y_target_2 = np.array([-2.5, -2.5])

                for target_i in range(0, 4):

                    # if min_y_target[1] > robots[target_i].sp[1]: # from down toward up
                    # from right toward left
                    # if min_y_target_1[0] < robots[target_i].sp[0]:
                    # from left toward right
                    if min_y_target_1[0] > robots[target_i].sp[0]:
                        min_y_target_1 = copy.deepcopy(robots[target_i].sp)

                        # set the param_target
                        params.victim_index_1 = target_i
                        # print("params.victim_index_1 in move: " +
                        #       str(params.victim_index_1))

                    # from left toward right
                    if max_y_target_2[1] < robots[target_i].sp[1]:
                        max_y_target_2 = copy.deepcopy(robots[target_i].sp)

                        # set the param_target
                        params.victim_index_2 = target_i

                goal_for_atk_1 = min_y_target_1
                goal_for_atk_2 = max_y_target_2
                # goal_for_atk_1[1] -= 0.2  # from down toward up
                goal_for_atk_1[0] -= 0.2  # from left toward right
                # goal_for_atk_1[0] += 0.2  # from right toward left

                goal_for_atk_2[1] += 0.2  # from left toward right

            elif strategy == 'e':
                # circling
                distance_from_centroid = 1.0

                # theta_based_on_centroid = math.pi() / 4

                goal_for_atk_1 = copy.deepcopy(
                    0.3 * (robots[3].sp + robots[1].sp))

                goal_for_atk_1[0] = 0.0
                goal_for_atk_1[1] = 2.4

                goal_for_atk_2 = copy.deepcopy(centroid)
                goal_for_atk_2[0] = centroid[0] + \
                    distance_from_centroid * \
                    math.sin(params.theta_based_on_centroid)
                goal_for_atk_2[1] = centroid[1] + \
                    distance_from_centroid * \
                    math.cos(params.theta_based_on_centroid)

                params.theta_based_on_centroid += math.pi() / 4

            # Here set the vel

            # if params.rand_seed % 5 == 0:
            #     # temp_coef_atk_vel = 2.0  # default

            # elif params.rand_seed % 5 == 1:
            #     # temp_coef_atk_vel = 1.75  # **

            # elif params.rand_seed % 5 == 2:
            #     temp_coef_atk_vel = 1.5  # **

            # elif params.rand_seed % 5 == 3:
            #     # temp_coef_atk_vel = 1.25  # **

            # elif params.rand_seed % 5 == 4:
            #     temp_coef_atk_vel = 1.0  # **

            temp_coef_atk_vel = 2.0

            # if params.rand_seed % 2 == 0:
            #     params.obst_size_bit = 0.141
            # elif params.rand_seed % 2 == 1:
            #     params.obst_size_bit = 0.0707

            # if params.rand_seed % 4 == 0:
            #     temp_coef_atk_vel = 1.5  # **

            # elif params.rand_seed % 4 == 1:
            #     temp_coef_atk_vel = 1.0  # **

            # elif params.rand_seed % 4 == 2:
            #     params.obst_size_bit = 0.141

            # elif params.rand_seed % 4 == 3:
            #     params.obst_size_bit = 0.0707

            vel_atk_drone = temp_coef_atk_vel * params.drone_vel

            special_target_1 = make_target_coor(
                goal_for_atk_1, vel_atk_drone, OBSTACLES[-3][0])

            special_target_2 = make_target_coor(
                goal_for_atk_2, vel_atk_drone, OBSTACLES[-2][0])

            OBSTACLES = move_obstacles(
                OBSTACLES, params, special_target_1, special_target_2)

            """
            SPAWN magic # TODO: make this simpler
            """
            if fuzz_test == 'true':
                if simul_tick == params.spawntime:
                    # Target: robots[3].sp

                    if params.rand_seed % 3 == 0:
                        zone_idx = 1
                    elif params.rand_seed % 3 == 1:
                        zone_idx = 2
                    elif params.rand_seed % 3 == 2:
                        zone_idx = 3

                    special_target_1 = spawn_attack_drone(
                        robots[3].sp, zone_idx, params)

                    special_target_2 = spawn_attack_drone(
                        robots[2].sp, zone_idx, params)  # temp

                    msg = "SpawnSpot: randomseed [%d] modified_value [%s] x[%f] from [%d] \
simul_tick [%d] in zone_[%d] at %f %f %f %f" % \
                        (p_seed, p_purpose, p_coef, p_tick,
                            simul_tick, zone_idx, special_target_1[0], special_target_1[1], special_target_2[0], special_target_2[1])

                    writeFile(ATTACK_SPOT, msg)

                    OBSTACLES = move_obstacles(
                        OBSTACLES, params, special_target_1, special_target_2)
            else:
                if simul_tick == params.spawntime:
                    # SPOT intermediate/ 60 or 80 tick
                    # special_target = np.array([-2.5, -0.2])

                    # special_target_1 = np.array(
                    #     [-1.0, -2.5])  # SPOT far / 120 tick

                    temp_special_target_2 = np.loadtxt(open(SEEDPOOL_DIR + "/candidate_spawning_pool.csv", "rb"),
                                                       delimiter=" ", skiprows=1)
                    fuzz_input_special_target_2 = temp_special_target_2[-1]
                    print("0. attacker is spawned at: " +
                          str(fuzz_input_special_target_2[0])+", "+str(fuzz_input_special_target_2[1]))
                    # special_target_1 = np.array(
                    #     [0.0, 2.5])  # SPOT close / 20 tick
                    # special_target_2 = np.array(
                    #     [-0.5, 2.5])  # SPOT close / 20 tickz

                    # special_target_2 = np.array(
                    #     [-0.5, 0.7])  # SPOT motivate (d) / 20 tick
                    # special_target_2 = np.array(
                    # [-0.5, 1.7])  # SPOT motivate (b) / 20 tick
                    # special_target_2 = np.array(
                    #     [-0.5, 1.3])  # SPOT motivate (c) / 20 tick

                    # special_target_2 = np.array(
                    #     [-50.5, 2.5])  # SPOT close / 20 tick
                    OBSTACLES = move_obstacles(
                        OBSTACLES, params, special_target_1, fuzz_input_special_target_2)

                    OBSTACLES[-1] = np.array([[-0.1, 1.4],
                                              [0.0, 1.4], [0.0, 1.5], [-0.1, 1.5]])

        # global set point is set here
        rbt.sp_global = traj_global[sp_ind, :]

        # Note this function always on.

        if param_setting != 'randomtest':
            checker_dist_obs(robots, simul_tick, params, OBSTACLES)

        # Note this function always on.

        # TODO: check this function: 40ms to finish this method
        # TODO: target_obs should be from arg
        # with 3rd OBS for now
        target_obs = '3rd'

        if params.contribution is True:
            # TODO: this is needed in the past for replay feature. Re define this feature.
            '''
            if target_obs is '1st':
                print("dbg : "+str(robots[0].distance_with_obs_ltr[-1]))
                dist_to_compare = robots[0].distance_with_obs_ltr[-1]

            elif target_obs is '2nd':
                dist_to_compare = robots[0].distance_with_obs_btt[-1]

            elif target_obs is '3rd':
                dist_to_compare = robots[0].distance_with_obs_dia[-1]

            if dist_to_compare <= CSCORE_WRITE_THRESHOLD:  # CSCORE_WRITE_THRESHOLD = 0.8
                
                print(
                "[log] now in the sensing area, contribution_leader starts to be calculated")

                contribution_leader(robots, simul_tick,
                                    params, OBSTACLES, target_obs)
            '''
            contribution_leader(robots, simul_tick,
                                params, OBSTACLES, target_obs)

        # correct leader's pose with local planner
        rbt.new_local_planner(OBSTACLES, params)

        # Below part should be placed after rbt is updated: rbt.new_local_planner(OBSTACLES, params)
        if params.contribution is True:

            # TODO: this is needed in the past for replay feature. Re define this feature.
            '''
            if target_obs is '1st':
                print("dbg : "+str(robots[p_target].distance_with_obs_ltr[-1]))
                dist_to_compare = robots[p_target].distance_with_obs_ltr[-1]
            elif target_obs is '2nd':
                dist_to_compare = robots[p_target].distance_with_obs_btt[-1]
            elif target_obs is '3rd':
                dist_to_compare = robots[p_target].distance_with_obs_dia[-1]

            if dist_to_compare <= CSCORE_WRITE_THRESHOLD: # CSCORE_WRITE_THRESHOLD = 0.8
            print(
                "[log] now in the sensing area, contribution score starts to be calculated")
            print("[dbg] out function self_sp: "+str(robots[p_target].sp) +
                  " | self_sp_global_prime: "+str(robots[p_target].sp_global))
            '''
            contribution_others(robots, rbt, 'for_followers', arg_target_index=1, simulation_tick=simul_tick,
                                followers_sp=followers_sp, params=params, OBSTACLES=OBSTACLES, target_obs=target_obs)
            contribution_others(robots, rbt, 'for_followers', arg_target_index=2, simulation_tick=simul_tick,
                                followers_sp=followers_sp, params=params, OBSTACLES=OBSTACLES, target_obs=target_obs)
            contribution_others(robots, rbt, 'for_followers', arg_target_index=3, simulation_tick=simul_tick,
                                followers_sp=followers_sp, params=params, OBSTACLES=OBSTACLES, target_obs=target_obs)

            temp_center_x = 0.25 * \
                (OBSTACLES[-2][0][0] + OBSTACLES[-2][1][0] +
                 OBSTACLES[-2][2][0] + OBSTACLES[-2][3][0])
            temp_center_y = 0.25 * \
                (OBSTACLES[-2][0][1] + OBSTACLES[-2][1][1] +
                 OBSTACLES[-2][2][1] + OBSTACLES[-2][3][1])
            # writeFile(CONTR_PN, str(simul_tick)+" "+str(robots[2].sp[0])+" "+str(robots[2].sp[1])+" "+str(temp_center_x) + " "+str(temp_center_y))

        if "DEBUG" in os.environ:
            print(" - check point1: %f" % (time.time() - start_time))

        '''
        1) adding following robots in the swarm
        2) replay robot2 ~ 4.sp_global
        3) formation poses from global planner
        
        comment below code under if statement.
        when replay, robots should be calculated by local planner to reflect the changes.
        however, initial value should be set before main simulation loop
        '''

        followers_sp_global = formation(
            params.num_robots, rbt.sp_global,
            v=normalize(rbt.sp_global - rbt.sp),
            l=params.interrobots_dist)

        for i in range(len(followers_sp_global)):
            robots[i + 1].sp_global = followers_sp_global[i]

        '''
        [replay] robot2~4.sp
        comment below code under if statement.
        when replay, robots should be calculated by local planner to reflect the changes.
        however, initial value should be set before main simulation loop
        '''

        # TODO: check the performance:
        #       one loop spends 10ms (and there are 3 loops)

        # formation poses correction with
        for p in range(len(followers_sp)):
            # robots repel from each other inside the formation
            # all poses except the robot[p]
            robots_obstacles_sp = [x for i, x in enumerate(
                followers_sp + [rbt.sp]) if i != p]
            # each drone is defined as a small cube for
            # inter-robots collision avoidance
            robots_obstacles = poses2polygons(robots_obstacles_sp)

            # combine exisiting obstacles on the map
            # with other robots[for each i: i!=p] in formation
            obstacles1 = np.array(OBSTACLES + robots_obstacles)
            # follower robot's position correction with local planner

            robots[p + 1].new_local_planner(obstacles1, params)
            followers_sp[p] = robots[p + 1].sp

        if "DEBUG" in os.environ:
            print(" - check point2: %f" % (time.time() - start_time))

        # centroid pose:
        centroid = 0
        for robot in robots:
            centroid += robot.sp / len(robots)

        metrics.centroid_path = np.vstack([metrics.centroid_path, centroid])

        # dists to robots from the centroid:
        dists = []
        for robot in robots:
            dists.append(norm(centroid - robot.sp))

        # Formation size estimation
        metrics.mean_dists_array.append(np.mean(dists))

        # Formation max Radius #not needed
        metrics.max_dists_array.append(np.max(dists))

        # visualization  # not needed
        if params.visualize:
            plt.cla()
            visualize2D(simul_tick, OBSTACLES, params,
                        robots, robot1, centroid, traj_global)
            plt.draw()
            plt.pause(0.01)

        if check_crash is True:
            has_crash = checker_crash_simple(simul_tick, robot1)
            if has_crash:
                msg = " > Crash"
                writeFile(CRASH_PN, msg)

        # for now this is not used. but let it alive.
        # checker_skip(robot1, simul_tick, centroid, params) ###########

        """
        for all_sp.log for finding out the upper bound in test inputs
        """
        l_sp = copy.deepcopy(rbt.sp)
        f1_sp = copy.deepcopy(robots[1].sp)
        f2_sp = copy.deepcopy(robots[2].sp)
        f3_sp = copy.deepcopy(robots[3].sp)

        obst_1 = modify_obstacle(OBSTACLES, 3)
        obst_2 = modify_obstacle(OBSTACLES, 2)
        obst_3 = modify_obstacle(OBSTACLES, 1)

        l_g_sp = copy.deepcopy(rbt.sp_global)
        f1_g_sp = copy.deepcopy(robots[1].sp_global)
        f2_g_sp = copy.deepcopy(robots[2].sp_global)
        f3_g_sp = copy.deepcopy(robots[3].sp_global)

        coord_record.append(
            [l_sp, f1_sp, f2_sp, f3_sp, obst_1, obst_2, obst_3,
                l_g_sp, f1_g_sp, f2_g_sp, f3_g_sp])

        if params.all_sp_record_for_replay is True:

            if params.already_written_allsp is False:

                for drone_index in range(0, 4):
                    if coord_record[-1][drone_index][0] >= \
                            params.info_trap_boundary_x \
                            and coord_record[-1][drone_index][1] >= \
                            params.info_trap_boundary_y:

                        if drone_index == 0:
                            params.info_trapped_drone = "L"
                        elif drone_index == 1:
                            params.info_trapped_drone = "f1"
                        elif drone_index == 2:
                            params.info_trapped_drone = "f2"
                        elif drone_index == 3:
                            params.info_trapped_drone = "f3"

                if params.mode_randomtesting is True:
                    '''
                    when random testing, it starts right before the obstacle,
                    it has no history.
                    '''
                    for writing_index in range(1, 2):
                        writeFile(ALLSP_PN, ret_log(
                            coord_record, writing_index, params, args, simul_tick))

                    # TODO: in random testing, no need to proceed further after crash checked.
                    # print("[log] BREAK because crash is recorded and no need to go further.")
                    # break

                else:

                    for writing_index in range(1, 5):
                        writeFile(ALLSP_PN, ret_log(
                            coord_record, writing_index, params, args, simul_tick)
                        )

                    params.already_written_allsp = True

            if params.mode_stop_before_obs is True:
                print(
                    "[log] break because params.mode_record_trajectory_replay is False")
                # This is deprecated. In real, not used so far.
                break
        
        

        if param_setting is 'record':
            if params.crash is True:
                '''TODO: CJ debug'''
                # print("[log] crash detected: l:"+str(rbt.sp)+" f1:"+str(robots[1].sp) +
                #       " f2:"+str(robots[2].sp)+" f3:"+str(robots[3].sp))
                writeFile(CRASH_FOR_RT_PN, ret_crash_log(
                    params, args, simul_tick, randometest_order)
                )
                res_suc_fail = "Failed"
                writeFile(RES, res_suc_fail)
                params.crash = False



        if params.crash_check_for_random_testing is True:

            # we give 4 tick for stabilization

            if simul_tick >= p_tick + 4:
                checker_dist_obs(robots, simul_tick, params, OBSTACLES)

            if params.crash is True:
                '''TODO: CJ debug'''
                # print("[log] crash detected: l:"+str(rbt.sp)+" f1:"+str(robots[1].sp) +
                #       " f2:"+str(robots[2].sp)+" f3:"+str(robots[3].sp))
                writeFile(CRASH_FOR_RT_PN, ret_crash_log(
                    params, args, simul_tick, randometest_order)
                )
                # params.crash = False
                params.crash_check_for_random_testing = False
                if params.mode_record_trajectory_replay is False:
                    break

        if param_setting is 'randomtest' and simul_tick > 100:
            min_x_robots = min(
                rbt.sp[0], robots[1].sp[0], robots[2].sp[0], robots[3].sp[0])
            if OBSTACLES[-2][0][0] <= min_x_robots - 0.1:
                # print("[dbg] o:" +str(OBSTACLES[-2][0]) +" l:"+str(rbt.sp)+" 1:"+str(robots[1].sp[0])+" 2:"+str(robots[2].sp[0])+" 3:"+str(robots[3].sp[0]))
                print("[log] all difficulties has gone... let's go to the next round")
                break

        """
        For replay
        """
        if params.mode_record_trajectory_replay is True:
            # print("[log] trajectories are recorded.")
            com_robot_1_sp_global.append(copy.deepcopy(rbt.sp_global))
            com_robot_2_sp_global.append(copy.deepcopy(robots[1].sp_global))
            com_robot_3_sp_global.append(copy.deepcopy(robots[2].sp_global))
            com_robot_4_sp_global.append(copy.deepcopy(robots[3].sp_global))
            com_robot_1_sp.append(copy.deepcopy(rbt.sp))
            com_robot_2_sp.append(copy.deepcopy(robots[1].sp))
            com_robot_3_sp.append(copy.deepcopy(robots[2].sp))
            com_robot_4_sp.append(copy.deepcopy(robots[3].sp))
            com_obstacles.append(copy.deepcopy(OBSTACLES))

        # loop should go on.
        simul_tick += 1

        """
        This is natural stop condition for the loop = simulation
        I added go_or_nogo and several restrictions in the if predicate.
        """
        if param_setting is not 'randomtest':
            fliped_coin.append(sp_ind)

        new_condition = 1.0 * 1.5
        condition_1 = norm(rbt.sp_global - centroid) < 2 * params.max_sp_dist
        condition_2 = norm(rbt.sp - rbt.sp_global) < new_condition
        # new_condition_3 = norm(robots[1].sp - robots[1].sp_global) < new_condition
        # new_condition_4 = norm(robots[2].sp - robots[2].sp_global) < new_condition
        # new_condition_5 = norm(robots[3].sp - robots[3].sp_global) < new_condition

        new_condition_3 = norm(
            rbt.sp - robots[1].sp) <= new_condition  # 2 * 0.8
        new_condition_4 = norm(
            rbt.sp - robots[2].sp) <= new_condition  # 2 * 0.8
        new_condition_5 = norm(
            rbt.sp - robots[3].sp) <= new_condition  # 2 * 1.0

        special_condition_1 = False
        if param_setting is not 'randomtest':
            if simul_tick >= 5:
                special_condition_1 = fliped_coin[-3] == fliped_coin[-2] and fliped_coin[-2] == fliped_coin[-1]

            # which means that if there's no update for 3 ticks, just go ahead.
            # special_condition_1 = com_robot_1_sp[-3][0] == com_robot_1_sp[-1][0] and com_robot_1_sp[-3][1] == com_robot_1_sp[-1][1]

        # if condition_1 and condition_2 and new_condition_3 and new_condition_4 and new_condition_5:
        if condition_1:
            go_or_nogo = True
        else:
            print("[log] loop condition is too strict!")
            # print("[log] condition is ["+str(condition_1)+"]["+str(condition_2)+"]["+str(condition_3)+"]["+str(condition_4)+"]["+str(condition_5)+"]")
            # print("[log] detailed 3 is ["+str(robots[3].sp)+"]["+str(robots[3].sp_global)+"]")

            go_or_nogo = False
            if special_condition_1:
                print("[log] go anyway")
                # go_or_nogo = True

        if sp_ind < traj_global.shape[0] - 1 and\
                go_or_nogo:
            sp_ind += 1

        """
        This is end condition by setting time limit is 500 ticks.
        added by Dr. Jung. JH.
        """
        if simul_tick >= MAX_TICK:
            elapsed_time = time.time() - start_time
            msg = "Mission failed: randomseed [%d] modified_value [%s] x[%f] from [%d] \
simul_tick [%d] with [%f] in zone_[%d] speedX [%f] obsSize [%f]" % \
                  (p_seed, p_purpose, p_coef, p_tick,
                   simul_tick, elapsed_time, zone_idx, temp_coef_atk_vel, params.obst_size_bit)

            writeFile(ATTACK_RES, msg)
            
            res_suc_fail = "Failed"
            writeFile(RES, res_suc_fail)

            msg = " > Cannot reach goal"
            writeFile(CRASH_PN, str(p_seed) + msg)
            break

        if "DEBUG" in os.environ:
            # pid = psutil.Process(os.getpid())
            # mem_usage = pid.memory_info().rss
            # print("Used memory (byte): %d" % mem_usage)

            tick_counter += 1
            total_time += (time.time() - start_time)
            print(
                "Elapsed time for this tick(ms): %f,%f" %
                (time.time() - start_time, total_time))
            print("Elapsed ticks: %d" % tick_counter)

    # xy_start = rbt.sp - [fall_back, 0]

    """
    For replay
    """
    if params.mode_record_trajectory_replay is True:
        folderName = "%s_x%.1f_rollback_%d/%d" % (
            args[3], args[2], args[5], args[1])

        mkdirs(REPLAY_DIR + "/" + folderName)
        np.save(
            REPLAY_DIR + "/" + folderName + "/robot_1_sp_global_"
            + str(params.rand_seed) + ".npy", com_robot_1_sp_global)
        np.save(
            REPLAY_DIR + "/" + folderName + "/robot_2_sp_global_"
            + str(params.rand_seed) + ".npy", com_robot_2_sp_global)
        np.save(
            REPLAY_DIR + "/" + folderName + "/robot_3_sp_global_"
            + str(params.rand_seed) + ".npy", com_robot_3_sp_global)
        np.save(
            REPLAY_DIR + "/" + folderName + "/robot_4_sp_global_"
            + str(params.rand_seed) + ".npy", com_robot_4_sp_global)

        np.save(
            REPLAY_DIR + "/" + folderName + "/robot_1_sp_"
            + str(params.rand_seed) + ".npy", com_robot_1_sp)
        np.save(
            REPLAY_DIR + "/" + folderName + "/robot_2_sp_"
            + str(params.rand_seed) + ".npy", com_robot_2_sp)
        np.save(
            REPLAY_DIR + "/" + folderName + "/robot_3_sp_"
            + str(params.rand_seed) + ".npy", com_robot_3_sp)
        np.save(
            REPLAY_DIR + "/" + folderName + "/robot_4_sp_"
            + str(params.rand_seed) + ".npy", com_robot_4_sp)

        np.save(
            REPLAY_DIR + "/" + folderName + "/obstacles_"
            + str(params.rand_seed) + ".npy", com_obstacles)

    '''
    for contribution score
    '''

    if params.record_contribution_score is True:
        print('[log] contribution score is being writing')
        write_influence(robots, arg_target_index=1, params=params)
        write_influence(robots, arg_target_index=2, params=params)
        write_influence(robots, arg_target_index=3, params=params)

        temp_dist_for_fuzz = 0

        start_seed_pool_idx = 0
        end_seed_pool_idx = int(load_size_pool(SEEDPOOL_DIR + "/poolsize.csv"))

        print("=== Summary ===")
        print("1. Current seed pool size: "+str(end_seed_pool_idx))

        min_dcc = 100
        min_dcc_seed = 0
        
        if feedback_type == 'dcc':
            for seed_pool_idx in range(start_seed_pool_idx, end_seed_pool_idx):

                ref_f1 = np.loadtxt(open(SEEDPOOL_DIR + "/"+str(seed_pool_idx)+"/ref_f1.csv", "rb"),
                                    delimiter=" ", skiprows=1)
                ref_f2 = np.loadtxt(open(SEEDPOOL_DIR + "/"+str(seed_pool_idx)+"/ref_f2.csv", "rb"),
                                    delimiter=" ", skiprows=1)
                ref_f3 = np.loadtxt(open(SEEDPOOL_DIR + "/"+str(seed_pool_idx)+"/ref_f3.csv", "rb"),
                                    delimiter=" ", skiprows=1)

                '''
                comparison instance 1
                '''
                # TODO: REMOVE
                distance_mode = DISTANCE_MODE #'normal'
                temp_temp_dist_for_fuzz = 1.0/3.0 * (distance_between_dcc(ref_f1, robots[1].dcc, distance_mode) + 
                distance_between_dcc(ref_f2, robots[2].dcc, distance_mode) + 
                distance_between_dcc(ref_f3, robots[3].dcc, distance_mode))

                if temp_temp_dist_for_fuzz <= min_dcc:
                    min_dcc = temp_temp_dist_for_fuzz
                    min_dcc_seed = seed_pool_idx

                print("1-1. Reading files from: " +
                    SEEDPOOL_DIR + "/"+str(seed_pool_idx) + ", and dist: "+str(temp_temp_dist_for_fuzz))
        

        file1 = open(OUTPUT_DIR + "/result.log", "r+")
        last_mat = file1.readlines()

        if feedback_type == 'dcc': # option 1: using dcc
            branch_option = min_dcc <= FUZZ_THRESHOLD
        elif feedback_type == 'random': # option 1: using naive feedback
            branch_option = last_mat[-1] != 'Failed\n' # mission succeeds: meaningless

        regen_condition = True
        # regen_boundary = 20.0

        contact_condition = True
        msg = "distance_with_obs_dia: 0[%f], 4[%f]" % (robots[0].distance_with_obs_dia[-1], robots[3].distance_with_obs_dia[-1])
        logging.debug(msg)
        if robots[0].distance_with_obs_dia[-1] <= 1.5 or robots[3].distance_with_obs_dia[-1] <= 1.5 :
            contact_condition = False # Too far
        else:
            contact_condition = True  # Too far

        if branch_option or contact_condition:
            '''
            branch option is true when previous mission is succeeded
            -> no meaningful result here
            which means that it should perturb more
            
            configured by user
            which means that it's not new!
            break immediatedly and purturb more
            so ignore this input
            purturb more
            '''

            temp_pop_up_from_spawning_pool = np.loadtxt(open(SEEDPOOL_DIR + "/spawning_pool.csv", "rb"),
                                                        delimiter=" ", skiprows=1)

            pop_up_from_spawning_pool = temp_pop_up_from_spawning_pool[-1]

            while regen_condition:

                perturbed_coord = make_perturbation(
                    current_spawning_point=pop_up_from_spawning_pool, mode='big')
                
                if norm(perturbed_coord) <= REGEN_BOUNDARY:
                    break
                logging.debug("Perturbed_coord is out of boundary, redo this.")
                
            # TODO: revise this
            update_candidate_spawning_pool(
                SEEDPOOL_DIR + "/candidate_spawning_pool.csv", str(perturbed_coord[0]) + " " + str(perturbed_coord[1]))
            # TODO: revise this
            update_candidate_spawning_pool(
                SEEDPOOL_DIR + "/record_candidate_spawning_pool.csv", str(fuzz_input_special_target_2[0]) + " " + str(fuzz_input_special_target_2[1]) + " with seed: " + str(min_dcc_seed) + " with dcc: " + str(min_dcc))

            print("3. Meaningless run. Nothing happened. Perturb More.")
            print("4. Big perturbation is applied: previous ["+str(pop_up_from_spawning_pool[0])+"," +
                  str(pop_up_from_spawning_pool[1])+"] -> new ["+str(
                perturbed_coord[0])+","+str(perturbed_coord[1])+"]")
            print("5. Also, comparison is terminated.")
            
            
        else:
            '''
            which means there's no single case that is the same trace with pool
            put this input into seed pool (save)
            '''
            put_into_seed_pool(robots, arg_target_index=0,
                               params=params, seed_pool_idx=end_seed_pool_idx)
            put_into_seed_pool(robots, arg_target_index=1,
                               params=params, seed_pool_idx=end_seed_pool_idx)
            put_into_seed_pool(robots, arg_target_index=2,
                               params=params, seed_pool_idx=end_seed_pool_idx)
            put_into_seed_pool(robots, arg_target_index=3,
                               params=params, seed_pool_idx=end_seed_pool_idx)

            update_size_pool(SEEDPOOL_DIR + "/poolsize.csv",
                             end_seed_pool_idx + 1)


            print("0. attacker is spawned at: " +
                  str(fuzz_input_special_target_2[0])+", "+str(fuzz_input_special_target_2[1]))

            update_spawning_pool(
                SEEDPOOL_DIR + "/spawning_pool.csv", str(fuzz_input_special_target_2[0]) + " " + str(fuzz_input_special_target_2[1]))

            update_spawning_pool(
                SEEDPOOL_DIR + "/record_spawning_pool.csv", str(fuzz_input_special_target_2[0]) + " " + str(fuzz_input_special_target_2[1]) + " " + str(params.rand_seed))

            temp_pop_up_from_spawning_pool = np.loadtxt(open(SEEDPOOL_DIR + "/spawning_pool.csv", "rb"),
                                                        delimiter=" ", skiprows=1)

            pop_up_from_spawning_pool = temp_pop_up_from_spawning_pool[-1]

            while regen_condition:

                perturbed_coord = make_perturbation(
                    current_spawning_point=pop_up_from_spawning_pool, mode='small')
                
                if norm(perturbed_coord) <= REGEN_BOUNDARY:
                    break
                logging.debug("Perturbed_coord is out of boundary, redo this.")

            print("0. attacker is spawned at: " +
                  str(fuzz_input_special_target_2[0])+", "+str(fuzz_input_special_target_2[1]))

            update_candidate_spawning_pool(
                SEEDPOOL_DIR + "/candidate_spawning_pool.csv", str(perturbed_coord[0]) + " " + str(perturbed_coord[1]))

            print("3. New input is found. Inserted into pool. Then, pool size becomes: " +
                  str(end_seed_pool_idx + 1))
            print("4. Small perturbation is applied: current ["+str(fuzz_input_special_target_2[0])+"," +
                  str(fuzz_input_special_target_2[1])+"] -> new ["+str(
                perturbed_coord[0])+","+str(perturbed_coord[1])+"]")
        
        msg = "feedback_type %s target %i spawned %f %f branch_option(isMissionSuc) %s contact_condition(isFar) %s" \
            % (feedback_type, params.attack_target, fuzz_input_special_target_2[0], fuzz_input_special_target_2[1], branch_option, contact_condition)
        writeFile(SIM_RESULT, msg)

    if params.visualize or "DEBUG" in os.environ:
        plt.close('all')


def AdSwarm(feedback_type):

    referfilename = 'randomtesting/pure_recog_time.csv'  # FIXED
    referFile = np.array(pd.read_csv(referfilename, sep=','))

    index_seed = 0
    index_tick = 1

    # TODO: set this right
    starting_point = XY_START #np.array([1.2, 1.25])  # [-1.2, 1.25] when 1.0

    des1 = copy.deepcopy(starting_point)
    des2, des3, des4 = formation(
        4, leader_des=des1, v=np.array([-1, 0]),
        l=0.5)

    xy_start.append(starting_point)
    drone_01.append(des1)
    drone_02.append(des2)
    drone_03.append(des3)
    drone_04.append(des4)

    for seed_idx in range(1, NUM_EXPERIMENTS):  # 3001

        # p_target_set = [1,2,3] # fixed in this mode 1 means f1, 2 means f2, 3 means f3
        p_target = 1 # TODO: remove
        p_seed = seed_idx
        p_coef = None # TODO: remove
        p_purpose = None  # TODO: remove
        p_idx = None 
        p_tick = None 

        '''robots_starting_point'''

        variation_p_coef = [1.0]  # [1.0, 1.6, 1.7, 1.8, 1.9, 2.0]#[1.5] #
        variation_p_idx = [0]
        variation_p_purpose = ['i']

        ''' Case 01: empty <- standard '''
        obstacle_set_1 = [COMPLEX_OBS_T_1]

        obstacle_set = obstacle_set_1

        for x in variation_p_coef:
            for y in variation_p_idx:
                for z in variation_p_purpose:
                    for obstacle_type in obstacle_set:
                        p_coef = x
                        p_idx = y
                        if p_idx == 0:
                            p_tick = 1
                        else:
                            p_tick = referFile[index_row][index_tick] - p_idx
                        p_purpose = z
                        args = [p_target, p_seed, p_coef,
                                p_purpose, p_tick, p_idx]
                        logging.debug("##################################################")
                        logging.debug(str(seed_idx)+"th randometesting.................. ")
                        logging.debug(
                            "[Exp_005 adswarm with lv 1")
                        logging.debug("##################################################")
                        # 1st trial
                        ts = time.gmtime()
                        msg = time.strftime("%Y-%m-%d %H:%M:%S", ts)
                        writeFile(TIMESTAMP, msg)

                        fuzz_one(args, obstacle_type, feedback_type, param_setting='record')

arg_01 = 0
metrics = Metrics()

if __name__ == '__main__':
    signal.signal(
        signal.SIGINT, exit_gracefully(signal.getsignal(signal.SIGINT)))

    '''make directory for the output'''
    mkdirs(OUTPUT_DIR)
    mkdirs(SEEDPOOL_DIR)

    parser = argparse.ArgumentParser()
    subparser = parser.add_subparsers(title='sub-parsers')
    tester = subparser.add_parser(
        'adswarm', help='Tester', add_help=False
    )
    tester.add_argument(
        "-k", "--kind", dest="kind", type=str,
        default=None, help="Normal test or replay", required=True
    )
    tester.add_argument(
        "-n", "--num_exp", dest="number_exp", type=str,
        default=None, help="Dry-run all cases", required=False
    )
    tester.set_defaults(action='adswarm')
    args = parser.parse_args()

    if args.action == "adswarm":
        kind = args.kind
        num_exp = args.number_exp # TODO
        
        if kind == "normal":
            globals()[TESTFUNC]()

        elif kind == "dcc": # TODO: Feedback
            # AdSwarm('dcc') # TODO: Feedback
            AdSwarm("dcc")

        elif kind == "random": # TODO: Feedback
            # AdSwarm('random')
            AdSwarm("random")

        elif kind == "debug":
            # TODO
            AdSwarm()

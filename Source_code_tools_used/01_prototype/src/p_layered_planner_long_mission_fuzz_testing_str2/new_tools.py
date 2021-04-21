#!/usr/bin/env python
import os
import time
import math
import copy
import numpy as np
import pandas as pd

from conf import *
from common import *
from rrt import *
from tools import *
from obstacle import *
from potential_fields import *

np.set_printoptions(threshold=np.inf, linewidth=np.inf)

init_fonts(small=12, medium=16, big=26)

if "TESTCASE" in os.environ:
    xy_start = np.array([-2.2, 2.2])
    xy_goal = np.array([2.2, -2.2])
else:
    xy_start = []  # np.array([-2.0, 1.25])
    # starting_point = np.array([1.2, 1.25])
    # xy_goal = np.array([2.0, -1.25])
    xy_goal = np.array([-2.2, 1.25])

# def update_xy_start(new_xy_start):
#     xy_start = new_xy_start


drone_01 = []
drone_02 = []
drone_03 = []
drone_04 = []
drone_05 = []
drone_06 = []
drone_07 = []
drone_08 = []

num_robots = 4

"""
Robot Class
"""


class Robot:
    def __init__(self, id):
        self.id = id
        self.sp = np.array([0, 0])
        self.sp_global = np.array([0, 0])
        self.route = np.array([self.sp])
        self.vel_array = []

        # attractive APF function
        self.U_a = 0

        # repulsive APF function
        self.U_r = 0

        # total APF function
        self.U = 0
        self.d2 = 0
        self.leader = False

        # created for log
        self.gx = []
        self.gy = []
        self.ax = []
        self.ay = []
        self.des = []

        """
        Normal tracking
        """

        self.distance_with_1stD = []
        self.distance_with_2ndD = []
        self.distance_with_3rdD = []
        self.distance_with_obs_ltr = []
        self.distance_with_obs_dia = []
        self.distance_with_obs_btt = []
        self.distance_with_obs_wall = []

        self.influence_avg = []
        self.influence_max = []
        self.influence_min = []
        self.dcc = []

        self.relative_score_with_obs_dia = []

    def new_local_planner(self, obs, params):
        """
        This function computes the next_point
        given current location (self.sp) and potential filed function, f.
        It also computes mean velocity, V, of the gradient map in current point.
        """

        d0_m_coef = 1.0
        obstacles_grid = grid_map(obs)
        # refer: influence_radius=1, attractive_coef=1./700, repulsive_coef=200
        self.U, self.U_a, self.U_r, self.d2, self.U_r_d0 = combined_potential(
            obstacles_grid, self.sp_global, d0_m_coef, params.influence_radius, params.attractive_coef, params.repulsive_coef)

        [gy, gx] = np.gradient(-self.U)
        iy, ix = np.array(meters2grid(self.sp), dtype=int)

        w = params.w_bound  # smoothing window size for gradient-velocity

        '''
        Below code (if statement) is for additional tests
        when w/2 is 8, it's ok, but over 9, it becomes 0
        '''
        temp_ix_add = ix+int(w/2)
        temp_iy_add = iy+int(w/2)

        if ix-int(w/2) < 0:
            temp_ix = 0
            if ix+int(w/2) == 0:
                temp_ix_add = 1
        else:
            temp_ix = ix-int(w/2)

        if iy-int(w/2) < 0:
            temp_iy = 0
            if iy+int(w/2) == 0:
                temp_iy_add = 1
        else:
            temp_iy = iy-int(w/2)

        # print(str(ix+int(w/2)) + "|" + str(iy+int(w/2)))
        # print(str(ix-int(w/2)) + "|" + str(iy-int(w/2)))
        # print(str(ix))
        ax = np.mean(gx[temp_ix: temp_ix_add, temp_iy: temp_iy_add])
        ay = np.mean(gy[temp_ix: temp_ix_add, temp_iy: temp_iy_add])
        # print("ax: "+str(ax))
        self.V = params.drone_vel * np.array([ax, ay])
        self.vel_array.append(norm(self.V))
        dt = 0.01 * params.drone_vel / \
            norm([ax, ay]) if norm([ax, ay]) != 0 else 0.01
        self.sp += dt*np.array([ax, ay])
        self.route = np.vstack([self.route, self.sp])


def write_index_contribution_others():

    # to avoid confusing, remain below comments

    writeFile(CONTR_PN, "drone_no " +
              "t " +

              # simple statistics
              # "sum_contri_s_obst " + \
              # "mul_contri_s_obst_to_tick " + \
              # "sum_mul_contri_s_obst_to_tick " + \
              # "mean_skewness " + \
              # "mode_skewness " + \
              # "pos_nega " + \
              # "blank " + \

              "delta_des " + \
              "delta_l " + \
              "delta_f2 " + \
              "delta_f3 " + \
              "delta_obs[-1] " + \
              "delta_obs[-2] " + \
              "delta_obs[-3] " + \
              "delta_wall " + \

              "cont_s_des " + \
              "cont_s_l " + \
              "cont_s_f2 " + \
              "cont_s_f3 " + \
              "cont_s_obs[-1] " + \
              "cont_s_obs[-2] " + \
              "cont_s_obs[-3] " + \
              "cont_s_wall " + \

              # special order: dist_f1_obs[-2]
              "dist_d_obs_ltr " + \
              "dist_d_obs_dia " + \
              "dist_d_obs_btt " + \
              # relative_score_with_obs_dia
              "relative_s_obs_dia " + \

              "dist_first_saw " + \
              "dist_biggest_infl " + \
              "dist_closest " + \
              "accu_infl " + \

              "max_relative_s " + \

              "extra_dist_with_1st " + \
              "extra_dist_with_2nd " + \
              "extra_dist_with_3rd "  # + \

              # "extra_cont_s_r "# + \
              )


def angle(u, v):
    mu = math.sqrt(u[0]**2 + u[1]**2)
    mv = math.sqrt(v[0]**2 + v[1]**2)
    cos_theta = np.dot(u, v) / (mu*mv)
    theta = math.acos(cos_theta)
    return theta


# TODO: check why this function takes 10ms
def m_original_new_local_planner(self_sp, self_sp_global, obstacles, params):

    obstacles_grid = grid_map(obstacles)
    temp_U, _, _ = original_combined_potential(
        obstacles_grid, self_sp_global, params.influence_radius,
        params.attractive_coef, params.repulsive_coef)
    [gy, gx] = np.gradient(-temp_U)

    iy, ix = np.array(meters2grid(self_sp), dtype=int)
    w = params.w_bound
    if ix-int(w/2) < 0:
        temp_ix = 0
    else:
        temp_ix = ix-int(w/2)

    if iy-int(w/2) < 0:
        temp_iy = 0
    else:
        temp_iy = iy-int(w/2)

    ax = np.mean(gx[temp_ix: ix+int(w/2), temp_iy: iy+int(w/2)])
    ay = np.mean(gy[temp_ix: ix+int(w/2), temp_iy: iy+int(w/2)])

    dt = 0.01 * params.drone_vel /\
        norm([ax, ay]) if norm([ax, ay]) != 0 else 0.01

    temp_sp = self_sp + dt * np.array([ax, ay])
    return temp_sp


def contribution_leader(robots, simulation_tick, params, OBSTACLES, target_obs):

    if "DEBUG" in os.environ:
        start_time = time.time()

    delta_distance = 9999.0  # in set_point
    temp_sp_leader = []

    self_sp = robots[0].sp
    self_sp_global_prime = robots[0].sp_global

    # attractive + repulsive
    # TODO: this m_original_new_local_planner is slow (10ms)
    after_normal_cal_sp = m_original_new_local_planner(
        self_sp, self_sp_global_prime, OBSTACLES, params)

    '''TODO: CJ debug'''
    # print("[dbg] leader after_normal_cal_sp: "+str(after_normal_cal_sp))

    temp_sp_leader.append(m_original_new_local_planner(
        self_sp, self_sp, OBSTACLES, params))
    '''TODO: CJ debug'''
    # print("[dbg] leader temp_sp_leader: "+str(temp_sp_leader[-1]))

    for obs_idx in range(1, 4):
        obs_onlyprime = copy.deepcopy(OBSTACLES)

        for ext_p_idx in range(0, 4):
            # x-axis
            obs_onlyprime[-obs_idx][ext_p_idx][0] =\
                obs_onlyprime[-obs_idx][ext_p_idx][0] + delta_distance

        temp_sp_leader.append(
            m_original_new_local_planner(
                self_sp, self_sp_global_prime, obs_onlyprime, params))

        '''TODO: CJ debug'''
        # print("[log]self_sp' = " + str(obs_idx) +
        #       " | " + str(temp_sp_leader[-1]))

        for ext_p_idx in range(0, 4):
            # x-axis
            obs_onlyprime[-obs_idx][ext_p_idx][0] = \
                obs_onlyprime[-obs_idx][ext_p_idx][0] - delta_distance

    temp_leader_global_sp = np.linalg.norm(
        after_normal_cal_sp - temp_sp_leader[0])  # new_added

    temp_leader_obs_btt = np.linalg.norm(
        after_normal_cal_sp - temp_sp_leader[1])  # new_added
    temp_leader_obs_dia = np.linalg.norm(
        after_normal_cal_sp - temp_sp_leader[2])  # new_added
    temp_leader_obs_ltr = np.linalg.norm(
        after_normal_cal_sp - temp_sp_leader[3])  # new_added

    robots[0].influence_max.append(
        [temp_leader_global_sp, temp_leader_obs_btt, temp_leader_obs_dia, temp_leader_obs_ltr])

    '''TODO: CJ debug'''
    # print("[log]robots[0].influence_max[-1][0]: " +
    #       str(robots[0].influence_max[-1][0]))
    # print("[log]robots[0].influence_max[-1][1]: " +
    #       str(robots[0].influence_max[-1][1]))
    # print("[log]robots[0].influence_max[-1][2]: " +
    #       str(robots[0].influence_max[-1][2]))
    # print("[log]robots[0].influence_max[-1][3]: " +
    #       str(robots[0].influence_max[-1][3]))

    if "DEBUG" in os.environ:
        print(" - CONTR: %f" % (time.time() - start_time))

    if target_obs is '1st':
        if temp_leader_obs_ltr != 0.00:
            # print("[log] leader recog. obs, cont_s: "+str(temp_leader_obs_ltr))
            params.all_sp_record_for_replay = True
            params.crash_check_for_random_testing = True

    elif target_obs is '2nd':
        if temp_leader_obs_btt != 0.00:
            # print("[log] leader recog. obs, cont_s: "+str(temp_leader_obs_btt))
            params.all_sp_record_for_replay = True
            params.crash_check_for_random_testing = True

    elif target_obs is '3rd':
        if temp_leader_obs_dia != 0.00:
            # print("[log] leader recog. obs, cont_s: "+str(temp_leader_obs_dia))
            params.all_sp_record_for_replay = True
            params.crash_check_for_random_testing = True


# TODO: check why this function takes 40ms
def contribution_others(robots, robot1, leader_follower, arg_target_index, simulation_tick, followers_sp, params, OBSTACLES, target_obs):

    if "DEBUG" in os.environ:
        start_time = time.time()

    delta_distance = 9999.0  # in set_point
    temp_sp = []
    temp_sp_leader = []

    if leader_follower == 'for_leader':
        '''
        This is for when the main agent is leader

        So far, this is deprecated.
        But later it will be used.
        '''

        followers_sp_prime = followers_sp
        self_sp = robots[0].sp
        self_sp_global_prime = robots[0].sp_global

        # attractive + repulsive
        after_normal_cal_sp = m_original_new_local_planner(
            self_sp, self_sp_global_prime, OBSTACLES, params)

        if "DEBUG" in os.environ:
            print(" - NORM1: %f" % (time.time() - start_time))

        for obs_idx in range(1, 4):
            # we only consider when BIG value is added in x-axis

            obstacles_prime = []
            obs_onlyprime = copy.deepcopy(OBSTACLES)

            for ext_p_idx in range(0, 4):
                # x-axis
                obs_onlyprime[-obs_idx][ext_p_idx][0] = obs_onlyprime[-obs_idx][ext_p_idx][0] + delta_distance

            temp_sp_leader.append(m_original_new_local_planner(
                self_sp, self_sp_global_prime, obs_onlyprime, params))

        # TODO: check below block and remove it
        temp_leader_obs_btt = np.linalg.norm(
            after_normal_cal_sp - temp_sp_leader[0])  # new_added
        temp_leader_obs_dia = np.linalg.norm(
            after_normal_cal_sp - temp_sp_leader[1])  # new_added
        temp_leader_obs_ltr = np.linalg.norm(
            after_normal_cal_sp - temp_sp_leader[2])  # new_added
        robots[0].influence_avg.append(
            [temp_leader_obs_btt, temp_leader_obs_dia, temp_leader_obs_ltr])

        if "DEBUG" in os.environ:
            print(" - NORM2: %f" % (time.time() - start_time))

        if temp_leader_obs_dia != 0.00:
            print("leader recog. obs, cont_s: "+str(temp_leader_obs_dia))
            params.all_sp_record_for_replay = True
            params.crash_check_for_random_testing = True

    else:
        '''
        from now
        we consider when the main agent is one of followers
        '''

        target_index = arg_target_index  # params.target_index

        self_sp = robots[target_index].sp

        relative_vector_drone_obs_dia = (robots[target_index].sp - [OBSTACLES[-2][0][0], OBSTACLES[-2][0][1]]) / np.linalg.norm([
            OBSTACLES[-2][0][0], OBSTACLES[-2][0][1]] - robots[target_index].sp)

        direction_obs_dia_vector = np.array(
            [-0.005, 0.005]) * params.drone_vel/2  # constant

        theta_drone_obs_dia = angle(
            relative_vector_drone_obs_dia, direction_obs_dia_vector)
        relative_score_with_obs_dia = (math.pi - theta_drone_obs_dia) / math.pi

        robots[target_index].relative_score_with_obs_dia.append(
            relative_score_with_obs_dia)

        # print("[dbg] self_sp: "+str(self_sp))
        robots_obstacles_sp_normal = [x for i, x in enumerate(
            followers_sp + [robot1.sp]) if i != (target_index - 1)]  # all poses except the robot[p]
        # each drone is defined as a small cube for inter-robots collision avoidance
        robots_obstacles_normal = poses2polygons(robots_obstacles_sp_normal)
        obstacles1_normal = np.array(OBSTACLES + robots_obstacles_normal)
        after_normal_cal_sp = m_original_new_local_planner(
            self_sp, robots[target_index].sp_global, obstacles1_normal, params)  # Here, attractive + repulsive

        # 0, 1, 2, 3 0 means leader.sp, 1,2,3 mean f1,f2,f3's sp
        for variable_index in range(0, 4):

            if variable_index == 0:
                '''
                This part is for when variable_index means leader that is target to figure out the contribution score
                we should consider leader's situation that is diffrent from other drones.

                the first bunch of this part is about leader is playing goal.
                '''

                # As formation
                variable_sp = []

                variable_sp.append(robot1.sp[0] + delta_distance)
                variable_sp.append(robot1.sp[1])  # + 0.01

                followers_sp_prime = followers_sp

                robot1_sp_prime = np.array(variable_sp)

                robots_obstacles_sp_prime = [x for i, x in enumerate(
                    followers_sp_prime + [robot1.sp]) if i != (target_index - 1)]  # SAME ORIGINAL!!!!!!

                # each drone is defined as a small cube for inter-robots collision avoidance
                robots_obstacles_prime = poses2polygons(
                    robots_obstacles_sp_prime)
                # combine exisiting obstacles on the map with other robots[for each i: i!=p] in formation
                obstacles_prime = np.array(OBSTACLES + robots_obstacles_prime)

                followers_sp_global_prime = formation(params.num_robots, robot1.sp_global, v=normalize(
                    robot1.sp_global-robot1_sp_prime), l=params.interrobots_dist)
                self_sp_global_prime = followers_sp_global_prime[target_index-1]

                if delta_distance >= 999:
                    # nowhere to go, so self_sp instead of self_sp_global_prime
                    temp_sp.append(m_original_new_local_planner(
                        self_sp, self_sp, obstacles_prime, params))
                else:
                    temp_sp.append(m_original_new_local_planner(
                        self_sp, self_sp_global_prime, obstacles_prime, params))

                '''
                this is a second bunch of this part
                This is about when leader is playing as an obstacle.

                we only consider add BIG value on x-axis
                '''

                variable_sp = []

                variable_sp.append(robot1.sp[0] + delta_distance)
                variable_sp.append(robot1.sp[1])  # + 0.01

                followers_sp_prime = followers_sp

                robot1_sp_prime = np.array(variable_sp)

                robots_obstacles_sp_prime = [x for i, x in enumerate(
                    followers_sp_prime + [robot1_sp_prime]) if i != (target_index - 1)]  # TODO change robot1.sp

                # each drone is defined as a small cube for inter-robots collision avoidance
                robots_obstacles_prime = poses2polygons(
                    robots_obstacles_sp_prime)
                # combine exisiting obstacles on the map with other robots[for each i: i!=p] in formation
                obstacles_prime = np.array(OBSTACLES + robots_obstacles_prime)

                followers_sp_global_prime = formation(params.num_robots, robot1.sp_global, v=normalize(
                    robot1.sp_global-robot1.sp), l=params.interrobots_dist)  # ORIGINAL SAME!
                self_sp_global_prime = followers_sp_global_prime[target_index-1]

                temp_sp.append(m_original_new_local_planner(
                    self_sp, self_sp_global_prime, obstacles_prime, params))

            elif variable_index == target_index:
                '''
                This is about directing itself.
                just let it be.
                '''
                temp_not_to_empty = 1

            else:

                '''
                This is about another drone as an obstacle

                consider only when ii = 0
                simply apply BIG value in ii = 0

                refer: for ii in range(0, 4): # 0,1,2,3 i means x + x - y + y -
                '''

                variable_sp = []

                variable_sp.append(
                    robots[variable_index].sp[0] + delta_distance)
                variable_sp.append(robots[variable_index].sp[1])  # + 0.01

                followers_sp_prime = copy.deepcopy(followers_sp)
                followers_sp_prime[variable_index-1] = np.array(variable_sp)

                robots_obstacles_sp_prime = [x for i, x in enumerate(
                    followers_sp_prime + [robot1.sp]) if i != (target_index - 1)]  # TODO change robot1.sp
                # each drone is defined as a small cube for inter-robots collision avoidance
                robots_obstacles_prime = poses2polygons(
                    robots_obstacles_sp_prime)
                # combine exisiting obstacles on the map with other robots[for each i: i!=p] in formation
                obstacles_prime = np.array(OBSTACLES + robots_obstacles_prime)

                # this is for when robot1.sp should be a variable
                self_sp_global_prime = robots[target_index].sp_global

                temp_sp.append(m_original_new_local_planner(
                    self_sp, self_sp_global_prime, obstacles_prime, params))
                # self_sp_global_prime has only 4 variations according to robot1.sp

        '''
        This is obst part.
        this is stored in temp[4]~[6]
        '''

        for obs_idx in range(1, 4):

            followers_sp_prime = followers_sp

            self_sp_global_prime = robots[target_index].sp_global

            obstacles_prime = []
            obs_onlyprime = copy.deepcopy(OBSTACLES)

            """
            consider simply add BIG value in ext_p_idx = 0
            so that no need to use for-loop
            """

            for ext_p_idx in range(0, 4):  # 0,1,2,3
                # x-axis
                obs_onlyprime[-obs_idx][ext_p_idx][0] = obs_onlyprime[-obs_idx][ext_p_idx][0] + delta_distance

            robots_obstacles_sp_prime = [x for i, x in enumerate(
                followers_sp_prime + [robot1.sp]) if i != (target_index - 1)]  # TODO change robot1.sp
            # each drone is defined as a small cube for inter-robots collision avoidance
            robots_obstacles_prime = poses2polygons(robots_obstacles_sp_prime)
            # combine exisiting obstacles on the map with other robots[for each i: i!=p] in formation
            obstacles_prime = np.array(obs_onlyprime + robots_obstacles_prime)
            temp_sp.append(m_original_new_local_planner(
                self_sp, self_sp_global_prime, obstacles_prime, params))

        '''
        This below code is for wall
        we move 5 walls at the same time to the original place.
        below code is about wall as obstale
        '''

        followers_sp_prime = copy.deepcopy(followers_sp)
        self_sp_global_prime = copy.deepcopy(robots[target_index].sp_global)

        wall_prime = []
        wall_copied = copy.deepcopy(OBSTACLES)

        for wall_index in range(0, 6):  # walls are 5, which is 0, 1, 2, 3, and 4
            for ext_p_idx in range(0, 4):  # 0,1,2,3 #four corner of wall
                # x-axis
                wall_copied[wall_index][ext_p_idx][0] = wall_copied[wall_index][ext_p_idx][0] + delta_distance

        robots_wall_sp_prime = [x for i, x in enumerate(
            followers_sp_prime + [robot1.sp]) if i != (target_index - 1)]  # TODO change robot1.sp
        # each drone is defined as a small cube for inter-robots collision avoidance
        robots_wall_prime = poses2polygons(robots_wall_sp_prime)
        # combine exisiting obstacles on the map with other robots[for each i: i!=p] in formation
        wall_prime = np.array(wall_copied + robots_wall_prime)
        temp_sp.append(m_original_new_local_planner(
            self_sp, self_sp_global_prime, wall_prime, params))  # temp[7]

        '''
        Below code is aggregated for writing
        '''
        # temp_sp[0] this is about the destination: goal
        temp_max_des = np.linalg.norm(after_normal_cal_sp - temp_sp[0])
        # temp_sp[1] it's about adjacent drone: leader
        temp_max_1st = np.linalg.norm(after_normal_cal_sp - temp_sp[1])
        # temp_sp[2] it's about adjacent drone
        temp_max_2nd = np.linalg.norm(after_normal_cal_sp - temp_sp[2])
        # temp_sp[3] it's about adjacent drone
        temp_max_3rd = np.linalg.norm(after_normal_cal_sp - temp_sp[3])
        # temp_sp[4] it's about obst
        temp_max_obs_btt = np.linalg.norm(after_normal_cal_sp - temp_sp[4])
        # temp_sp[5] it's about obst
        temp_max_obs_dia = np.linalg.norm(after_normal_cal_sp - temp_sp[5])
        # temp_sp[6] it's about obst
        temp_max_obs_ltr = np.linalg.norm(after_normal_cal_sp - temp_sp[6])
        # temp_sp[7] it's about wall
        temp_wall = np.linalg.norm(after_normal_cal_sp - temp_sp[7])

        # for dcc
        temp_sum = temp_max_des + temp_max_1st + temp_max_2nd + temp_max_3rd + \
            temp_max_obs_btt + temp_max_obs_dia + temp_max_obs_ltr + temp_wall

        # temp_sp[0] this is about the destination: goal
        temp_dcc_des = temp_max_des / temp_sum
        # temp_sp[1] it's about adjacent drone: leader
        temp_dcc_1st = temp_max_1st / temp_sum
        # temp_sp[2] it's about adjacent drone
        temp_dcc_2nd = temp_max_2nd / temp_sum
        # temp_sp[3] it's about adjacent drone
        temp_dcc_3rd = temp_max_3rd / temp_sum
        # temp_sp[4] it's about obst
        temp_dcc_obs_btt = temp_max_obs_btt / temp_sum
        # temp_sp[5] it's about obst
        temp_dcc_obs_dia = temp_max_obs_dia / temp_sum
        # temp_sp[6] it's about obst
        temp_dcc_obs_ltr = temp_max_obs_ltr / temp_sum
        # temp_sp[7] it's about wall
        temp_dcc_wall = temp_wall / temp_sum

        if target_index != 0:
            robots[target_index].influence_max.append([temp_max_des, temp_max_1st, temp_max_2nd, temp_max_3rd,
                                                       temp_max_obs_btt, temp_max_obs_dia, temp_max_obs_ltr, temp_wall])  # , temp_r])
            robots[target_index].dcc.append([temp_dcc_des, temp_dcc_1st, temp_dcc_2nd, temp_dcc_3rd,
                                             temp_dcc_obs_btt, temp_dcc_obs_dia, temp_dcc_obs_ltr, temp_dcc_wall])

        if target_obs is '1st':
            print("dbg temp_max_obs_ltr " + str(temp_max_obs_ltr) +
                  "|" + str(temp_max_obs_btt) + "|" + str(temp_min_obs_dia))
            # if temp_max_obs_ltr != 0.00:
            # print("[log] follower recog. obs, cont_s: "+str(temp_max_obs_ltr))
            params.record_contribution_score = True

        elif target_obs is '2nd':
            print("dbg temp_max_obs_btt " + str(temp_max_obs_btt))
            # if temp_max_obs_btt != 0.00:
            # print("[log] follower recog. obs, cont_s: "+str(temp_max_obs_btt))
            params.record_contribution_score = True

        elif target_obs is '3rd':
            # print("dbg temp_min_obs_dia " + str(temp_max_obs_dia))
            # if temp_max_obs_dia != 0.00:
            # print("[log] follower recog. obs, cont_s: "+str(temp_max_obs_dia))
            params.record_contribution_score = True

        ########
        # all log for contribution_to_sp_norm_comparing
        ########

        temp_obst_x_sp = (OBSTACLES[-2][0][0] + OBSTACLES[-2][1]
                          [0] + OBSTACLES[-2][2][0] + OBSTACLES[-2][3][0]) * 0.25
        temp_obst_y_sp = (OBSTACLES[-2][0][1] + OBSTACLES[-2][1]
                          [1] + OBSTACLES[-2][2][1] + OBSTACLES[-2][3][1]) * 0.25

        dist_obst_normal_sp = cutoff(np.linalg.norm(
            [temp_obst_x_sp, temp_obst_y_sp] - after_normal_cal_sp))


def write_influence(robots, arg_target_index, params):

    target_index = arg_target_index  # params.target_index

    # print("target_index = " + str(target_index))
    # print("total simulation time is " +
    #       str(len(robots[target_index].influence_avg)))

    temp_max_relative_s = 0
    """
    Note that the simulation tick is not the absolute tick,
    it is just the order of array.
    """

    for tick_index in range(len(robots[target_index].influence_max)):

        if tick_index == len(robots[target_index].influence_avg) - 1:
            break

        '''
        when you need to consider only obs_dia,
        use below code

        if robots[target_index].influence_max[tick_index][5] != 0.00 or robots[target_index].influence_max[tick_index + 1][5] != 0.00 :
        '''

        # everytime
        if tick_index + 1 >= len(robots[target_index].influence_max):
            continue
        if robots[target_index].influence_max[tick_index][0] != 0.00 or robots[target_index].influence_max[tick_index + 1][5] != 0.00:
            # print("contribution is now writing...")

            if target_index == 0:
                writeFile(CONTR_PN, str(target_index) +
                          " " + str(tick_index+1) +

                          " " + str(robots[target_index].influence_max[tick_index][0]) +
                          " " + str(robots[target_index].influence_max[tick_index][1]) +
                          " " + str(robots[target_index].influence_max[tick_index][2]) +
                          " " + str(robots[target_index].influence_max[tick_index][3]) +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +

                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +

                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +

                          # relative_score_with_obs_dia
                          " " + "to_be_removed" +

                          " " + "to_be_removed" + \
                          " " + "to_be_removed" + \
                          " " + "to_be_removed" + \
                          " " + "to_be_removed" + \

                          " " + "to_be_removed" +

                          " " + "to_be_removed" + \
                          " " + "to_be_removed" + \
                          " " + "to_be_removed"  # + \

                          )
            else:
                temp_max_relative_s = max(
                    temp_max_relative_s, robots[target_index].relative_score_with_obs_dia[tick_index])

                writeFile(CONTR_PN, str(target_index) +
                          " " + str(tick_index+1) +

                          " " + str(robots[target_index].influence_max[tick_index][0]) +
                          " " + str(robots[target_index].influence_max[tick_index][1]) +
                          " " + str(robots[target_index].influence_max[tick_index][2]) +
                          " " + str(robots[target_index].influence_max[tick_index][3]) +
                          " " + str(robots[target_index].influence_max[tick_index][4]) +
                          " " + str(robots[target_index].influence_max[tick_index][5]) +
                          " " + str(robots[target_index].influence_max[tick_index][6]) +
                          " " + str(robots[target_index].influence_max[tick_index][7]) +

                          " " + str(robots[target_index].dcc[tick_index][0]) +
                          " " + str(robots[target_index].dcc[tick_index][1]) +
                          " " + str(robots[target_index].dcc[tick_index][2]) +
                          " " + str(robots[target_index].dcc[tick_index][3]) +
                          " " + str(robots[target_index].dcc[tick_index][4]) +
                          " " + str(robots[target_index].dcc[tick_index][5]) +
                          " " + str(robots[target_index].dcc[tick_index][6]) +
                          " " + str(robots[target_index].dcc[tick_index][7]) +

                          " " + str(robots[target_index].distance_with_obs_ltr[tick_index]) +
                          " " + str(robots[target_index].distance_with_obs_dia[tick_index]) +
                          " " + str(robots[target_index].distance_with_obs_btt[tick_index]) +

                          # relative_score_with_obs_dia
                          " " + str(robots[target_index].relative_score_with_obs_dia[tick_index]) + \

                          " " + "to_be_removed" + \
                          " " + "to_be_removed" + \
                          " " + "to_be_removed" + \
                          " " + "to_be_removed" + \

                          " " + str(temp_max_relative_s) + \

                          " " + "to_be_removed" + \
                          " " + "to_be_removed" + \
                          " " + "to_be_removed"  # + \

                          )


def put_into_seed_pool(robots, arg_target_index, params, seed_pool_idx):

    mkdirs(SEEDPOOL_DIR + "/" + str(seed_pool_idx))

    target_index = arg_target_index  # params.target_index

    # print("target_index = " + str(target_index))
    # print("total simulation time is " +
    #       str(len(robots[target_index].influence_avg)))

    temp_max_relative_s = 0
    """
    Note that the simulation tick is not the absolute tick,
    it is just the order of array.
    """

    writeFile(SEEDPOOL_DIR + "/" + str(seed_pool_idx) + "/ref_f" + str(target_index)+".csv",
              "dcc_des " +
              "dcc_l " +
              "dcc_f2 " +
              "dcc_f3 " +
              "dcc_obs[-1] " +
              "dcc_obs[-2] " +
              "dcc_obs[-3] " +
              "dcc_wall "
              )

    for tick_index in range(len(robots[target_index].influence_max)):

        if tick_index == len(robots[target_index].influence_avg) - 1:
            break

        '''
        when you need to consider only obs_dia,
        use below code

        if robots[target_index].influence_max[tick_index][5] != 0.00 or robots[target_index].influence_max[tick_index + 1][5] != 0.00 :
        '''

        # everytime
        if tick_index + 1 >= len(robots[target_index].influence_max):
            continue
        if robots[target_index].influence_max[tick_index][0] != 0.00 or robots[target_index].influence_max[tick_index + 1][5] != 0.00:
            # print("contribution is now writing...")

            if target_index == 0:
                writeFile(SEEDPOOL_DIR + "/" + str(seed_pool_idx) + "/ref_f" + str(target_index)+".csv", str(target_index) +
                          " " + str(tick_index+1) +

                          " " + str(robots[target_index].influence_max[tick_index][0]) +
                          " " + str(robots[target_index].influence_max[tick_index][1]) +
                          " " + str(robots[target_index].influence_max[tick_index][2]) +
                          " " + str(robots[target_index].influence_max[tick_index][3]) +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +

                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +

                          " " + "to_be_removed" +
                          " " + "to_be_removed" +
                          " " + "to_be_removed" +

                          # relative_score_with_obs_dia
                          " " + "to_be_removed" +

                          " " + "to_be_removed" + \
                          " " + "to_be_removed" + \
                          " " + "to_be_removed" + \
                          " " + "to_be_removed" + \

                          " " + "to_be_removed" +

                          " " + "to_be_removed" + \
                          " " + "to_be_removed" + \
                          " " + "to_be_removed"  # + \

                          )
            else:
                temp_max_relative_s = max(
                    temp_max_relative_s, robots[target_index].relative_score_with_obs_dia[tick_index])

                writeFile(SEEDPOOL_DIR + "/" + str(seed_pool_idx) + "/ref_f" + str(target_index)+".csv",
                          str(robots[target_index].dcc[tick_index][0]) +
                          " " + str(robots[target_index].dcc[tick_index][1]) +
                          " " + str(robots[target_index].dcc[tick_index][2]) +
                          " " + str(robots[target_index].dcc[tick_index][3]) +
                          " " + str(robots[target_index].dcc[tick_index][4]) +
                          " " + str(robots[target_index].dcc[tick_index][5]) +
                          " " + str(robots[target_index].dcc[tick_index][6]) +
                          " " + str(robots[target_index].dcc[tick_index][7])

                          )

# TODO: remove arrays for record, later


def putInInitialValue(robots, followers_sp, robot1_sp):
    for i in range(0, 3):  # for all followers
        robots[i+1].U_record.append(0)  # for initial value
        robots[i+1].U_a_record.append(0)  # for initial value
        robots[i+1].U_r_record.append(0)  # for initial value
        robots[i+1].gx.append(0)  # for initial value
        robots[i+1].gy.append(0)  # for initial value
        robots[i+1].ax.append(0)
        robots[i+1].ay.append(0)
        robots[i+1].sp_global_record.append(0)
        robots[i+1].sp_record.append(0)
        robots[i+1].d2_record.append(0)
        robots[i+1].robots_obstacles.append(
            [x for p, x in enumerate(followers_sp + [robot1_sp]) if p != i])


def cal_ratio3(A, B, C):
    if(A == 0 and B == 0 and C == 0):
        return 0, 0, 0

    bigestguy = whoisbigguy3(A, B, C)

    ratio_A = A / bigestguy
    ratio_B = B / bigestguy
    ratio_C = C / bigestguy

    return ratio_A, ratio_B, ratio_C


def whoisbigguy3(A, B, C):
    bigguy = whoisbigguy(A, whoisbigguy(B, C))
    return bigguy


def cal_ratio(A, B):
    if(A == 0 and B == 0):
        return 0, 0

    bigestguy = whoisbigguy(A, B)

    ratio_A = A / bigestguy
    ratio_B = B / bigestguy

    return ratio_A, ratio_B


def whoisbigguy(A, B):
    if(A >= B):
        return A
    else:
        return B


def writeIndex_dist_obs(modified_value, _x, _from, params):
    writeFile(DIST_PN, "randomseed ["+str(params.rand_seed)+"]" + " modified_value ["+str(
        modified_value)+"] x["+str(float(_x))+"] from ["+str(int(_from))+"]")
    writeFile(DIST_PN, "sim_time " +
              "l_f1 " +
              "l_f2 " +
              "l_f3 " +
              "l_obs0(b_t_t) " +
              "leader_obs1(diagonal) " +
              "leader_obs2(l_t_r) " +
              "l_obs_wall_1 " +

              "l_f1 " +
              "f1_f2 " +
              "f1_f3 " +
              "f1_obs0(b_t_t) " +
              "f1_obs1(diagonal) " +
              "f1_obs2(l_t_r) " +
              "f1_obs_wall_1 " +

              "l_f2 " +
              "f1_f2 " +
              "f2_f3 " +
              "f2_obs0(b_t_t) " +
              "f2_obs1(diagonal) " +
              "f2_obs2(l_t_r) " +
              "f2_obs_wall_1 " +

              "l_f3 " +
              "f1_f3 " +
              "f2_f3 " +
              "f3_obs0(b_t_t) " +
              "f3_obs1(diagonal) " +
              "f3_obs2(l_t_r) " +
              "f3_obs_wall_1 "  # + \
              )


# for checking the distance between drones and obs.
def checker_dist_obs(robots, simulation_tick, params, OBSTACLES):

    # global CENTER_X
    # global CENTER_Y

    dist_obs_wall_1 = [0, 0, 0, 0]

    CENTER_X = []
    CENTER_Y = []

    for obs_i in range(1, 4):
        CENTER_X.append(
            (OBSTACLES[-obs_i][0][0] + OBSTACLES[-obs_i][1][0]
                + OBSTACLES[-obs_i][2][0] + OBSTACLES[-obs_i][3][0]) * 0.25)
        CENTER_Y.append(
            (OBSTACLES[-obs_i][0][1] + OBSTACLES[-obs_i][1][1]
                + OBSTACLES[-obs_i][2][1] + OBSTACLES[-obs_i][3][1]) * 0.25)

    for i in range(0, 4):
        dist_obs_wall_1[i] = min(
            dist_line_drone(OBSTACLES[0][0], OBSTACLES[0][1], robots[i].sp),
            dist_line_drone(OBSTACLES[0][1], OBSTACLES[0][2], robots[i].sp),
            dist_line_drone(OBSTACLES[0][2], OBSTACLES[0][3], robots[i].sp),
            dist_line_drone(OBSTACLES[0][3], OBSTACLES[0][0], robots[i].sp),
            dist_line_drone(OBSTACLES[1][0], OBSTACLES[1][1], robots[i].sp),
            dist_line_drone(OBSTACLES[1][1], OBSTACLES[1][2], robots[i].sp),
            dist_line_drone(OBSTACLES[1][2], OBSTACLES[1][3], robots[i].sp),
            dist_line_drone(OBSTACLES[1][3], OBSTACLES[1][0], robots[i].sp),
            dist_line_drone(OBSTACLES[2][0], OBSTACLES[2][1], robots[i].sp),
            dist_line_drone(OBSTACLES[2][1], OBSTACLES[2][2], robots[i].sp),
            dist_line_drone(OBSTACLES[2][2], OBSTACLES[2][3], robots[i].sp),
            dist_line_drone(OBSTACLES[2][3], OBSTACLES[2][0], robots[i].sp)
        )

    for k in range(0, 4):
        if k == 0:
            idl = 1
            m = 2
            n = 3
        elif k == 1:
            idl = 0
            m = 2
            n = 3
        elif k == 2:
            idl = 0
            m = 1
            n = 3
        else:
            idl = 0
            m = 1
            n = 2

        robots[k].distance_with_1stD.append(
            np.linalg.norm(robots[k].sp - robots[idl].sp))
        robots[k].distance_with_2ndD.append(
            np.linalg.norm(robots[k].sp - robots[m].sp))
        robots[k].distance_with_3rdD.append(
            np.linalg.norm(robots[k].sp - robots[n].sp))
        robots[k].distance_with_obs_btt.append(
            np.linalg.norm([CENTER_X[0], CENTER_Y[0]] - robots[k].sp))
        robots[k].distance_with_obs_dia.append(
            np.linalg.norm([CENTER_X[1], CENTER_Y[1]] - robots[k].sp))
        robots[k].distance_with_obs_ltr.append(
            np.linalg.norm([CENTER_X[2], CENTER_Y[2]] - robots[k].sp))
        robots[k].distance_with_obs_wall.append(cutoff(dist_obs_wall_1[k]))

    # check whether crash or not
    if simulation_tick > 10 and params.crash is False:

        params.info_crashed_time = copy.deepcopy(simulation_tick)

        """
        crash check with L with other drones or moving obstacles
        """
        if robots[0].distance_with_1stD[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "L"
            params.info_crashed_obs = "f1"
            params.info_crashed_dist = robots[0].distance_with_1stD[-1]
        elif robots[0].distance_with_2ndD[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "L"
            params.info_crashed_obs = "f2"
            params.info_crashed_dist = robots[0].distance_with_2ndD[-1]
        elif robots[0].distance_with_3rdD[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "L"
            params.info_crashed_obs = "f3"
            params.info_crashed_dist = robots[0].distance_with_3rdD[-1]
            # print("[dbg]robots[0].distance_with_3rdD[-1]: " +
            #   str(robots[0].distance_with_3rdD[-1]))
        elif robots[0].distance_with_obs_btt[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "L"
            params.info_crashed_obs = "2ndO"
            params.info_crashed_dist = robots[0].distance_with_obs_btt[-1]
        elif robots[0].distance_with_obs_dia[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "L"
            params.info_crashed_obs = "3rdO"
            params.info_crashed_dist = robots[0].distance_with_obs_dia[-1]
        elif robots[0].distance_with_obs_ltr[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "L"
            params.info_crashed_obs = "1stO"
            params.info_crashed_dist = robots[0].distance_with_obs_ltr[-1]
        # """
        # crash check with f1 with other drones or moving obstacles
        # """
        elif robots[1].distance_with_1stD[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f1"
            params.info_crashed_obs = "L"
            params.info_crashed_dist = robots[1].distance_with_1stD[-1]
        elif robots[1].distance_with_2ndD[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f1"
            params.info_crashed_obs = "f2"
            params.info_crashed_dist = robots[1].distance_with_2ndD[-1]
        elif robots[1].distance_with_3rdD[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f1"
            params.info_crashed_obs = "f3"
            params.info_crashed_dist = robots[1].distance_with_3rdD[-1]
        elif robots[1].distance_with_obs_btt[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f1"
            params.info_crashed_obs = "2ndO"
            params.info_crashed_dist = robots[1].distance_with_obs_btt[-1]
        elif robots[1].distance_with_obs_dia[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f1"
            params.info_crashed_obs = "3rdO"
            params.info_crashed_dist = robots[1].distance_with_obs_dia[-1]
        elif robots[1].distance_with_obs_ltr[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f1"
            params.info_crashed_obs = "1stO"
            params.info_crashed_dist = robots[1].distance_with_obs_ltr[-1]
        # """
        # crash check with f2 with other drones or moving obstacles
        # """
        elif robots[2].distance_with_1stD[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f2"
            params.info_crashed_obs = "L"
            params.info_crashed_dist = robots[2].distance_with_1stD[-1]
        elif robots[2].distance_with_2ndD[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f2"
            params.info_crashed_obs = "f1"
            params.info_crashed_dist = robots[2].distance_with_2ndD[-1]
        elif robots[2].distance_with_3rdD[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f2"
            params.info_crashed_obs = "f3"
            params.info_crashed_dist = robots[2].distance_with_3rdD[-1]
        elif robots[2].distance_with_obs_btt[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f2"
            params.info_crashed_obs = "2ndO"
            params.info_crashed_dist = robots[2].distance_with_obs_btt[-1]
        elif robots[2].distance_with_obs_dia[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f2"
            params.info_crashed_obs = "3rdO"
            params.info_crashed_dist = robots[2].distance_with_obs_dia[-1]
        elif robots[2].distance_with_obs_ltr[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f2"
            params.info_crashed_obs = "1stO"
            params.info_crashed_dist = robots[2].distance_with_obs_ltr[-1]
        # """
        # crash check with f3 with other drones or moving obstacles
        # """
        elif robots[3].distance_with_1stD[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f3"
            params.info_crashed_obs = "L"
            params.info_crashed_dist = robots[3].distance_with_1stD[-1]
        elif robots[3].distance_with_2ndD[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f3"
            params.info_crashed_obs = "f1"
            params.info_crashed_dist = robots[3].distance_with_2ndD[-1]
        elif robots[3].distance_with_3rdD[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f3"
            params.info_crashed_obs = "f2"
            params.info_crashed_dist = robots[3].distance_with_3rdD[-1]
        elif robots[3].distance_with_obs_btt[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f3"
            params.info_crashed_obs = "2ndO"
            params.info_crashed_dist = robots[3].distance_with_obs_btt[-1]
        elif robots[3].distance_with_obs_dia[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f3"
            params.info_crashed_obs = "3rdO"
            params.info_crashed_dist = robots[3].distance_with_obs_dia[-1]
        elif robots[3].distance_with_obs_ltr[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f3"
            params.info_crashed_obs = "1stO"
            params.info_crashed_dist = robots[3].distance_with_obs_ltr[-1]
        # """
        # crash check with walls
        # """
        elif robots[0].distance_with_obs_wall[-1] < CRASH_THRESHOLD:  # 0.00001:
            params.crash = True
            params.info_crashed_drone = "L"
            params.info_crashed_obs = "wall"
            params.info_crashed_dist = robots[0].distance_with_obs_wall[-1]
        # 0.00001:
        elif robots[1].distance_with_obs_wall[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f1"
            params.info_crashed_obs = "wall"
            params.info_crashed_dist = robots[1].distance_with_obs_wall[-1]
        # 0.00001:
        elif robots[2].distance_with_obs_wall[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f2"
            params.info_crashed_obs = "wall"
            params.info_crashed_dist = robots[2].distance_with_obs_wall[-1]
        # 0.00001:
        elif robots[3].distance_with_obs_wall[-1] < CRASH_THRESHOLD:
            params.crash = True
            params.info_crashed_drone = "f3"
            params.info_crashed_obs = "wall"
            params.info_crashed_dist = robots[3].distance_with_obs_wall[-1]

    l_sr = pd.Series(
        [np.linalg.norm(robots[0].sp - robots[1].sp),
            np.linalg.norm(robots[0].sp - robots[2].sp),
            np.linalg.norm(robots[0].sp - robots[3].sp),
            np.linalg.norm([CENTER_X[0], CENTER_Y[0]] - robots[0].sp),
            np.linalg.norm([CENTER_X[1], CENTER_Y[1]] - robots[0].sp),
            np.linalg.norm([CENTER_X[2], CENTER_Y[2]] - robots[0].sp),
            dist_obs_wall_1[0]])
    l_index = [
        " l_f1 ", " l_f2 ", " l_f3 ", " l_obs0(b_t_t) ",
        " leader_obs1(diagonal) ", " leader_obs2(l_t_r) ",
        " l_obs_wall_1 "
    ]
    l_sr.index = l_index
    # l_rank = l_sr.rank()  # not used?

    f1_sr = pd.Series(
        [np.linalg.norm(robots[0].sp - robots[1].sp),
            np.linalg.norm(robots[1].sp - robots[2].sp),
            np.linalg.norm(robots[1].sp - robots[3].sp),
            np.linalg.norm([CENTER_X[0], CENTER_Y[0]] - robots[1].sp),
            np.linalg.norm([CENTER_X[1], CENTER_Y[1]] - robots[1].sp),
            np.linalg.norm([CENTER_X[2], CENTER_Y[2]] - robots[1].sp),
            dist_obs_wall_1[1]])
    f1_index = [
        " f1_l ", " f1_f2 ", " f1_f3 ", " f1_obs0(b_t_t) ",
        " f1_obs1(diagonal) ", " f1_obs2(l_t_r) ",
        " f1_obs_wall_1 "
    ]

    f1_sr.index = f1_index
    # f1_rank = f1_sr.rank()  # not used?

    f2_sr = pd.Series(
        [np.linalg.norm(robots[0].sp - robots[2].sp),
            np.linalg.norm(robots[1].sp - robots[2].sp),
            np.linalg.norm(robots[2].sp - robots[3].sp),
            np.linalg.norm([CENTER_X[0], CENTER_Y[0]] - robots[2].sp),
            np.linalg.norm([CENTER_X[1], CENTER_Y[1]] - robots[2].sp),
            np.linalg.norm([CENTER_X[2], CENTER_Y[2]] - robots[2].sp),
            dist_obs_wall_1[2]])
    f2_index = [
        " f2_l ", " f2_f1 ", " f2_f3 ", " f2_obs0(b_t_t) ",
        " f2_obs1(diagonal) ", " f2_obs2(l_t_r) ",
        " f2_obs_wall_1 "
    ]
    f2_sr.index = f2_index
    # f2_rank = f2_sr.rank()  # not used?

    f3_sr = pd.Series(
        [np.linalg.norm(robots[0].sp - robots[3].sp),
            np.linalg.norm(robots[1].sp - robots[3].sp),
            np.linalg.norm(robots[2].sp - robots[3].sp),
            np.linalg.norm([CENTER_X[0], CENTER_Y[0]] - robots[3].sp),
            np.linalg.norm([CENTER_X[1], CENTER_Y[1]] - robots[3].sp),
            np.linalg.norm([CENTER_X[2], CENTER_Y[2]] - robots[3].sp),
            dist_obs_wall_1[3]])
    f3_index = [
        " f3_l ", " f3_f1 ", " f3_f2 ", " f3_obs0(b_t_t) ",
        " f3_obs1(diagonal) ", " f3_obs2(l_t_r) ",
        " f3_obs_wall_1 "
    ]
    f3_sr.index = f3_index
    # f3_rank = f3_sr.rank()  # not used?

    # for distance rank
    # writeFile(
    #     "distance_rank_l.log",
    #     "sim_t " + str(simulation_tick) + " rank " + str(np.matrix(l_rank)))
    # writeFile(
    #     "distance_rank_f1.log",
    #     "sim_t " + str(simulation_tick) + " rank " + str(np.matrix(f1_rank)))
    # writeFile(
    #     "distance_rank_f2.log",
    #     "sim_t " + str(simulation_tick) + " rank " + str(np.matrix(f2_rank)))
    # writeFile(
    #     "distance_rank_f3.log",
    #     "sim_t " + str(simulation_tick) + " rank " + str(np.matrix(f3_rank)))


# checking crash
# TODO: this will be removed after simply checking
def checker_crash_simple(simulation_tick, _print=False):

    for o_i in range(0, 3):
        # TODO: activate below code when you test this function
        # D1 = math.sqrt(math.pow((CENTER_X[o_i] - robot1.sp[0]), 2) + math.pow((CENTER_Y[o_i] - robot1.sp[1]), 2))
        D1 = 1
        if D1 <= 0.07:
            if _print:
                print('Simulation time: ', simulation_tick)
                print(
                    'Leader has crashed with obs[', o_i, '] ! at [',
                    CENTER_X[o_i], CENTER_Y[o_i], ']')
                print('Leader is at ', robot1.sp)
                print(int(robot1.sp[0] * 100), int(robot1.sp[1] * 100))
                print(robot1.U[1:3, 1:5])
            return True

        for r_j in range(0, 3):
            # TODO: activate below code when you test this function
            # D2 = math.sqrt(math.pow((CENTER_X[o_i] - followers_sp[r_j][0]), 2) + math.pow((CENTER_Y[o_i] - followers_sp[r_j][1]), 2))
            D2 = 1
            if D2 <= 0.07:
                if _print:
                    print('Simulation time: ', simulation_tick)
                    print(
                        'Follower[', r_j, '] has crashed with obs[',
                        o_i, '] ! at [', CENTER_X[o_i], CENTER_Y[o_i], ']')
                    print(
                        int(followers_sp[r_j][0] * 100),
                        int(followers_sp[r_j][1] * 100))
                    print('follower is at ', followers_sp[r_j])
                return True

    return False


"""
Below code is for simple tool for calculation in this script
"""


def checker_skip(robot1, simulation_tick, centroid, params):
    if norm(robot1.sp_global - centroid) >= params.max_sp_dist:
        writeFile("[log]skip.txt", "skip's tick " + str(simulation_tick))


# line l is consist of pointA and B, pointC is target
def dist_line_drone(pointA, pointB, pointC):
    pointH = np.array([0, 0])

    if(pointA[1] - pointB[1] == 0):
        pointH = np.array([pointC[0], pointA[1]])
    elif(pointA[0] - pointB[0] == 0):
        pointH = np.array([pointA[0], pointC[1]])
    else:
        gradient_line_AB = (pointA[1] - pointB[1]) / (pointA[0] - pointB[0])
        gradient_line_orth_AB = - 1 / gradient_line_AB
        pointH_x = (-gradient_line_AB * pointB[0] + pointB[1] + gradient_line_orth_AB *
                    pointC[0] - pointC[1]) / (gradient_line_orth_AB - gradient_line_AB)
        pointH_y = gradient_line_orth_AB * (pointH_x - pointC[0]) + pointC[1]
        pointH = np.array([pointH_x, pointH_y])
    # max(pointA[0], pointB[0])
    # min(pointA[0], pointB[0])

    if(pointH[0] <= max(pointA[0], pointB[0]) and pointH[0] >= min(pointA[0], pointB[0]) and pointH[1] <= max(pointA[1], pointB[1]) and pointH[1] >= min(pointA[1], pointB[1])):
        return np.linalg.norm(pointH - pointC)
    else:
        return min(np.linalg.norm(pointA - pointC), np.linalg.norm(pointB - pointC))


def cutoff(number):
    if(number <= 1.0):
        return number
    else:
        return 1.0


def distance_between_dcc(comparison_1, comparison_2):

    distance = 0
    temp_element_wise = 0
    start_tick = 1

    end_tick = 100
    if len(comparison_1) <= len(comparison_2):
        end_tick = len(comparison_1)
    else:
        end_tick = len(comparison_2)

    num_object = 8

    for tick_index in range(start_tick, end_tick):
        for object_index in range(0, num_object):
            temp_temp = math.pow((comparison_1[tick_index][object_index] -
                                  comparison_2[tick_index][object_index]), 2)
            temp_element_wise += temp_temp

    distance = math.sqrt(temp_element_wise)

    return distance


def mkdirs(pn):
    try:
        os.makedirs(pn)
    except OSError:
        pass


def update_size_pool(filename, contents):
    with open(str(filename), 'w') as f:
        f.write("poolsize" + '\n')
        f.write(str(contents) + '\n')


def load_size_pool(filename):

    loaded = np.loadtxt(open(filename, "rb"),
                        delimiter=",", skiprows=1)
    print("loaded: "+str(loaded))
    return loaded


def update_spawning_pool(filename, contents):
    with open(str(filename), 'a') as f:
        f.write(str(contents) + '\n')


def update_candidate_spawning_pool(filename, contents):
    with open(str(filename), 'a') as f:
        f.write(str(contents) + '\n')


def make_perturbation(current_spawning_point, mode):

    perturbed_coord = np.array([0.0, 0.0])

    rnd_length = float(np.random.rand(1))  # float
    temp_rnd_theta = float(np.random.rand(1))
    rnd_theta = 2.0 * 3.14159 * temp_rnd_theta  # float

    coef_divider_big = 2.0
    coef_divider_small = 5.0

    coef_length_big = 0.5
    coef_length_small = 0.1

    if mode == 'big':
        perturbed_coord[0] = current_spawning_point[0] + \
            (coef_length_big + rnd_length / coef_divider_big) * math.cos(rnd_theta)
        perturbed_coord[1] = current_spawning_point[1] + \
            (coef_length_big + rnd_length / coef_divider_big) * math.sin(rnd_theta)

    else:  # 'small'
        perturbed_coord[0] = current_spawning_point[0] + \
            (coef_length_small + rnd_length /
             coef_divider_small) * math.cos(rnd_theta)
        perturbed_coord[1] = current_spawning_point[1] + \
            (coef_length_small + rnd_length /
             coef_divider_small) * math.sin(rnd_theta)

    return perturbed_coord

# TODO: make this up


def prevent_near_spawn(size_drone, leader_sp, f1_sp, f2_sp, f3_sp, atk_sp_to_be_spawned):

    while (norm(atk_sp_to_be_spawned - leader_sp) >= 2 * size_drone and norm(atk_sp_to_be_spawned - f1_sp) >= 2 * size_drone and norm(atk_sp_to_be_spawned - f2_sp) >= 2 * size_drone and norm(atk_sp_to_be_spawned - f3_sp) >= 2 * size_drone):

        perturbed_coord = make_perturbation(
            current_spawning_point=pop_up_from_spawning_pool, mode='big')

        filtered_pose = np.array([0.0, 0.0])

    return filtered_pose

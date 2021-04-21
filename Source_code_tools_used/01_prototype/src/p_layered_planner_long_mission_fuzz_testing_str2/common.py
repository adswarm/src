import os
from tools import *
from new_tools import *
from svgpath2mpl import parse_path

HEADER = "sim_time l_sp_x l_sp_y f1_sp_x f1_sp_y f2_sp_x f2_sp_y f3_sp_x \
f3_sp_y obs(ltr)_x obs(ltr)_y obs(dia)_x obs(dia)_y obs(btt)_x \
obs(btt)_y des_l_x des_l_y des_f1_x des_f1_y des_f2_x des_f2_y \
des_f3_x des_f3_y crash? who? with? when? trapped?"

# CENTER_X = []
# CENTER_Y = []


# Metrics to measure (for post-processing)
class Metrics:
    def __init__(self):
        self.mean_dists_array = []
        self.max_dists_array = []
        self.centroid_path = [np.array([0, 0])]
        self.centroid_path_length = 0
        self.robots = []
        self.vels_mean = []
        self.vels_max = []
        self.area_array = []
        self.cpu_usage_array = []  # [%]
        self.memory_usage_array = []  # [MiB]

        # TODO: fix this absolute link
        self.folder_to_save = '/home/rus/Desktop/'


class Params:
    def __init__(self):
        # show RRT construction, set 0 to reduce time of
        # the RRT algorithm
        self.animate_rrt = 0

        # show robots movement
        self.visualize = 0

        # process and visualize the simulated experiment
        # data after the simulation
        self.postprocessing = 0

        # save postprocessing metrics to the XLS-file
        self.savedata = 0

        # max number of samples to build the RRT
        self.maxiters = 500

        # with probability goal_prob, sample the goal
        self.goal_prob = 0.05

        # [m], min distance os samples from goal to add goal node to the RRT
        self.minDistGoal = 0.25

        # [m], extension parameter: this controls how far
        # the RRT extends in each step.
        self.extension = 0.8

        # [m], map size in X-direction
        self.world_bounds_x = [-2.5, 2.5]

        # [m], map size in Y-direction
        self.world_bounds_y = [-2.5, 2.5]

        self.drone_vel = 4.0  # [m/s]

        self.ViconRate = 100  # [Hz]

        # [m] potential fields radius, defining repulsive area size
        # near the obstacle
        self.influence_radius = 0.3  # 0.15 -> 0.3

        # [m], maximum distance threshold to reach the goal
        self.goal_tolerance = 0.10  # 0.05

        # number of robots in the formation
        self.num_robots = 4  # 4-> 6

        # [m], distance between robots in default formation
        self.interrobots_dist = 0.5  # 0.3 -> 0.5

        # [m], maximum distance between current robot's pose
        # and the sp from global planner
        self.max_sp_dist = 0.2 * self.drone_vel
        self.target_index = 99
        self.rand_seed = 999
        self.attractive_coef = 1. / 700  # 1./700
        # 200 -> 400 for expansion safe distance (0.3)
        self.repulsive_coef = 400
        self.w_bound = 20

        self.crash = False

        self.contribution = False

        # mode config.
        self.all_sp_record_for_replay = False  # fixed
        self.record_contribution_score = False

        # 1
        self.mode_replay = False
        # 2
        self.mode_stop_before_obs = False
        # 3
        self.crash_check_for_random_testing = False
        # 4
        self.mode_randomtesting = False
        # 5
        self.mode_record_trajectory_replay = True
        # 6
        self.already_written_allsp = False  # fixed
        # 7
        self.mode_defective = False

        self.info_crashed_drone = "null"
        self.info_crashed_obs = "null"
        self.info_crashed_time = 0.00
        self.info_crashed_dist = 0.00

        self.theta_based_on_centroid = 0.00

        self.info_trapped_drone = "null"

        # should be larger than this
        self.info_trap_boundary_x = -1.65

        # should be larger than this
        self.info_trap_boundary_y = 0.15

        # self.empty_obs = False
        """
        This is for project swarm attack
        """
        self.victim_index_1 = 0
        self.victim_index_2 = 0
        self.victim_index_3 = 0
        self.spawntime = 20  # 120: far // 20: close // 70: middle
        self.obst_size_bit = 0.1

        self.fuzz_threshold = 4.0
        self.end_seed_pool_idx = 1
        self.flag_meaningless = False

    def update_param(self, _arr):

        self.repulsive_coef = _arr[0]
        self.attractive_coef = _arr[1]
        self.influence_radius = _arr[2]
        self.interrobots_dist = _arr[3]
        self.drone_vel = _arr[4]
        self.w_bound = _arr[5]

    def ret_param_to_str(self):

        msg = "rep: %f, att: %f, inf: %f, int: %f, dro: %f, wbo: %f"\
            % (self.repulsive_coef, self.attractive_coef, self.influence_radius,
                self.interrobots_dist, self.drone_vel, self.w_bound)
        return msg


def writeFile(filename, contents):
    with open(str(filename), 'a') as f:
        f.write(str(contents) + '\n')


def mkdirs(pn):
    try:
        os.makedirs(pn)
    except OSError:
        pass


def visualize2D(tick, obs, params, robots, robot1, centroid, traj_global):
    """
    Visualization: transition to sub pub is needed
    """

    draw_map(obs)
    # draw_gradient(robots[1].U) if params.num_robots > 1 \
    #     else draw_gradient(robots[0].U)

    smiley = parse_path("""M458 2420 c-215 -38 -368 -257 -329 -469 34 -182 175 -314 354 -329 l57 -4 0 45 0 44 -42 7 c-101 16 -187 79 -236 171 -37 69 -38 187 -4 257 30 60 90 120 150 150 70 34 188 33 258 -4 89 -47 153 -136 169 -235 l7 -43 50 0 51 0 -6 59 c-13 147 -124 285 -268 334 -60 20 -152 28 -211 17z M1940 2417 c-172 -39 -302 -181 -317 -347 l-6 -60 51 0 50 0 12 52 c14 70 49 126 110 181 118 106 284 100 399 -14 64 -64 86 -120 86 -214 0 -67 -5 -88 -27 -130 -49 -92 -135 -155 -236 -171 l-42 -7 0 -49 0 -50 58 4 c115 8 242 91 306 200 36 61 59 177 51 248 -30 244 -260 410 -495 357z M506 2038 c-9 -12 -16 -41 -16 -64 0 -39 11 -56 158 -240 87 -110 161 -205 166 -212 5 -9 10 -382 6 -494 0 -3 -74 -97 -165 -208 l-165 -202 0 -52 c0 -68 18 -86 86 -86 40 0 55 5 80 28 17 15 112 89 211 166 l180 138 239 0 239 -1 209 -165 c203 -162 210 -166 256 -166 60 0 80 20 80 81 0 43 -8 55 -170 264 l-170 220 0 230 c0 202 2 233 18 257 9 15 86 108 170 208 l152 180 0 54 c0 65 -19 86 -76 86 -36 0 -58 -15 -234 -151 -107 -83 -205 -158 -217 -166 -19 -12 -67 -15 -260 -15 l-238 1 -209 165 -209 166 -53 0 c-43 0 -56 -4 -68 -22z M415 926 c-199 -63 -321 -258 -286 -457 31 -179 161 -309 340 -340 75 -14 171 1 248 37 116 55 209 188 220 314 l6 60 -49 0 -49 0 -17 -70 c-20 -84 -62 -147 -123 -188 -154 -102 -363 -44 -446 124 -35 72 -34 189 3 259 49 92 135 155 236 171 l42 7 0 48 0 49 -42 -1 c-24 0 -61 -6 -83 -13z M2020 882 l0 -50 43 -7 c99 -16 188 -80 235 -169 22 -43 27 -64 27 -131 0 -98 -23 -155 -90 -219 -177 -172 -471 -67 -511 183 l-7 41 -50 0 -50 0 6 -60 c11 -126 102 -257 218 -314 251 -123 542 26 590 303 39 221 -132 448 -351 468 l-60 6 0 -51z""")
    smiley.vertices -= smiley.vertices.mean(axis=0)

    # for robot in robots: plt.plot(
    #    robot.sp[0], robot.sp[1], '^', color='blue',
    #    markersize=10, zorder=15) # robots poses

    for target_i in range(0, 4):
        if target_i == params.victim_index_1:
            plt.plot(
                robots[target_i].sp[0], robots[target_i].sp[1], marker=smiley, color='orange',
                markersize=10, zorder=15)  # targetted robots poses
            # print("params.victim_index_1 in visualize2D: " +
            #       str(params.victim_index_1))
        elif target_i == params.victim_index_2:
            plt.plot(
                robots[target_i].sp[0], robots[target_i].sp[1], marker=smiley, color='purple',
                markersize=10, zorder=15)  # targetted robots poses
        # elif target_i == params.victim_index_2:
        # elif target_i == params.victim_index_3:
        else:
            plt.plot(
                robots[target_i].sp[0], robots[target_i].sp[1], marker=smiley, color='blue',
                markersize=10, zorder=15)  # robots poses

    plt.plot(
        obs[-3][0][0], obs[-3][0][1], marker=smiley, color='red',
        markersize=10, zorder=15)  # attacker drone poses

    plt.plot(
        obs[-2][0][0], obs[-2][0][1], marker=smiley, color='cyan',
        markersize=10, zorder=15)  # attacker drone poses

    robots_poses = []

    for robot in robots:
        robots_poses.append(robot.sp)

    robots_poses.sort(
        key=lambda p: atan2(p[1] - centroid[1], p[0] - centroid[0]))
    plt.gca().add_patch(Polygon(robots_poses, color='yellow'))
    plt.plot(
        centroid[0], centroid[1], '*', color='b', markersize=10,
        label='Centroid position')
    plt.plot(
        robot1.route[:, 0], robot1.route[:, 1], linewidth=2,
        color='green', label="Leader's path", zorder=10)

    # for robot in robots[1:]:
    #    plt.plot(
    #    robot.route[:, 0], robot.route[:, 1], '--', linewidth=2,
    #    color='green', zorder=10)

    # if params.mode_replay is False:
    #     plt.plot(
    #         P[:, 0], P[:, 1], linewidth=3, color='orange',
    #         label='Global planner path')

    # if params.mode_replay is False:
    #     plt.plot(
    #         traj_global[sp_ind, 0], traj_global[sp_ind, 1], 'ro',
    #         color='blue', markersize=7, label='Global planner setpoint')

    # plt.plot(
    #     xy_start[-1][0], xy_start[-1][1], 'bo', color='red', markersize=20,
    #     label='start')
    # plt.plot(
    #     xy_goal[0], xy_goal[1], 'bo', color='green', markersize=20,
    #     label='goal')
    time = tick
    plt.text(
        -2.2, 2.2, 'Time = ' + str(time),
        bbox=dict(facecolor='red', alpha=0.2))
    plt.text(
        -2.2, 1.8, 'l = r, f1 = bl, f2 = br, f3 = or',
        bbox=dict(facecolor='blue', alpha=0.2))
    # plt.legend()

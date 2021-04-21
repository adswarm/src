import numpy as np
from numpy.linalg import norm
from math import *
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import Polygon
import xlwt
import time
import os
import copy


def writeFile(filename, contents):
    with open(str(filename), 'a') as f:
        f.write(str(contents) + '\n')


'''
pure
'''
# REPLAY_DIR = "13"
REPLAY_DIR = "pure_1"

# REPLAY_DIR = "after_modification_global_vari_r_x0.2_rollback_20"
# REPLAY_DIR = "r_x0.2_rollback_20_1_new"
# REPLAY_DIR = "r_x2.0_rollback_220_1"
# REPLAY_DIR = "r_x1.0_rollback_0_1"


''' FILENAME '''
# FILENAME = "robot_3_sp_1"
# No = "13"
No = "1"


data_robot1_sp_global = np.load(
    REPLAY_DIR + "/robot_1_sp_global_" + No + ".npy")
data_robot2_sp_global = np.load(
    REPLAY_DIR + "/robot_2_sp_global_" + No + ".npy")
data_robot3_sp_global = np.load(
    REPLAY_DIR + "/robot_3_sp_global_" + No + ".npy")
data_robot4_sp_global = np.load(
    REPLAY_DIR + "/robot_4_sp_global_" + No + ".npy")


data_robot1_sp = np.load(
    REPLAY_DIR + "/robot_1_sp_" + No + ".npy")
data_robot2_sp = np.load(
    REPLAY_DIR + "/robot_2_sp_" + No + ".npy")
data_robot3_sp = np.load(
    REPLAY_DIR + "/robot_3_sp_" + No + ".npy")
data_robot4_sp = np.load(
    REPLAY_DIR + "/robot_4_sp_" + No + ".npy")

data_obstacles = np.load(
    REPLAY_DIR + "/obstacles_" + No + ".npy")  # fixed

"""data"""
DATA1 = data_robot1_sp
DATA2 = data_robot2_sp
DATA3 = data_robot3_sp
DATA4 = data_robot4_sp
DATA_o = data_obstacles

filename1 = "data_robot1_sp"
filename2 = "data_robot2_sp"
filename3 = "data_robot3_sp"
filename4 = "data_robot4_sp"
filename_o = "obstacles_1"

# simul_tick = 7
# test = []
# test = DATA[0: simul_tick - 2]
# test.append(copy.deepcopy(np.matrix(DATA)))

# print("[log]test: "+str(test))
# print("[log][test]DATA: "+str(DATA[0: simul_tick - 2]))
# print("[log][test]DATA: "+str(DATA[simul_tick - 2]))


# writeFile(REPLAY_DIR + "_" +filename1 +".csv", DATA1)
# writeFile(REPLAY_DIR + "_" +filename2 +".csv", DATA2)
# writeFile(REPLAY_DIR + "_" +filename3 +".csv", DATA3)
# writeFile(REPLAY_DIR + "_" +filename4 +".csv", DATA4)
# writeFile("obstacles_1.csv", DATA_o)

'''
print(DATA_o[0][-2])
===
[[ 4.586 -1.9  ]
 [ 4.686 -1.9  ]
 [ 4.686 -1.8  ]
 [ 4.586 -1.8  ]]
'''

# print(center_x)
# print(center_y)
for idx in range(len(DATA1)):
    center_x = 0.25 * (DATA_o[idx][-2][0][0] + DATA_o[idx][-2]
                       [1][0] + DATA_o[idx][-2][2][0] + DATA_o[idx][-2][3][0])
    center_y = 0.25 * (DATA_o[idx][-2][0][1] + DATA_o[idx][-2]
                       [1][1] + DATA_o[idx][-2][2][1] + DATA_o[idx][-2][3][1])

    writeFile("comp.csv", str(DATA1[idx][0])+","+str(DATA1[idx][1]) + "," + str(DATA2[idx][0])+","+str(DATA2[idx][1]) + "," + str(
        DATA3[idx][0])+","+str(DATA3[idx][1]) + "," + str(DATA4[idx][0])+","+str(DATA4[idx][1]) + ","+str(center_x)+","+str(center_y))
    # print(DATA1[idx][0])

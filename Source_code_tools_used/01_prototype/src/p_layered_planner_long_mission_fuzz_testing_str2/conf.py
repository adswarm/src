import os
import copy
from obstacle import *
from test_cases import *

# file path
OUTPUT_DIR = "output"
REPLAY_DIR = "replay"
SEEDPOOL_DIR = "seedpool"
CONTR_PN = os.path.join(OUTPUT_DIR, "contribution.log")
ALLSP_PN = os.path.join(OUTPUT_DIR, "all_sp.log")
CRASH_PN = os.path.join(OUTPUT_DIR, "crash.log")
CRASH_FOR_RT_PN = os.path.join(OUTPUT_DIR, "crash_for_rt.log")
DIST_PN = os.path.join(OUTPUT_DIR, "distance.log")
TESTCASE_PN = os.path.join("test", "testcases")
ATTACK_RES = os.path.join(
    OUTPUT_DIR, "EXP_103_str3_vel_1.5_1.0_obsSize_2.0_0.5.log")
ATTACK_SPOT = os.path.join(OUTPUT_DIR, "attack_spot.log")

# how to define crash?
CRASH_THRESHOLD = 0.3  # 0.1 -> 0.3
MAX_TICK = 200  # original 500
MAP_SIZE = 500  # original is 500
MAP_BOUNDS_METER = 2.5  # original is 2.5

# when contribution score check? how far from obs?
CSCORE_WRITE_THRESHOLD = 0.8

# constant param: coef name
COEF = {}
COEF["r"] = "params.repulsive_coef"
COEF["a"] = "params.attractive_coef"
COEF["i"] = "params.influence_radius"
COEF["d"] = "params.interrobots_dist"
COEF["v"] = "params.drone_vel"
COEF["b"] = "params.w_bound"

# global variable:

# #  1) COMPLEX_OBS, 2) NORMAL_OBS, 3) EMPTY_OBS
# if "TESTCASE" in os.environ:
#     OBSTACLES = copy.deepcopy(TEMP_OBS)
# else:
#     OBSTACLES = copy.deepcopy(COMPLEX_OBS)
#     # OBSTACLES = NORMAL_OBS


# obstacles_ltr_record = []
# obstacles_dia_record = []
# obstacles_btt_record = []
# obstacles_ltr_record.append(OBSTACLES[-3])
# obstacles_dia_record.append(OBSTACLES[-2])
# obstacles_btt_record.append(OBSTACLES[-1])


#  1) test, 2) test_original, 3) test_ajust
TESTFUNC = "test_crash"

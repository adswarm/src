import os
import copy
import logging
import numpy as np
from obstacle import *

'''
logging mode
'''
logging.basicConfig(level=logging.DEBUG)

'''
I/O configuration
- file path
'''

OUTPUT_DIR = "output"
REPLAY_DIR = "replay" #TODO check and remove
SEEDPOOL_DIR = "seedpool"

CONTR_PN = os.path.join(OUTPUT_DIR, "contribution.log")
ALLSP_PN = os.path.join(OUTPUT_DIR, "all_sp.log")
CRASH_PN = os.path.join(OUTPUT_DIR, "crash.log")
CRASH_FOR_RT_PN = os.path.join(OUTPUT_DIR, "crash_for_rt.log")
DIST_PN = os.path.join(OUTPUT_DIR, "distance.log")
TESTCASE_PN = os.path.join("test", "testcases") #TODO check and remove
ATTACK_RES = os.path.join(
    OUTPUT_DIR, "EXP_103_str3_vel_1.5_1.0_obsSize_2.0_0.5.log") #TODO check and remove
RES = os.path.join(OUTPUT_DIR, "result.log") #TODO check and RENAME!
SIM_RESULT  = os.path.join(OUTPUT_DIR, "final_sim_result.log") #TODO check and RENAME!
ATTACK_SPOT = os.path.join(OUTPUT_DIR, "attack_spot.log") #TODO check and remove
TIMESTAMP = os.path.join(OUTPUT_DIR, "timestamp.log")

'''
Crash threshold = safety distance
'''
CRASH_THRESHOLD = 0.3  # 0.1 -> 0.3


'''
General configuration for simulation
'''
VISUALIZE = False

MAX_TICK = 300  # original 500
NUM_EXPERIMENTS = 2001 

NUM_ATTACKER = 1


'''
Environment configuration
'''
MAP_SIZE = 500  # original is 500
MAP_BOUNDS_METER = 2.5  # original is 2.5

XY_START = np.array([1.2, 1.25]) #np.array([-2.2, 2.2])
XY_GOAL = np.array([2.2, -2.2]) # for simple mode, np.array([-2.2, 1.25])





'''
Attack configuration
1. target
2. strategy
3. Spawn position for each attacker
    - zone_idx in old version: (deprecated later)
    - Current version has one attacker.
4. Spawn timing for each attacker
    - Current version has one attacker.
'''


ATTACK_TARGET_MODE = 'random'

# ATTACK_TARGET = 0


ATTACK_STRATEGY = 'a' # 'a', 'b', 'c', 'd', 'e'
ATTACK_DISTANCE = 0.4

'''
Feedback configuration
- Perturbation configuration
'''
COEF_LENGTH_BIG = 0.8
REGEN_BOUNDARY = 5.0

# mode that calculates the diff between dccs
DISTANCE_MODE = 'ncc' #'normal' 

if DISTANCE_MODE == 'ncc':
    # 4.0 for 'normal'
    # 0.87 for 'ncc'
    FUZZ_THRESHOLD = 0.8
    
elif DISTANCE_MODE == 'normal':
    FUZZ_THRESHOLD = 4.0






'''
TODO
???
'''
# when contribution score check? how far from obs?
CSCORE_WRITE_THRESHOLD = 0.8



'''
Deprecated
TODO: check and remove
'''
TESTFUNC = "test_crash"

# constant param: coef name
COEF = {}
COEF["r"] = "params.repulsive_coef"
COEF["a"] = "params.attractive_coef"
COEF["i"] = "params.influence_radius"
COEF["d"] = "params.interrobots_dist"
COEF["v"] = "params.drone_vel"
COEF["b"] = "params.w_bound"

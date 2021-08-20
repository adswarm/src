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
# import time

from conf import *
from common import *
from tools import *
from rrt import *
from potential_fields import *
from new_tools import *

start_seed_pool_idx = 1
end_seed_pool_idx = 1000
fuzz_threshold = 0.8 #0.87#4.0

# SEEDPOOL_DIR_SPECIAL = '/home/cj/91_data_storage_mt/Github/Project_AdSwarm_A1/result_to_analyze/test_07_rand_07_776times_boundary_level4_to_see_expension_boundary/seedpool'
# SEEDPOOL_DIR_SPECIAL = '/home/cj/91_data_storage_mt/Github/Project_AdSwarm_A1/result_to_analyze/test_02_rand_02_427times_V/seedpool'
SEEDPOOL_DIR_SPECIAL = '/home/cj/91_data_storage_mt/Github/Project_AdSwarm_A1/seedpool'
def foo():

    print(COEF_LENGTH_BIG)

for seed_pool_idx in tqdm(range(start_seed_pool_idx, end_seed_pool_idx)):

    min_dcc = 100
    min_dcc_seed = 0
    unique = False

    for seed_pool_idx_inner in range(0, seed_pool_idx):
        # print("[%d] <-> [%d]" % (seed_pool_idx, seed_pool_idx_inner))

        ref_f1 = np.loadtxt(open(SEEDPOOL_DIR_SPECIAL + "/"+str(seed_pool_idx)+"/ref_f1.csv", "rb"),
                            delimiter=" ", skiprows=1)
        ref_f2 = np.loadtxt(open(SEEDPOOL_DIR_SPECIAL + "/"+str(seed_pool_idx)+"/ref_f2.csv", "rb"),
                            delimiter=" ", skiprows=1)
        ref_f3 = np.loadtxt(open(SEEDPOOL_DIR_SPECIAL + "/"+str(seed_pool_idx)+"/ref_f3.csv", "rb"),
                            delimiter=" ", skiprows=1)

        ref_f1_2 = np.loadtxt(open(SEEDPOOL_DIR_SPECIAL + "/"+str(seed_pool_idx_inner)+"/ref_f1.csv", "rb"),
                            delimiter=" ", skiprows=1)
        ref_f2_2 = np.loadtxt(open(SEEDPOOL_DIR_SPECIAL + "/"+str(seed_pool_idx_inner)+"/ref_f2.csv", "rb"),
                            delimiter=" ", skiprows=1)
        ref_f3_2 = np.loadtxt(open(SEEDPOOL_DIR_SPECIAL + "/"+str(seed_pool_idx_inner)+"/ref_f3.csv", "rb"),
                            delimiter=" ", skiprows=1)
        '''
        comparison instance 1
        '''
        distance_mode = 'ncc'
        temp_temp_dist_for_fuzz = 1.0/3.0 * (distance_between_dcc(ref_f1, ref_f1_2, distance_mode) + distance_between_dcc(
            ref_f2, ref_f2_2, distance_mode) + distance_between_dcc(ref_f3, ref_f3_2, distance_mode))

        if temp_temp_dist_for_fuzz <= min_dcc:
            min_dcc = temp_temp_dist_for_fuzz
            min_dcc_seed = seed_pool_idx

        # print("1-1. Reading files from: " +
        #         SEEDPOOL_DIR_SPECIAL + "/"+str(seed_pool_idx) + ", and dist: "+str(temp_temp_dist_for_fuzz))

    if min_dcc <= fuzz_threshold:
        unique = True
    
    writeFile("result_unique.log","[%d] <-> [%d] with dist [%f]: Unique? [%r]" % (seed_pool_idx, seed_pool_idx_inner, min_dcc, unique))


    # ts = time.gmtime()
    # print(time.strftime("%Y-%m-%d %H:%M:%S", ts))
    # # 2021-07-15 05:47:39

    # #     print("Unique!")
    # # else: 
    # #     print("Not Unique!")
    # # unique = True
    # foo()
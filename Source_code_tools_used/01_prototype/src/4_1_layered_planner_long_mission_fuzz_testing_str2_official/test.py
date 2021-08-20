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


# temp_pop_up_from_spawning_pool = np.loadtxt(open(OUTPUT_DIR + "/result.log", "rb"),
#                                             delimiter=" ", skiprows=1)

# pop_up_from_spawning_pool = temp_pop_up_from_spawning_pool[-1]

# print(pop_up_from_spawning_pool)

# file1 = open(OUTPUT_DIR + "/result.log", "r+")
# last_mat = file1.readlines()
# print(last_mat[-1])

# if(last_mat[-1] == 'XXX\n'):
#     print("OK")
# else:
#     print("not OK")

filtered_pose = np.array([1.0, 2.0])
"""
debug => 10
info => 20
warning => 30
error => 40
critical => 50

logging.basicConfig(level = logging.INFO, filename = 'datacamp.log')
logging.basicConfig(level = logging.INFO, filename = 'datacamp.log', filemode = 'w')
logging.basicConfig(format='Date-Time : %(asctime)s : Line No. : %(lineno)d - %(message)s', \
                    level = logging.DEBUG)
"""

logging.basicConfig(level=logging.DEBUG)
# logging.basicConfig(level = logging.INFO, filename = 'datacamp.log')
name1 = "Jone"
name2 = "Jane"
name3 = "Jana"
name4 = True
num1 = 123
num2 = 123.333

msg1 = "Name1 = [%s]\tName2 = [%s]\tName3 = [%s]\tName4 = [%s]\tnum1 = [%i]" % (name1, name2, name3, name4, num1)
msg2 = "Name1 = [%s]\tName2 = [%s]\tName3 = [%s]\tName4 = [%s]\tnum1 = [%d]" % (name4, name4, name4, name4, num1)
msg3 = "Name1 = [%s]\tName2 = [%s]\tName3 = [%s]\tName4 = [%s]\tnum1 = [%f]" % (name4, name4, name4, name4, num1)
logging.debug(msg1)
logging.debug(msg2)
logging.debug(msg3)
logging.info("A \t Info \t Logging \t Message")
logging.warning("A Warning Logging Message")
logging.error("An Error Logging Message")
logging.critical("A Critical Logging Message")

print(norm(filtered_pose))
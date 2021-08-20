import os
import sys
import glob
import game
import pickle

sys.path.append("../../libs/Mazify/maze")
sys.path.append("../../libs/Mazify/solvers")
from solvers import astar_solver
from ast import literal_eval as make_tuple
from maze import Maze
from draw_maze import draw_maze

"""
Usage
$ python3 mz.py create rows=10 columns=20 file-path='/tmp/small'
$ python3 mz.py solve 'start=(3,3)' 'end=(22,22)' file-path='/tmp/small.txt'

$ python3 mz.py genmap
"""

STORE_ROOT = "/tmp"
STORE_DIR = os.path.join(STORE_ROOT, "maps")


def mkdirs(pn):
    try:
        os.makedirs(pn)
    except OSError:
        pass


def get_param(type):
    for arg in sys.argv:
        tokens = arg.split('=')

        if tokens[0] == type:
            return tokens[1]
    return None

def check_max_val(_dir):
    pass


if sys.argv[1].startswith('create'):
    nrows = int(get_param('rows'))
    ncols = int(get_param('columns'))
    filepath = get_param('file-path')

    maze = Maze.create_maze(nrows, ncols)
    draw_maze(maze, file_path=filepath)


elif sys.argv[1].startswith('solve'):
    start = make_tuple(get_param('start'))
    end = make_tuple(get_param('end'))

    maze = Maze.load_from_file(get_param('file-path'))
    path = astar_solver.solve_maze(maze, start, end)
    draw_maze(maze, path)

elif sys.argv[1].startswith('play'):
    game.run_game(get_param('file-path'))

elif sys.argv[1].startswith("genmap"):

    mkdirs(STORE_DIR)

    for x in range(100):

        try:
            pn = os.path.join(STORE_DIR, "map%d" % x)
            pickle_pn = os.path.join(STORE_DIR, "map%d.pkl" % x)
            nrows = 25
            ncols = 25

            maze = Maze.create_maze(nrows, ncols)
            maze.place_obstables()

            start = (3, 3)
            end = (22, 22)
            path = astar_solver.solve_maze(maze, start, end)

            if len(path) > 0:
                draw_maze(maze, path, file_path=pn)
                obs = maze.maze_to_numpy()
                pickle.dump(obs, open(pickle_pn, 'wb'))

            del maze, path
        except:
            pass


elif sys.argv[1] == 'help':
    print('Key controls')
    print('z    Highlight current location')
    print('x    Highlight destination')
    print('t    Show solution from current location')
    print('c    Decrease frame rate')
    print('v    Increase frame rate')
    print('f    Show frame rate')
    print('Arrows or WASD for movement')

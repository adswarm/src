import numpy as np
from numpy.random import random_integers as rand
from draw_maze import ascii_representation
from constants import *


class Maze:
    def __init__(self, rows, columns):
        assert rows >= 1 and columns >= 1

        self.nrows = rows
        self.ncolumns = columns
        self.board = np.zeros((rows, columns), dtype=WALL_TYPE)
        self.board.fill(EMPTY)
        self.temporal = []
        self.coordinate = []
        self.obstacles = []

    def set_borders(self):
        self.board[0, :] = self.board[-1, :] = WALL
        self.board[:, 0] = self.board[:, -1] = WALL

    def print_coordinate(self):
        for x, y, x2, y2 in self.coordinate:
            print(x, y, x2, y2)

    def is_wall(self, x, y):
        assert self.in_maze(x, y)
        return self.board[x][y] == WALL

    def is_temporal(self, x, y):
        assert self.in_maze(x, y)
        return self.board[x][y] == TEMP

    def place_obstables(self):
        # place three moving obstacles

        obs_count = 0
        boundary = 2

        while True:
            rand_x = rand(2, self.ncolumns - 3)
            rand_y = rand(2, self.nrows - 3)
            is_valid = True

            for x in range(-boundary, boundary + 1):
                for y in range(-boundary, boundary + 1):
                    temp_x = rand_x + x
                    temp_y = rand_y + y

                    if self.board[temp_x][temp_y] == WALL:
                        is_valid = False

            if is_valid:
                obs_count += 1
                self.set_wall(rand_x, rand_y)
                self.obstacles.append((rand_x, rand_y))

            if obs_count > 2:
                #for x, y in self.obstacles:
                #    self.unset_wall(x, y)
                break

    def scale_coordinate(self, x, y, x_min, y_min):
        # x_min: -2.5, y_min: 2.5
        # x: 12, y: 12

        length = float(self.ncolumns-1)
        height = float(self.nrows-1)

        size_x = abs(x_min) * 2
        size_y = abs(y_min) * 2

        ratio_x = x / length
        ratio_y = y / height

        new_x = (size_x * ratio_x) + x_min
        new_y = -(size_y * ratio_y) + y_min

        return new_x, new_y

    def translate_coordinate(self, x1, y1, x2, y2):
        nx1, ny1 = self.scale_coordinate(x1, y1, -2.5, 2.5)
        nx2, ny2 = self.scale_coordinate(x2+1, y2+1, -2.5, 2.5)
        unit = 0.2

        # rx1: left, rx2: right
        rx1 = min(nx1, nx2)
        rx2 = max(nx1, nx2)

        # ry1: bottom, ry2: top
        ry1 = min(ny1, ny2)
        ry2 = max(ny1, ny2)

        if rx1 == rx2:
            rx2 += 0.01

        if ry1 == ry2:
            ry2 += 0.01

        return np.array([[rx1, ry1], [rx1, ry2], [rx2, ry2], [rx2, ry1]])

    def translate_obs(self, x, y):
        nx1, ny1 = self.scale_coordinate(x, y, -2.5, 2.5)
        nx2 = nx1 + 0.1
        ny2 = ny1 + 0.1

        return np.array([[nx1, ny1], [nx1, ny2], [nx2, ny2], [nx2, ny1]])

    def maze_to_numpy(self):
        obs = []

        # append fixed obstacles
        for x1, y1, x2, y2 in self.coordinate:
            # test = self.translate_coordinate(10, 10, 12, 12)
            # print(test)
            # exit()
            numpy_coordinate = self.translate_coordinate(x1, y1, x2, y2)
            obs.append(numpy_coordinate)

        # manually add the room (boundary of map)
        obs.append(
            np.array([[-2.5, -2.5], [2.5, -2.5], [2.5, -2.47], [-2.5, -2.47]]))
        obs.append(
            np.array([[-2.5, 2.47], [2.5, 2.47], [2.5, 2.5], [-2.5, 2.5]]))
        obs.append(
            np.array([[-2.5, -2.47], [-2.47, -2.47], [-2.47, 2.47], [-2.5, 2.47]]))
        obs.append(
            np.array([[2.47, -2.47], [2.5, -2.47], [2.5, 2.47], [2.47, 2.47]]))

        # moving obstacles
        for x, y in self.obstacles:
            numpy_obs = self.translate_obs(x, y)
            obs.append(numpy_obs)

        return obs

    def clear_temporal(self):
        self.temporal = []

    def t_wall(self, x, y):
        assert self.in_maze(x, y)
        self.board[x][y] = TEMP
        self.temporal.append((x, y))

    def temporal_to_wall(self):
        for x, y in self.temporal:
            self.board[x][y] = WALL

        if len(self.temporal) > 1:
            minx = 1000
            maxx = -1
            miny = 1000
            maxy = -1

            for x, y in self.temporal:
                if x < minx:
                    minx = x
                if x > maxx:
                    maxx = x
                if y < miny:
                    miny = y
                if y > maxy:
                    maxy = y

            for x in range(minx, maxx + 2):
                for y in range(miny, maxy + 2):
                    self.board[x][y] = WALL

            self.coordinate.append((minx, miny, maxx, maxy))

    def unset_wall(self, x, y):
        assert self.in_maze(x, y)
        self.board[x][y] = EMPTY

    def set_wall(self, x, y):
        assert self.in_maze(x, y)
        self.board[x][y] = WALL

    def remove_wall(self, x, y):
        assert self.in_maze(x, y)
        self.board[x][y] = EMPTY

    def in_maze(self, x, y):
        return 0 <= x < self.nrows and 0 <= y < self.ncolumns

    def in_maze_inner(self, x, y):
        if not self.in_maze(x + 2, y):
            return False
        if not self.in_maze(x - 2, y):
            return False
        if not self.in_maze(x, y + 2):
            return False
        if not self.in_maze(x, y - 2):
            return False
        return True

    def wall_near(self, x, y):
        if self.board[x + 2][y] == WALL:
            return True
        if self.board[x - 2][y] == WALL:
            return True
        if self.board[x][y + 2] == WALL:
            return True
        if self.board[x][y - 2] == WALL:
            return True
        return False

    def satisfy(self):
        boundary = 2
        startx = int(self.ncolumns * 0.15)
        starty = int(self.nrows * 0.15)

        endx = int(self.ncolumns * 0.85)
        endy = int(self.nrows * 0.85)

        # there should not wall
        for x in range(-boundary, boundary + 1):
            for y in range(-boundary, boundary + 1):
                temp_x = startx + x
                temp_y = starty + y

                temp_ex = endx + x
                temp_ey = endy + y

                if self.board[temp_x][temp_y] == WALL:
                    return False
                if self.board[temp_ex][temp_ey] == WALL:
                    return False
        return True

    def write_to_file(self, filename):
        f = open(filename, 'w')
        f.write(ascii_representation(self))
        f.close()

    @staticmethod
    def load_from_file(filename):
        with open(filename, 'r') as f:
            content = f.readlines()

        # remove whitespace characters like `\n` at the end of each line
        content = [x.strip() for x in content]

        xss = []
        for line in content:
            xs = []

            for c in line:
                if c == ' ':
                    xs.append(EMPTY)
                elif c == 'X':
                    xs.append(WALL)
                else:
                    raise ValueError('unexpected character found: ' + c)

            xss.append(xs)

        maze = Maze(len(xss), len(xss[0]))

        for xs in xss:
            assert len(xs) == maze.ncolumns

        for i in range(maze.nrows):
            for j in range(maze.ncolumns):
                if xss[i][j] == EMPTY:
                    maze.remove_wall(i, j)
                else:
                    maze.set_wall(i, j)

        return maze

    @staticmethod
    def complete_maze(rows, columns):
        maze = Maze(rows, columns)

        for i in range(rows):
            for j in range(columns):
                maze.board[i][j] = WALL

        return maze

    @staticmethod
    def create_maze(rows, columns, seed=None, complexity=.5, density=.2):

        while True:
            rows = (rows // 2) * 2 + 1
            columns = (columns // 2) * 2 + 1

            c_adjust = 1.2
            d_adjust = 0.8

            if seed is not None:
                np.random.seed(seed)

            # Adjust complexity and density relative to maze size
            comp = int(complexity * (c_adjust * (rows + columns)))
            dens = int(density * ((rows // 2) * (columns // 2)) * d_adjust)
            width = 2

            maze = Maze(rows, columns)
            maze.set_borders()

            # Make aisles
            for i in range(dens):
                maze.clear_temporal()
                x, y = rand(0, rows // 2) * 2, rand(0, columns // 2) * 2

                if maze.in_maze_inner(x, y):
                    if maze.wall_near(x, y):
                        continue

                maze.set_wall(x, y)

                for j in range(comp):
                    neighbours = []

                    if maze.in_maze(x - width, y):
                        neighbours.append((x - width, y))

                    if maze.in_maze(x + width, y):
                        neighbours.append((x + width, y))

                    if maze.in_maze(x, y - width):
                        neighbours.append((x, y - width))

                    if maze.in_maze(x, y + width):
                        neighbours.append((x, y + width))

                    if len(neighbours):
                        nx, ny = neighbours[rand(0, len(neighbours) - 1)]

                        # if not maze.is_temporal(nx, ny) and\
                        if not maze.is_wall(nx, ny):

                            if maze.wall_near(nx, ny):
                                maze.t_wall(nx, ny)
                                maze.t_wall(
                                    nx + (x - nx) // 2, ny + (y - ny) // 2)
                                x, y = nx, ny

                maze.temporal_to_wall()

            if maze.satisfy():
                break
            else:
                del maze
        return maze

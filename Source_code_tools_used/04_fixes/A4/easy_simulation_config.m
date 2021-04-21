%% Configuration file for quadrotor_swarm.m
%Enter simulation parameter values below
N = 100;         %number of agents
t0 = 0;         %initial time (s)
t_end = 1000;     %end time (s)
timer = 1;    %agent timer s(1) / S(1,j). Can be used to transition from initial state
dt = 5e-1;      %simulation time step (s)

%Try to keep values below unchanged
r_agent = 2;    %nearby agent detection/communication radius (m)
IR_angle = pi/4; %infrared proximity sensor angle
IR_dist = 2;    %infrared proximity sensor range (m)
target_radius = 1;    %radius of target(s)
v_max = 2;      %max quadcopter velocity (m/s)
d_max = v_max*dt; %maximum agent travel displacement per time step
% Check time step is sufficiently small:
if d_max >= IR_dist
    disp('Warning: time step too large, may cause agents to crash into obstacles')    
end
R_search = 0.02; %target search rate (/s)



%% Terrain/obstacle properties

map_type = 0;   % = 0 for standard map, = 1 for custom map

if map_type == 0;
        load easy_obstacles.mat;
    load easy_targets.mat;
    %load obstacles_standard.mat;  %rename as map_standard.mat or similar
    %load targets_standard.mat;
    map_size = 25;
else
    [map_size] = map_maker(1); 
    load easy_obstacles.mat;
    load easy_targets.mat;
end

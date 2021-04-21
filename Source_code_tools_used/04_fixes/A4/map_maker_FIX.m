function [ map_size ] = map_maker(blank)

close all;
clear all;

%% command prompt inputs: map size, number of obstacles, number of targets
display(' ');
display('*****Quadcopter swarm map maker*****');
map_size = input('Enter map dimension (m): ');
if isempty(map_size)
    map_size = 10;
end
number_obstacles = input('Enter number of obstacles: ');
if isempty(number_obstacles)
    number_obstacles = 1;
end
if number_obstacles == 0;
    number_obstacles = 1;
    display('Minimum number of obstacles = 1');
end

number_targets = input('Enter number of targets: ');
if isempty(number_targets)
    number_targets = 1;
end
if number_targets == 0;
    number_targets = 1;
    display('Minimum number of targets = 1');
end

display('Draw obstacles on Figure 1...');

%% create figure 1
figure(1);
axis equal;
axis([0 map_size 0 map_size]);
xlabel('x (m)');
ylabel('y (m)');
h1 = text(map_size/20,map_size/20,strcat('Obstacles drawn: 0/5'));
hold on;

%% Polygon creation
if number_obstacles ~= 0;

for i = 1:number_obstacles;
    set(h1, 'String', strcat('Obstacles drawn: ',num2str(i-1),'/',num2str(number_obstacles)));
    obs = impoly;
    obs = getPosition(obs);
    facecolour = zeros(1,size(obs,1));     
    patch(obs(:,1),obs(:,2),facecolour,'EdgeAlpha',0.2,'FaceColor','g','FaceAlpha',0.2);
    whitebg([1 1 1]);
    obs((1+size(obs,1)),1) = obs(1,1);
    obs((size(obs,1)),2) = obs(1,2);
    j = 2*i - 1;
    obstacles(1:size(obs,1),j) = {obs(:,1)}; 
    obstacles(1:size(obs,1),j+1) = {obs(:,2)};
       
end;

set(h1, 'String', strcat('Obstacles drawn: ',num2str(i),'/',num2str(number_obstacles)));

else
    obstacles = cell(1);
    set(h1, 'String', 'No obstacles');
end

save obstacles obstacles;


%% Add targets
if number_targets ~= 0;
    
display('Add targets to Figure 1...');
h2 = text(map_size/20,2*map_size/20,strcat('Targets added: '));
targets = zeros(2,number_targets);
for i = 1:number_targets;
    set(h2, 'String', strcat('Targets added: ',num2str(i-1),'/',num2str(number_targets)));
    [x,y] = ginput(1);
    plot(x,y,'xr');
    targets(1,i) = x;
    targets(2,i) = y;
end

set(h2, 'String', strcat('Targets added: ',num2str(i),'/',num2str(number_targets)));

save targets targets;

else
    targets = [];
    text(map_size/20,2*map_size/20,'No targets');
end

text(map_size/20,3*map_size/20,strcat('Finished'));

display('Obstacles saved as "obstacles.mat"');
display('Targets saved as "targets.mat"');
display(' ');
pause(2);
close all

end



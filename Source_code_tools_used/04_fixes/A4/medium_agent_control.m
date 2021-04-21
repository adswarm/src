function [ q  ] = agent_control(t,j,N,d_max,q,s,neighbour)

global Q;  %neighbouring agent state --> Q(1,neighbour)
global S;  %neighbouring agent sensor array --> S(1:11,neighbour)
a=1; % seconds of spreading out...
%   Detailed explanation goes here



%% State 0 - Move (initial)
if q(1) == 0;
    if t < s(1);    %Time in State 0
        theta = rand(1)*2*pi; dx = 0; dy = 0;
    else
        q(1) = 1;  %if t >= timer then transition to State 1 - Move (General)
        theta = s(5); dx = 0; dy = 0;
    end
    %% state 1 - movement
elseif q(1) == 1;
    
    % if target is near
    if s(6) == 1; %check sensor input: target detection
        q(1) = 2; %transition to State 2 (Enter target)
        theta = s(6); dx = 0; dy = 0;
    end
    
        %check for nearby agents searching targets, if so move into target!
    if s(9)==1 && Q(1,neighbour)==2
        theta = S(11,neighbour);
        d = S(10,neighbour);
    end
    
    % param_obst_danger = 0

    % obstacle avoidance
    if s(2) == 1 && s(3) ==1; %Check right + left hand ir sensor
        rand_num = rand(1); %in case there is a tight opening...
        if rand_num>0.10;
        theta = s(5)+pi;
        d = d_max*rand(1); %new translation magnitude
        end
        if rand_num<0.10 % 10 percent of the time the agent will just go for it!
            theta = s(5);
        d = d_max*rand(1); %new translation magnitude
        end
        % fix
        % if rand_num>0.00;
        % theta = s(5)+pi;
        % d = 0.01; %new translation magnitude
        % param_obst_danger = 1;
        % end
        % % if rand_num<0.10 % 10 percent of the time the agent will just go for it!
        % %     theta = s(5);
        % % d = d_max*rand(1); %new translation magnitude
        % end

        end
    end
    if s(2) ==1 && s(3) ==0; %check if object is to the right of fsa
        theta = s(5)+pi/6;
        d = d_max*rand(1); %new translation magnitude
    end
    if s(2) ==0 && s(3) ==1;
        theta = s(5)-pi/6;
        d = d_max*rand(1); %new translation magnitude
    end
    
    if s(2)==0 && s(3) ==0;
        if t<a;
        theta = s(5); %+ (rand(1)-0.5)*pi;	 %new agent angle [note use of current angle, stored in sensor array as s(5)]
        d = d_max;
        end
        if t>=a;
        theta =  s(5) + (rand(1)-0.5)*pi ;
        d = rand(1)*d_max;
        end
    end
    
%     d = d_max*rand(1); %new translation magnitude
    dx = cos(theta)*d; %x-component of new translation
    dy = sin(theta)*d; %y-component of new translation
    
    %% State 2 - Enter and search target
elseif q(1) == 2;
    if s(6) == 1;  %target detection = 1 (above/in target)
        theta = s(6); %theta = theta_target
        dx = 0; %stay in target
        dy = 0; %stay in target
    else  %Target detection = 1 (target search 100% completed)
        q(1) = 1; %transition back to State 1 Move (general)
        theta = s(6)+pi; dx = 0; dy = 0;
    end
end

%% State 3 - Crashed   (DO NOT CHANGE)
if q(1) == 3;
    theta = 0;
    dx = 0;
    dy = 0;
end

%% Update [x,y,theta] in agent j's state array q
q(4) = theta;        %insert new agent angle into state array
q(2) = dx + q(2);	%insert new global x position into state array
q(3) = dy + q(3);    %insert new global y position into state array













end


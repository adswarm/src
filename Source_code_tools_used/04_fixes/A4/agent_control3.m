function [ q  ] = agent_control(t,j,N,d_max,q,s,neighbour)
%AGENT_CONTROL: Finite State Automata in conditional form for the jth agent
%   function [ q ] = agent_control(t,j,N,d_max,q,s,neighbour)
% q is the state array for the jth agent = Q(:,j)
% s is the sensor array for the jth agent = S(:,j)
global Q;  %neighbouring agent state --> Q(1,neighbour)
global S;  %neighbouring agent sensor array --> S(1:11,neighbour)

%NOTES:
%Do not use absolute (x,y) values in calculations
%FSA state transitions achieved by changing q(1)
%Agent motion is controlled by generating dx, dy and theta values
%dx, dy and theta values are updated in q(2:4) at end of sub-function

%% State 0 - Move (initial)
if q(1) == 0;
    
    if rand(1)>0.3;
    q(1)=4;
    end
    
    
    if t < s(1);    %Time in State 0
        theta = rand(1); dx = 0; dy = 0;
    else
        q(1) = 1;  %if t >= timer then transition to State 1 - Move (General)
        theta = s(5); dx = 0; dy = 0;
    end
    
    
    
    
    %% State 1 - Move (general)
elseif q(1) == 1;
    

    
    if s(9)==1 && S(6,neighbour)>0
      q(1) = 2; 
    end
    
    
    if s(6) == 1; %check sensor input: target detection
        q(1) = 2; %transition to State 2 (Enter target)
        theta = s(6); dx = 0; dy = 0;
    end
    
    if s(2) == 1 && s(3) ==1; %Check right + left hand ir sensor
        theta = s(5)+pi;
    end
    if s(2) ==1 && s(3) ==0; %check if object is to the right of fsa
        theta = s(5)+pi/6;
    end
    if s(2) ==0 && s(3) ==1;
        theta = s(5)-pi/6;
    end
    
    if s(2)==0 && s(3) ==0;
        theta = s(5) + (rand(1)-0.5)*pi;	 %new agent angle [note use of current angle, stored in sensor array as s(5)]
    end
    
    d = d_max*rand(1); %new translation magnitude
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

    %% state 3?
      if q(1) == 4 && t < 5;    %Time in State 0
        theta = rand(1); dx = 0; dy = 0;
            d = d_max; %new translation magnitude
    dx = cos(theta)*d; %x-component of new translation
    dy = sin(theta)*d; %y-component of new translation
    else
        q(1) = 2;  %if t >= timer then transition to State 1 - Move (General)
        theta = s(5); dx = 0; dy = 0;
      end
     


    
    
%---------------  DO NOT ADD CODE BELOW HERE ---------------%

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
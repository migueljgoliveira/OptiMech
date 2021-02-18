% File Name: setting.m --------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% Description:  --------------------------+
% -----------------------------------------------------------------------------+

function [D,bounds_x,Best] = setting()
    % Number of Design Variables
    D = 7;
    % Search Range of Design Variables
    bound_x1 = [2.6 3.6];  % Face Width
    bound_x2 = [0.7 0.8];  % Module of Teeth
    bound_x3 = [17 29];    % Number of Teeth Pinion
    bound_x4 = [7.3 8.3]; % Lenght First Shaft
    bound_x5 = [7.8 8.3]; % Lenght Second Shaft
    bound_x6 = [2.9 3.9];  % Diameter First Shaft
    bound_x7 = [5.0 5.5];  % Diameter Second Shaft
    
    bounds_x = [bound_x1;bound_x2;bound_x3;bound_x4;bound_x5;bound_x6;bound_x7];
    
    Best = 2996.348165;
end

% END -------------------------------------------------------------------------+

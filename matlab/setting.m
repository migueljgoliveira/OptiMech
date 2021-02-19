% File Name: setting.m --------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% -----------------------------------------------------------------------------+

function [D,G,bounds_x,bounds_v] = setting()
    % Number of Design Variables
    D = 3;
    
    % Number of Constraints
    G = 0;
    
    % Search Range of Design Variables
    bound_x1 = [0 2];
    bound_x2 = [0 2];
    bound_x3 = [0 2];

    bounds_x = [bound_x1;bound_x2;bound_x3];
    
    % Velocity Range of Design Variables (only for PSO)
    bounds_v = zeros(D,2);
    for i = 1:D
        vmax = (bounds_x(i,2) - bounds_x(i,1))/2;
        vmin = - vmax;
        bound_v = [vmin vmax];
        bounds_v(i,:) = bound_v;
    end
end

% END -------------------------------------------------------------------------+

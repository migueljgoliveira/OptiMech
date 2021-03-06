% File Name: initial.m --------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation 
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% -----------------------------------------------------------------------------+

function x0 = initial(D,bounds_x)
    % Initial Values (X0,V0) of Design Variables
    x0 = zeros(1,D);
    for i = 1:D
        x0(i) = bounds_x(i,1) + rand()*(bounds_x(i,2) - bounds_x(i,1));
        if i == 3
            x0(i) = floor(x0(i));
        end
    end
end

% END -------------------------------------------------------------------------+

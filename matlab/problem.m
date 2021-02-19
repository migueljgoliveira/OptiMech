% File Name: problem.m --------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation 
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% -----------------------------------------------------------------------------+

% OBJECTIVE FUNCTION ----------------------------------------------------------+
function [F, x, Gj, P] = problem(x,i)
%     x(3) = floor(x(3));

    % UNCONSTRAINED OBJECTIVE FUNCTION
    f = sum(100.0*(x-x.^2).^2 + (1-x).^2);
    
    % CONSTRAINTS FUNCTION
    Gj = constraints(x);

    % PENALTY FUNCTION
    P = penalty(Gj,i);
    
    % CONSTRAINED OBJECTIVE FUNCTION
    F = f + P;
    
end

% CONSTRAINTS FUNCTION --------------------------------------------------------+
function Gj = constraints(x)
    % INEQUALITY CONSTRAINTS
	% g1 = ...
	% g2 = ...

	% Gj = [g1,...]
      Gj = 0;
end

% PENALTY FUNCTION ------------------------------------------------------------+
function P = penalty(Gj,i)
    C = 60;
    a = 2;
    B = 1;
    SVC = 0;
    for j = 1:length(Gj)
        if Gj(j) <= 0
            D = 0;
        else
            D = abs(Gj(j));
        end
        
        SVC = SVC + D^B;
    end
    P = ((C*i)^a)*SVC;    
end

% END -------------------------------------------------------------------------+

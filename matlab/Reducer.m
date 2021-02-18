% File Name: Reducer.m --------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation 
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% Description:  --------------------------+
% -----------------------------------------------------------------------------+

% OBJECTIVE FUNCTION ----------------------------------------------------------+
function [F, x, Gj, P] = Reducer(x,i)
    x(3) = floor(x(3));

    % UNCONSTRAINED OBJECTIVE FUNCTION
    f1 = 0.7854*x(1)*x(2)^2*( 3.3333*x(3)^2 + 14.9334*x(3) - 43.0934 );
    f2 = 1.508*x(1)*( x(6)^2 + x(7)^2 );
    f3 = 7.4777*( x(6)^3 + x(7)^3 );
    f4 = 0.7854*( x(4)*x(6)^2 + x(5)*x(7)^2 );
    f = f1 - f2 + f3 + f4;
    
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
    g1 = 27.0*( 1/(x(1)*x(2)^2*x(3)) ) - 1;
    g2 = 397.5*( 1/(x(1)*x(2)^2*x(3)^2)  ) - 1;
    g3 = 1.93*( x(4)^3/(x(2)*x(3)*x(6)^4) ) - 1;
    g4 = 1.93*( x(5)^3/(x(2)*x(3)*x(7)^4) ) - 1;
    g5 = ((1/(110.0*x(6)^3))*((745.0*x(4)/(x(2)*x(3)))^2+16.9e6)^(0.5)) - 1;
    g6 = ((1/(85.0*x(7)^3))*((745.0*x(5)/(x(2)*x(3)))^2+157.5e6)^(0.5)) - 1;
    g7 = x(2)*x(3)*(1/40) - 1;
    g8 = 5.0*(x(2)/x(1)) - 1;
    g9 = (1/12)*(x(1)/x(2)) - 1;
    g10 = (1/x(4))*(1.5*x(6)+1.9)  - 1;
    g11 = (1/x(5))*(1.1*x(7)+1.9) - 1;

    Gj = [g1 g2 g3 g4 g5 g6 g7 g8 g9 g10 g11];
end

% PENALTY FUNCTION ------------------------------------------------------------+
function P = penalty(Gj,i)
    C = 60;
    a = 2; % 1 or 2 good: a = 2 e B = 1
    B = 1; % 1 or 2
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

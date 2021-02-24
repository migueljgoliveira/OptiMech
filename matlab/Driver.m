% File Name: driver.m ---------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation 
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% -----------------------------------------------------------------------------+

function driver()
    clear; clc; close all;
    
    fprintf('+++ OptiMeta - Driver +++\n')
    
    x = [1.0 1.0 1.0];
    i = 1;
    
	[F, Gj, P] = problem(x,i);
    
	fprintf(['\nCost = ', num2str(F),'\n']) 
    fprintf(['Constraints = [',num2str(Gj),']\n'])
    fprintf(['Penalty = ',num2str(P),'\n'])
end

% END -------------------------------------------------------------------------+

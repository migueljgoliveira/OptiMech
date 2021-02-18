% File Name: Driver.m ---------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation 
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% Description:  --------------------------+
% -----------------------------------------------------------------------------+

function Driver()
    clear; clc; close all;
    
    fprintf('+++ SPEED REDUCER +++\n')
    
    x = [3.49999 0.6999 17 7.3 7.8 3.3502 5.2866];
    i = 1;
    
	[F, Gj, P] = Reducer(x,i);
    
	fprintf(['Cost = ', num2str(F),'\n']) 
    fprintf(['Constraints = [',num2str(Gj),']\n'])
    fprintf(['Penalty = ',num2str(P),'\n'])
end

% END -------------------------------------------------------------------------+

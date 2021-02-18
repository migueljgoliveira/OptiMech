% File Name: variables.m ------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation 
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% Description:  --------------------------+
% -----------------------------------------------------------------------------+

function [Evolution,EvolutionPosition,EvolutionConstraints,BestPosition,...
        EvolutionPenalty,BestCost,BestConstraint,BestPenalty,BestEval,...
        run_timer,evaluation_timer,process_timer,gens] = variables(runs,fe,ps,D)
    generations = ceil(fe/ps)-1;
    Evolution = zeros(runs,generations);
    EvolutionPosition = cell(1,runs);
    EvolutionConstraints = cell(1,runs);
    EvolutionPenalty = zeros(runs,generations);
	BestPosition = zeros(runs,D);
	BestCost = zeros(1,runs);
	BestConstraint = zeros(runs,11);
	BestPenalty = zeros(1,runs);
    BestEval = zeros(1,runs);
    gens = zeros(1,runs);
	run_timer = zeros(1,runs);
    evaluation_timer = zeros(1,runs);
    process_timer = zeros(1,runs);
end

% END -------------------------------------------------------------------------+

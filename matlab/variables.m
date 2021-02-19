% File Name: variables.m ------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation 
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% -----------------------------------------------------------------------------+

function [Evolution,EvolutionPosition,EvolutionConstraints,BestPosition,...
        EvolutionPenalty,BestCost,BestConstraint,BestPenalty,BestEval,...
        run_timer,gens] = variables(runs,fe,ps,D,G,algo)
    if strcmp(algo,'de')
        generations = ceil(fe/ps)-1;
    elseif strcmp(algo,'pso')
        generations = ceil(fe/ps);
    elseif strcmp(algo,'tlbo')
        generations = ceil(fe/(2*ps));
    end
    Evolution = zeros(runs,generations);
    EvolutionPosition = cell(1,runs);
    EvolutionConstraints = cell(1,runs);
    EvolutionPenalty = zeros(runs,generations);
	BestPosition = zeros(runs,D);
	BestCost = zeros(1,runs);
	BestConstraint = zeros(runs,G);
	BestPenalty = zeros(1,runs);
    BestEval = zeros(1,runs);
    gens = zeros(1,runs);
	run_timer = zeros(1,runs);
end

% END -------------------------------------------------------------------------+

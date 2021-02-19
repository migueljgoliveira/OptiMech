% File Name: result.m ---------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation 
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% -----------------------------------------------------------------------------+

function [Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,...
            BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,...
            run_timer,gens] = result(i,Evol,EvolPos,EvolCons,EvolPen,...
            Position_Best_g,Cost_Best_g,Constraint_Best_g,Penalty_Best_g,run_time,...
            Best_Eval,Evolution,EvolutionPosition,EvolutionConstraints,...
            EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,...
            BestEval,run_timer,gens,gen)
    % Append Number of Generations per Run
    gens(i) = gen;
    % Append Evaluation in which Best Cost was found
    BestEval(i) = Best_Eval;
    % Append Evolution Runs
	Evolution(i, :) = Evol;
    % Append Evolution of Position of Runs
	EvolutionPosition{i} =  EvolPos;
    % Append Evolution of Constraints of Runs
	EvolutionConstraints{i} =  EvolCons;
    % Append Evolution of Penalty Runs
	EvolutionPenalty(i, :) = EvolPen;
	% Append Best Position of runs
	BestPosition(i,:) = Position_Best_g;
	% Append Best Cost of runs
	BestCost(i) = Cost_Best_g;
	% Append Best Constraints of runs
	BestConstraint(i,:) = Constraint_Best_g;
	% Append Best Penalty of runs
	BestPenalty(i) = Penalty_Best_g;
	% Append elapsed time of runs
	run_timer(i) = run_time;
end

% END -------------------------------------------------------------------------+

% File Name: Run.m ------------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% Description:  --------------------------+
% -----------------------------------------------------------------------------+

% MAIN ------------------------------------------------------------------------+
function Run()
    close all; clear; clc;    
    fprintf('+++ OptiMech +++\n')
    
    % DE PARAMETERS SETTING ---------------------------------------------------+
    % Function Independent Parameters
    runs = 2; fe = 100000;
    
    % Function Dependent Parameters
    [D,bounds_x,Best] = setting();
    ps = 6*D;
    
    % Call 'variables' function
    [Evolution,EvolutionPosition,EvolutionConstraints,BestPosition,...
        EvolutionPenalty,BestCost,BestConstraint,BestPenalty,BestEval,...
        run_timer,gens] = variables(runs,fe,ps,D);
    
    % RUN ---------------------------------------------------------------------+
    total_start_time = tic;
    
    for i = 1:runs
        fprintf(['RUN ', num2str(i),' ...\n' ])
        % Starting Time of Run
        run_start_time = tic;
        
        % Call "SDE.m"
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        [Cost_Best_g,Position_Best_g,Constraint_Best_g,Penalty_Best_g,...
        Evol,EvolPos,EvolCons,EvolPen,gen,Best_Eval] = ...
        SDE(@Reducer,@initial,bounds_x,ps,D,fe,Best);
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        % Elapsed Time of Run
        run_time = toc(run_start_time);
        
        % Call 'result'
        [Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,...
            BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,...
            run_timer,gens] = result(i,Evol,EvolPos,EvolCons,EvolPen,...
            Position_Best_g,Cost_Best_g,Constraint_Best_g,Penalty_Best_g,run_time,...
            Best_Eval,Evolution,EvolutionPosition,EvolutionConstraints,...
            EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,...
            BestEval,run_timer,gens,gen);
    end
    
    total_time = toc(total_start_time);
    
    % Call PostProcessing
    PostProcessing(fe,ps,runs,gens,Best,Evolution,EvolutionPosition,EvolutionConstraints,...
        EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,...
        BestEval,run_timer,total_time);
end

% END -------------------------------------------------------------------------+

% File Name: main.m -----------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% -----------------------------------------------------------------------------+

% MAIN ------------------------------------------------------------------------+
function main()
    close all; clear; clc;    
    fprintf('+++ OptiMech +++\n')
    
    % GENERAL SETTINGS --------------------------------------------------------+
    algo = 'de';
    parallel = false;
    nproc = 2;
    
    % PARAMETERS SETTING ------------------------------------------------------+
    % Function Independent Parameters
    runs = 10; 
    fe = 1000;
    
    % Function Dependent Parameters
    [D,G,bounds_x,bounds_v] = setting();
    ps = 6*D;
    
    % Call 'variables' function
    [Evolution,EvolutionPosition,EvolutionConstraints,BestPosition,...
        EvolutionPenalty,BestCost,BestConstraint,BestPenalty,BestEval,...
        run_timer,gens] = variables(runs,fe,ps,D,G,algo);
    
    % RUN ---------------------------------------------------------------------+
    total_start_time = tic;
    
    % create pool processes
    if parallel
        pool = parpool(nproc);
    end
    
    for i = 1:runs
        fprintf(['RUN ', num2str(i),' ...\n' ])
        % Starting Time of Run
        run_start_time = tic;
        
        % DE
        if strcmp(algo,'de')
            [Cost_Best_g,Position_Best_g,Constraint_Best_g,Penalty_Best_g,...
                Evol,EvolPos,EvolCons,EvolPen,gen,Best_Eval] = ...
                de(@problem,@initial,bounds_x,ps,D,fe);
        % PSO
        elseif strcmp(algo,'pso')
            [Cost_Best_g,Position_Best_g,Constraint_Best_g,Penalty_Best_g,...
                Evol,EvolPos,EvolCons,EvolPen,gen,Best_Eval] = ...
                pso(@problem,@initial_pso,bounds_x,bounds_v,ps,D,fe,parallel);
        % TLBO
        elseif strcmp(algo,'tlbo')
            [Cost_Best_g,Position_Best_g,Constraint_Best_g,Penalty_Best_g,...
                Evol,EvolPos,EvolCons,EvolPen,gen,Best_Eval] = ...
                tlbo(@problem,@initial,bounds_x,ps,D,fe);
        end
        
        % Elapsed Time of Run
        run_time = toc(run_start_time);
        
        % Call 'result'
        [Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,...
            BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,...
            run_timer,gens] = result(i,Evol,EvolPos,EvolCons,EvolPen,...
            Position_Best_g,Cost_Best_g,Constraint_Best_g,Penalty_Best_g,...
            run_time,Best_Eval,Evolution,EvolutionPosition,...
            EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,...
            BestConstraint,BestPenalty,BestEval,run_timer,gens,gen);
    end
    
    if parallel
        delete(pool);
    end
    
    total_time = toc(total_start_time);
    
    % Call postprocessing
    postprocessing(D,G,fe,ps,runs,gens,Evolution,EvolutionPosition,...
        EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,...
        BestConstraint,BestPenalty,BestEval,run_timer,total_time);
end

% END -------------------------------------------------------------------------+

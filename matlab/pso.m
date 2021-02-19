% File Name: spso.m -----------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% -----------------------------------------------------------------------------+

function [Cost_Best_g,Position_Best_g,Constraint_Best_g,Penalty_Best_g,...
        Evol,EvolPos,EvolCons,EvolPen,gen,Best_Eval] = ...
        pso(costFunc,initial,bounds_x,bounds_v,ps,D,fe,parallel)
    
    Cost_Best_g = -1;       % Best Cost for Group
    Position_Best_g = [];   % Best Position for Group
    Constraint_Best_g = []; % Best Constraint for Group
    Penalty_Best_g = -1;    % Best Penalty for Group
    Best_Eval = 0;
    
    if parallel
        Swarm = cell(ps);
    else
        Swarm = {};
    end
    
    for i = 1:ps
        Swarm{i} = pso_particle(D,bounds_x,bounds_v,initial);
    end
    
    % Begin optimization Loop
    gen = 0;
    e = 0;
    Evol = [];
    EvolPos = [];
    EvolCon = [];
    EvolPen = [];
    
    while e ~= fe
           
        if parallel
            parfor j = 1:ps
                Swarm{j} = evaluate(Swarm{j},costFunc,gen+1);
            end
        else
            for j = 1:ps
                Swarm{j} = evaluate(Swarm{j},costFunc,gen+1);
            end
        end
        
        for j = 1:ps
            if e < fe               
                % determine if current particle is the best (globally)
                if Swarm{j}.Cost_Best_i < Cost_Best_g || Cost_Best_g == -1
                    Cost_Best_g = Swarm{j}.Cost_Best_i;
                    Position_Best_g = Swarm{j}.Position_Best_i;
                    Constraint_Best_g = Swarm{j}.Constraint_Best_i;
                    Penalty_Best_g = Swarm{j}.Penalty_Best_i;
                    Best_Eval = e;
                end
                
                e = e + 1;
            else
                break
            end
        end
        
        % cycle through swarm and update velocities and position
        for j = 1:ps
            Swarm{j} = update_velocity(Swarm{j},Position_Best_g,D,gen,fe/ps,bounds_v);
            Swarm{j} = update_position(Swarm{j},bounds_x,D);
        end
        
        fprintf(['\nGeneration: ',num2str(gen+1),'\n'])
        fprintf(['Evaluations: ',num2str(e),'\n'])
        fprintf(['Best Cost: ',num2str(Cost_Best_g),'\n'])
        fprintf(['Best Position: [',num2str(Position_Best_g),']\n'])
        fprintf(['Best Constraint: [',num2str(Constraint_Best_g),']\n'])
        fprintf(['Best Penalty: ',num2str(Penalty_Best_g),'\n'])
        
        Evol(gen+1) = Cost_Best_g;
        EvolPos(gen+1,:) = Position_Best_g;
        EvolCons(gen+1,:) = Constraint_Best_g;
        EvolPen(gen+1) = Penalty_Best_g;
        
        gen = gen + 1;
    end 
end

% END -------------------------------------------------------------------------+

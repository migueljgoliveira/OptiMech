% File Name: de.m -------------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% -----------------------------------------------------------------------------+

function [Cost_Best,Position_Best,Constraint_Best,Penalty_Best,...
        Evol,EvolPos,EvolCons,EvolPen,gen,Best_Eval] = de(costFunc,initial,bounds_x,ps,D,fe)
    
    Cost_Best = -1;       % Best Cost for Population
    Position_Best = [];   % Best Position for Population
    Constraint_Best = []; % Best Constraint for Population
    Penalty_Best = -1;    % Best Penalty for Population
    Best_Eval = 0;
    
    % Establish Population
    Population = {};
    for i = 1:ps
        Population{i} = de_individual(D,bounds_x,initial);
    end
    
    % cycle through individual in population and evaluate fitness
    e = 0;
    for j = 1:ps
        Population{j} = evaluate(Population{j},costFunc,1);
        
        e = e + 1;
    end
    
    % DE Parameters
    F = 0.5;    % Mutation Constant
    CR = 0.7;   % Crossover Probability
    
    % Begin optimization Loop
    gen = 0;
    e = ps;
    Evol = [];
    EvolPos = [];
    EvolCon = [];
    EvolPen = [];
   
    while e ~= fe
        % cycle through individual in population
        for j = 1:ps
            Target = Population{j};
            % 1. MUTATION ---------------------------------------------------- +
            % select three random index positions (except current target)
            Candidates = linspace(1,ps,ps);
            Candidates(j) = [];
            random_index = randperm(length(Candidates),3);
            
            % target vectors
            Target_1 = Population{random_index(1)};
            Target_2 = Population{random_index(2)};
            Target_3 = Population{random_index(3)};
            
            % generate mutant vector
            Mutant = de_individual(D,bounds_x,initial);
            
            Mutant.Position = Target_1.Position + F*(Target_2.Position - Target_3.Position);
            for n = 1:D                
                if Mutant.Position(n) < bounds_x(n,1)
                    Mutant.Position(n) = bounds_x(n,1);
                elseif Mutant.Position(n) > bounds_x(n,2)
                    Mutant.Position(n) = bounds_x(n,2);
                end
            end
            
            % 2. RECOMBINATION ----------------------------------------------- +
            Trial = de_individual(D,bounds_x,initial);
            for n = 1:D
                Crossover = rand();
                if Crossover <= CR
                    Trial.Position(n) = Mutant.Position(n);
                else
                    Trial.Position(n) = Target.Position(n);
                end
            end
            
            % 3. SELECTION --------------------------------------------------- +
            if e < fe
                Trial = evaluate(Trial,costFunc,i);
                e = e + 1;
                
                if Trial.Cost < Target.Cost
                    Population{j} = Trial;
                end
                
                if Population{n}.Cost < Cost_Best || Cost_Best == -1
                    Cost_Best = Population{n}.Cost;
                    Position_Best = Population{n}.Position;
                    Constraint_Best = Population{n}.Constraint;
                    Penalty_Best = Population{n}.Penalty;
                    Best_Eval = e;
                end
            else 
                break;
            end
        end
        
        fprintf(['\nGeneration: ',num2str(gen+1),'\n'])
        fprintf(['Evaluations: ',num2str(e),'\n'])
        fprintf(['Best Cost: ',num2str(Cost_Best),'\n'])
        fprintf(['Best Position: [',num2str(Position_Best),']\n'])
        fprintf(['Best Constraint: [',num2str(Constraint_Best),']\n'])
        fprintf(['Best Penalty: ',num2str(Penalty_Best),'\n'])
        
        Evol(gen+1) = Cost_Best;
        EvolPos(gen+1,:) = Position_Best;
        EvolCons(gen+1,:) = Constraint_Best;
        EvolPen(gen+1) = Penalty_Best;
        
        gen = gen + 1;
    end
end

% END -------------------------------------------------------------------------+

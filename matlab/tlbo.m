% File Name: tlbo.m -----------------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% Description:  --------------------------+
% -----------------------------------------------------------------------------+

function [Teacher_Cost,Teacher_Position,Teacher_Constraint,Teacher_Penalty,...
        Evol,EvolPos,EvolCons,EvolPen,gen,Best_Eval] = ...
        tlbo(costFunc,initial,bounds_x,ps,D,fe)
    
    Teacher_Cost = -1;          % Best Cost for Population
    Teacher_Position = [];      % Best Position for Population
    Teacher_Constraint = [];    % Best Constraint for Population
    Teacher_Penalty = -1;       % Best Penalty for Population
    Best_Eval = 0;
    
    evaluation_time = [];
    % Establish Population
    Population = {};
    e = 0;
    for i = 1:ps
        Population{i} = tlbo_learner(D,bounds_x,initial);
        
        Population{i} = evaluate(Population{i},costFunc,1);
        
        e = e + 1;
        
        % determine if current particle is the best (globally)
        if Population{i}.Cost < Teacher_Cost || Teacher_Cost == -1
            Teacher_Cost = Population{i}.Cost;
            Teacher_Position = Population{i}.Position;
            Teacher_Constraint = Population{i}.Constraint;
            Teacher_Penalty = Population{i}.Penalty;
        end
    end
    
    % Begin optimization Loop
    gen = 0;
    Evol = [];
    EvolPos = [];
    EvolCon = [];
    EvolPen = [];
    
    while e ~= fe
        % TEACHER PHASE -------------------------------------------------------+
        % calculate mean of each design variable (population)
        Mean_Variables = zeros(1,D);
        for j = 1:D
            for k = 1:ps
                Mean_Variables(j) = Mean_Variables(j) + Population{k}.Position(j);
            end
        end
        Mean_Variables = Mean_Variables/ps;
        
        Teacher_PositionGen = Teacher_Position;
        % modify solution based on teacher solution
        for i = 1:ps
            NewSolution = tlbo_learner(D,bounds_x,initial);
            
            Tf = randi([1 2]);
            r = rand(1,D);
            Difference_Mean = r.*(Teacher_PositionGen-Tf*Mean_Variables);
            
            % update position based of mean difference of solutions
            NewSolution.Position = Population{i}.Position + Difference_Mean;
            
            % adjust maximum and minimum position if necessary
            NewSolution = update_position(NewSolution,D,bounds_x);
            
            % evaluate new generated solution
            if e < fe                
                NewSolution = evaluate(NewSolution,costFunc,gen+1);
                
                e = e + 1;
                
                % is new solution better than existing?
                if NewSolution.Cost < Population{i}.Cost
                    Population{j}.Cost = NewSolution.Cost;
                    Population{j}.Position = NewSolution.Position;
                    Population{j}.Constraint = NewSolution.Constraint;
                    Population{j}.Penalty = NewSolution.Penalty;
                end
                
                if Population{i}.Cost < Teacher_Cost
                    Teacher_Cost = Population{i}.Cost;
                    Teacher_Position = Population{i}.Position;
                    Teacher_Constraint = Population{i}.Constraint;
                    Teacher_Penalty = Population{i}.Penalty;
                    Best_Eval = e;
                end
            else
                break;
            end
        end
        
        % LEARNER PHASE -------------------------------------------------------+
        SnapPopulation = Population;
        NewSolution = tlbo_learner(D,bounds_x,initial);
        for j = 1:ps
            % select one random solution
            Candidates = linspace(1,ps,ps);
            Candidates(j) = [];
            random_index = randperm(length(Candidates),1);
            % is current solution better than random
            r = rand(1,D);
            if SnapPopulation{j}.Cost < SnapPopulation{random_index}.Cost
                % generate new solution based on current and random
                NewSolution.Position = SnapPopulation{j}.Position + ...
                    r.*(SnapPopulation{j}.Position - SnapPopulation{random_index}.Position);
                % is random solution better than current?
            else
                % generate new solution based on current and random
                NewSolution.Position = SnapPopulation{j}.Position + ...
                    r.*(SnapPopulation{random_index}.Position - SnapPopulation{j}.Position);
            end
            
            % adjust maximum and minimum position if necessary
            NewSolution = update_position(NewSolution,D,bounds_x);
            
            % evaluate new generated solution
            if e < fe                
                NewSolution = evaluate(NewSolution,costFunc,gen+1);
                
                e = e + 1;
                
                % is new solution better than existing?
                if NewSolution.Cost < Population{j}.Cost
                    Population{j}.Cost = NewSolution.Cost;
                    Population{j}.Position = NewSolution.Position;
                    Population{j}.Constraint = NewSolution.Constraint;
                    Population{j}.Penalty = NewSolution.Penalty;
                end
                
                if Population{j}.Cost < Teacher_Cost
                    Teacher_Cost = Population{j}.Cost;
                    Teacher_Position = Population{j}.Position;
                    Teacher_Constraint = Population{j}.Constraint;
                    Teacher_Penalty = Population{j}.Penalty;
                    Best_Eval = e;
                end
            else
                break;
            end
            
        end
        
        % remove duplicates
        for j = 1:ps
            for k = j+1:ps
                if isequal(Population{j}.Position,Population{k}.Position)
                    Mutate = Population{k}.Position;
                    isNew = false;
                    while ~isNew
                        subject = randi(D);
                        if rand() > 0.5
                            Mutate(subject) = Mutate(subject) + (rand()*Mutate(subject));
                        else
                            Mutate(subject) = Mutate(subject) - (rand()*Mutate(subject));
                        end
                        
                        if Mutate(subject) > bounds_x(subject,2)
                            Mutate(subject) = bounds_x(subject,2);
                        elseif Mutate(subject) < bounds_x(subject,1)
                            Mutate(subject) = bounds_x(subject,1);
                        end
                        
                        for n = 1:ps
                            if ~isequal(Population{n}.Position,Mutate)
                                isNew = true;
                            end
                        end
                    end
                    Population{k}.Position = Mutate;
                end
            end
        end
        
        fprintf(['\nGeneration: ',num2str(gen+1),'\n'])
        fprintf(['Evaluations: ',num2str(e),'\n'])
        fprintf(['Best Cost: ',num2str(Teacher_Cost),'\n'])
        fprintf(['Best Position: [',num2str(Teacher_Position),']\n'])
        fprintf(['Best Constraint: [',num2str(Teacher_Constraint),']\n'])
        fprintf(['Best Penalty: ',num2str(Teacher_Penalty),'\n'])
        
        Evol(gen+1) = Teacher_Cost;
        EvolPos(gen+1,:) = Teacher_Position;
        EvolCons(gen+1,:) = Teacher_Constraint;
        EvolPen(gen+1) = Teacher_Penalty;
        
        gen = gen + 1;
    end
end

% END -------------------------------------------------------------------------+

% File Name: Individual.m -----------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% Description:  --------------------------+
% -----------------------------------------------------------------------------+

% INDIVIDUAL CLASS ------------------------------------------------------------+
classdef Individual
    properties
        Cost
        Position
        Constraint
        Penalty
    end
    methods
        function self = Individual(D,bounds_x,initial)
            
            self.Cost = -1;              % individual cost
            self.Position = [];          % individual position
            self.Constraint = [];        % individual constraints
            self.Penalty = -1;           % individual penalty
            
            self.Position = initial(D,bounds_x);
        end
        
        % evaluate current fitness
        function self = evaluate(self,costFunc,i)
            
            [self.Cost, self.Position, self.Constraint,self.Penalty] = costFunc(self.Position,i);
            
        end
        
    end
end

% END -------------------------------------------------------------------------+


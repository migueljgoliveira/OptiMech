% File Name: tlbo_learner.m ---------------------------------------------------+
% -----------------------------------------------------------------------------+
%
%   Miguel G. Oliveira
%   Dissertation
%   MSc in Mechanical Engineer
%   University of Aveiro
%
% Description:  --------------------------+
% -----------------------------------------------------------------------------+

% PARTICLE CLASS --------------------------------------------------------------+
classdef tlbo_learner
    properties
        Position
        Cost
        Constraint
        Penalty
    end
    methods
        function self = tlbo_learner(D,bounds_x,initial)
            self.Position = [];          % learner position
            self.Cost = -1;              % learner cost
            self.Constraint = [];        % learner constraint
            self.Penalty = -1;           % learner penalty
            
            self.Position = initial(D,bounds_x);
        end
        
        % evaluate current fitness
        function self = evaluate(self,costFunc,i)
            [self.Cost, self.Position, self.Constraint, self.Penalty] = costFunc(self.Position,i);
        end
        
        % update position based of bounds
        function self = update_position(self,D,bounds_x)
            for i = 1:D                
                if self.Position(i) > bounds_x(i,2)
                    self.Position(i) = bounds_x(i,2);
                elseif self.Position(i) < bounds_x(i,1)
                    self.Position(i) = bounds_x(i,1);
                end
            end
        end
    end
end

% END -------------------------------------------------------------------------+


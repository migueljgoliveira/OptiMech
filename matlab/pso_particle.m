% File Name: Particle.m -------------------------------------------------------+
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
classdef pso_particle
    properties
        Position_i
        Velocity_i
        Cost_i
        Position_Best_i
        Cost_Best_i
        Constraint_Best_i
        Constraint_i
        Penalty_i
        Penalty_Best_i
    end
    methods
        function self = pso_particle(D,bounds_x,bounds_v,initial)
            
            self.Position_i = [];          % particle position
            self.Velocity_i = [];          % particle velocity
            self.Cost_i = -1;              % cost individual
            self.Position_Best_i = [];     % best position individual
            self.Cost_Best_i = -1;         % best cost individual
            self.Constraint_Best_i = [];   % best cost individual contraints
            self.Constraint_i = [];        % constraints individual
            self.Penalty_i = -1;           % constraints individual
            self.Penalty_Best_i = -1;      % constraints individual
            
            [self.Position_i,self.Velocity_i] = initial(D,bounds_x,bounds_v);
            
        end
        
        % evaluate current fitness
        function self = evaluate(self,costFunc,i)
            [self.Cost_i, self.Position_i, self.Constraint_i,self.Penalty_i] = costFunc(self.Position_i,i);
            
            % check to see if the current position is an individual best
            if self.Cost_i < self.Cost_Best_i || self.Cost_Best_i == -1
                self.Cost_Best_i = self.Cost_i;
                self.Position_Best_i = self.Position_i;
                self.Constraint_Best_i = self.Constraint_i;
                self.Penalty_Best_i = self.Penalty_i;
            end
            
        end
        
        % update new particle velocity
        function self = update_velocity(self,Position_Best_g,D,i,maxiter,bounds_v)
            % linear decreasing weight
            w = (0.9-0.4)*((floor(maxiter)-i)/floor(maxiter)) + 0.4; 
            c1 = 2;        % cognitive Constant
            c2 = 2;        % social constant
            r1 = rand(1,D);
            r2 = rand(1,D);
            
            Velocity_Cognitive = c1*r1.*(self.Position_Best_i - self.Position_i);
            Velocity_Social = c2*r2.*(Position_Best_g - self.Position_i);
            self.Velocity_i = w*self.Velocity_i + Velocity_Cognitive + Velocity_Social;
            
            % adjust maximum and minimum velocity if necessary
            for i = 1:D    
                if self.Velocity_i(i) > bounds_v(i,2)
                    self.Velocity_i(i) = bounds_v(i,2);
                elseif self.Velocity_i(i) < bounds_v(i,1)
                    self.Velocity_i(i) = bounds_v(i,1);
                end
            end
        end
        
        % update the particle position based off new velocity updates
        function self = update_position(self,bounds_x,D)
            self.Position_i = self.Position_i + self.Velocity_i;
            
            % adjust maximum and minimum position if necessary
            for i = 1:D                
                if self.Position_i(i) > bounds_x(i,2)
                    self.Position_i(i) = bounds_x(i,2);
                elseif self.Position_i(i) < bounds_x(i,1)
                    self.Position_i(i) = bounds_x(i,1);
                end
            end
        end
    end
end

% END -------------------------------------------------------------------------+


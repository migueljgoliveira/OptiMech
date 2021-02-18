# File Name: pso.py ----------------------------------------------------------+
# ----------------------------------------------------------------------------+
#
#   Miguel G. Oliveira
#   Dissertation
#   MSc in Mechanical Engineer
#   University of Aveiro
#
# ----------------------------------------------------------------------------+

# IMPORT PACKAGES ------------------------------------------------------------+
import random
import time
import numpy as np
import multiprocessing as mp
from functools import partial

# MAIN -----------------------------------------------------------------------+

# PROXY ----------------------------------------------------------------------+
def proxy(gg, costf, i):
    return gg.evaluate(costf, i)

# PARTICLE CLASS -------------------------------------------------------------+
class Particle:
    def __init__(self,D,bounds_x,bounds_v,initial):
        self.Position_i = []          # particle position
        self.Velocity_i = []          # particle velocity
        self.Cost_i = -1              # cost individual
        self.Position_Best_i = []     # best position individual
        self.Cost_Best_i = -1         # best cost individual
        self.Constraint_Best_i = []   # best cost individual contraints
        self.Constraint_i = []        # constraints individual
        self.Penalty_i = -1           # penalty individual
        self.Penalty_Best_i = -1      # penalty best individual

        self.Position_i,self.Velocity_i = initial(D,bounds_x,bounds_v)

    # evaluate current fitness
    def evaluate(self,costFunc,i):
        self.Cost_i, self.Position_i, self.Constraint_i, self.Penalty_i = costFunc(self.Position_i,i)

        # check to see if the current position is an individual best
        if self.Cost_i < self.Cost_Best_i or self.Cost_Best_i == -1:
            self.Position_Best_i = list(self.Position_i)
            self.Cost_Best_i = float(self.Cost_i)
            self.Constraint_Best_i = list(self.Constraint_i)
            self.Penalty_Best_i = float(self.Penalty_i)

        return self

    # update new particle velocity
    def update_velocity(self,Position_Best_g,D,i,maxiter,bounds_v):
    	# linear decreasing weight
    	w = (0.9-0.4)*((np.trunc(maxiter)-i)/np.trunc(maxiter))+0.4
    	c1 = 2        # cognitive Constant
    	c2 = 2        # social constant

    	for i in range(0,D):
    		r1 = random.random()
    		r2 = random.random()

    		Velocity_Cognitive = c1*r1*(self.Position_Best_i[i] - self.Position_i[i])
    		Velocity_Social = c2*r2*(Position_Best_g[i] - self.Position_i[i])

    		self.Velocity_i[i] = w*self.Velocity_i[i] + Velocity_Cognitive + Velocity_Social

    		# adjust maximum and minimum velocity if necessary
    		if self.Velocity_i[i] > bounds_v[i][1]:
    			self.Velocity_i[i] = bounds_v[i][1]
    		elif self.Velocity_i[i] < bounds_v[i][0]:
    			self.Velocity_i[i] = bounds_v[i][0]

    # update the particle position based off new velocity updates
    def update_position(self,bounds_x,D):
        for i in range(0,D):
            self.Position_i[i] = self.Position_i[i] + self.Velocity_i[i]

            # adjust maximum and minimum position if necessary
            if self.Position_i[i] > bounds_x[i][1]:
                self.Position_i[i] = bounds_x[i][1]
            elif self.Position_i[i] < bounds_x[i][0]:
                self.Position_i[i] = bounds_x[i][0]

# SWARM CLASS ----------------------------------------------------------------+
def pso(costFunc,initial,bounds_x,bounds_v,ps,D,fe,parallel,pool):
    Cost_Best_g = -1       # Best Cost for Group
    Position_Best_g = []   # Best Position for Group
    Constraint_Best_g = [] # Best Constraint for Group
    Penalty_Best_g = -1	   # Best Penalty for Group
    Best_Eval = 0

    # Establish Swarm
    Swarm = []
    for i in range(0,ps):
        Swarm.append(Particle(D,bounds_x,bounds_v,initial))

    # Begin optimization Loop
    gen = 0
    e = 0
    Evol = []
    EvolPos = []
    EvolCons = []
    EvolPen = []

    evaluation_time = []

    while e != fe:
        # parallel processing
        if parallel == True:
            swarm = pool.map_async(partial(proxy,costf=costFunc,i=gen+1),Swarm)
            Swarm = swarm.get()
        else:
            for j in range(0,ps):
                Swarm[j].evaluate(costFunc,gen+1)

        # cycle through particles in swarm and evaluate fitness
        for j in range(0,ps):
            if e < fe:
                # determine if current particle is the best (globally)
                if Swarm[j].Cost_Best_i < Cost_Best_g or Cost_Best_g == -1:
                    Position_Best_g = list(Swarm[j].Position_Best_i)
                    Cost_Best_g = float(Swarm[j].Cost_Best_i)
                    Constraint_Best_g = list(Swarm[j].Constraint_Best_i)
                    Penalty_Best_g = float(Swarm[j].Penalty_Best_i)
                    Best_Eval = e

                e += 1
            else:
                break

        # cycle through swarm and update velocities and position
        for j in range(0,ps):
            Swarm[j].update_velocity(Position_Best_g,D,gen+1,fe/ps,bounds_v)
            Swarm[j].update_position(bounds_x,D)

        print ("\nGeneration: %r" % (gen+1))
        print ("Function Evaluations: %r" % e)
        print ("Best Cost: %r" % Cost_Best_g)
        print ("Best Position: %r" % Position_Best_g)
        print ("Constraint: %r" % Constraint_Best_g)
        print ("Penalty: %r" % Penalty_Best_g)

        Evol.append(Cost_Best_g)
        EvolPos.append(Position_Best_g)
        EvolCons.append(Constraint_Best_g)
        EvolPen.append(Penalty_Best_g)

        gen += 1

    return Cost_Best_g,Position_Best_g,Constraint_Best_g,Penalty_Best_g,Evol,EvolPos,EvolCons,EvolPen,gen,Best_Eval

# END ----------------------------------------------------------------------+
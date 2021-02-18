# File Name: de.py -----------------------------------------------------------+
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

# MAIN -----------------------------------------------------------------------+

# INDIVIDUAL CLASS -----------------------------------------------------------+
class Individual:
    def __init__(self,D,bounds_x,initial):
        self.Cost = -1              # individual cost
        self.Position = []          # individual position
        self.Constraint = []        # individual constraints
        self.Penalty = -1           # individual penalty

        self.Position = initial(D,bounds_x)

    # evaluate current fitness
    def evaluate(self,costFunc,i):
        self.Cost,self.Position,self.Constraint,self.Penalty = costFunc(self.Position,i)

        return self

# POPULATION CLASS -----------------------------------------------------------+
def de(costFunc,initial,bounds_x,ps,D,fe):
    Cost_Best = -1       	# Best Cost for Population
    Position_Best = []   	# Best Position for Population
    Constraint_Best = [] 	# Best Constraint for Population
    Penalty_Best = -1	    # Best Penalty for Population
    Best_Eval = 0

    # Establish Population
    e = 0
    Population = []
    for j in range(0,ps):
        Population.append(Individual(D,bounds_x,initial))

        # cycle through individual in population and evaluate fitness
        Population[j].evaluate(costFunc,1)

        e += 1

    # DE Parameters
    F = 0.5		# Mutation Constant
    CR = 0.7 	# Crossover Probability

    # Begin optimization Loop
    gen = 0
    Evol = []
    EvolPos = []
    EvolCons = []
    EvolPen = []

    while e != fe:
        # cycle through individual in population
        for j in range(0,ps):
            Target = Population[j]
            # 1. MUTATION --------------------------------------------------- +
            # select three random index positions (except current target)
            Candidates = [n for n in range(0, ps)]
            Candidates.remove(j)
            random_index = random.sample(Candidates, 3)

            # target vectors
            Target_1 = Population[random_index[0]]
            Target_2 = Population[random_index[1]]
            Target_3 = Population[random_index[2]]

            # generate mutant vector
            Mutant = Individual(D,bounds_x,initial)
            for n in range(D):
                Mutant.Position[n] = Target_1.Position[n] + F*(Target_2.Position[n] - Target_3.Position[n])
                # adjust maximum and minimum position if necessary
                if Mutant.Position[n] < bounds_x[n][0]:
                    Mutant.Position[n] = bounds_x[n][0]
                elif Mutant.Position[n] > bounds_x[n][1]:
                    Mutant.Position[n] = bounds_x[n][1]

            # 2. RECOMBINATION ---------------------------------------------- +
            Trial = Individual(D,bounds_x,initial)
            for n in range(D):
                Crossover = random.random()
                if Crossover <= CR:
                    Trial.Position[n] = Mutant.Position[n]
                else:
                    Trial.Position[n] = Target.Position[n]

            # 3. SELECTION -------------------------------------------------- +
            if e < fe:
                Trial.evaluate(costFunc,gen+1)

                e += 1

                if Trial.Cost < Target.Cost:
                    Population[j].Cost = float(Trial.Cost);
                    Population[j].Position = list(Trial.Position);
                    Population[j].Constraint = list(Trial.Constraint);
                    Population[j].Penalty = float(Trial.Penalty);

                if Population[j].Cost < Cost_Best or Cost_Best == -1:
                    Cost_Best = float(Population[j].Cost)
                    Position_Best = list(Population[j].Position)
                    Constraint_Best = list(Population[j].Constraint)
                    Penalty_Best = float(Population[j].Penalty)
                    Best_Eval = e

            else:
                break

        print ("\nGeneration: %r" % (gen+1))
        print ("Function Evaluations: %r" % e)
        print ("Best Cost: %r" % Cost_Best)
        print ("Best Position: %r" % Position_Best)
        print ("Constraint: %r" % Constraint_Best)
        print ("Penalty: %r" % Penalty_Best)

        Evol.append(Cost_Best)
        EvolPos.append(Position_Best)
        EvolCons.append(Constraint_Best)
        EvolPen.append(Penalty_Best)

        gen += 1

    return Cost_Best,Position_Best,Constraint_Best,Penalty_Best,Evol,EvolPos,EvolCons,EvolPen,gen,Best_Eval

# END ----------------------------------------------------------------------+
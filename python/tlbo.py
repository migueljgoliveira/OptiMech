# File Name: tlbo.py ---------------------------------------------------------+
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

# LEARNER CLASS --------------------------------------------------------------+
class Learner:
    def __init__(self,D,bounds_x,initial):
        self.Position = []          # learner position
        self.Cost = -1              # learner cost
        self.Constraint = []        # learner constraint
        self.Penalty = -1           # learner penalty

        self.Position = initial(D,bounds_x)

    # evaluate current fitness
    def evaluate(self,costFunc,i):
        self.Cost,self.Position,self.Constraint,self.Penalty = costFunc(self.Position,i)

    # adjust maximum and minimum position if necessary
    def update_position(self,D,bounds_x):
        for j in range(0,D):
            if self.Position[j] > bounds_x[j][1]:
                self.Position[j] = bounds_x[j][1]
            elif self.Position[j] < bounds_x[j][0]:
                self.Position[j] = bounds_x[j][0]

# POPULATION CLASS -----------------------------------------------------------+
def tlbo(costFunc,initial,bounds_x,ps,D,fe):
    Teacher_Cost = -1          # Best Cost for Population
    Teacher_Position = []      # Best Position for Population
    Teacher_Constraint = []    # Best Constraint for Population
    Teacher_Penalty = -1       # Best Penalty for Population
    Best_Eval = 0

    # Establish Population
    Population = []
    e = 0
    for j in range(0,ps):
        Population.append(Learner(D,bounds_x,initial))

        Population[j].evaluate(costFunc,1)

        e += 1

        if Population[j].Cost < Teacher_Cost or Teacher_Cost == -1:
            Teacher_Cost = float(Population[j].Cost)
            Teacher_Position = list(Population[j].Position)
            Teacher_Constraint = list(Population[j].Constraint)
            Teacher_Penalty = float(Population[j].Penalty)

    # Begin optimization Loop
    gen = 0
    Evol = []
    EvolPos = []
    EvolCons = []
    EvolPen = []

    while e != fe:
        # TEACHER PHASE ------------------------------------------------------+
        # calculate mean of each design variable (population)
        Mean_Variables = np.zeros(D)
        for j in range(0,D):
            for k in range(0,ps):
                Mean_Variables[j] += Population[k].Position[j]
        Mean_Variables = Mean_Variables/ps
        Teacher_PositionGen = Teacher_Position

        # modify solution based on teacher solution
        for i in range(0,ps):
            NewSolution = Learner(D,bounds_x,initial)

            Tf = round(1+random.random()*(2-1))
            r = np.random.rand(1,D)
            Difference_Mean = np.zeros(D)

            for j in range(0,D):
                Difference_Mean[j] = r[0][j]*(Teacher_PositionGen[j]-Tf*Mean_Variables[j])

            # update position based of mean difference of solutions
            for j in range(0,D):
                NewSolution.Position[j] = Population[i].Position[j] + Difference_Mean[j]

            # adjust maximum and minimum position if necessary
            NewSolution.update_position(D,bounds_x)

            # evaluate new generated solution
            if e < fe:
                NewSolution.evaluate(costFunc,gen+1)

                e += 1

                # is new solution better than existing?
                if NewSolution.Cost < Population[i].Cost:
                    Population[i].Cost = float(NewSolution.Cost)
                    Population[i].Position = list(NewSolution.Position)
                    Population[i].Constraint = list(NewSolution.Constraint)
                    Population[i].Penalty = float(NewSolution.Penalty)

                if Population[i].Cost < Teacher_Cost:
                    Teacher_Cost = float(Population[i].Cost)
                    Teacher_Position = list(Population[i].Position)
                    Teacher_Constraint = list(Population[i].Constraint)
                    Teacher_Penalty = float(Population[i].Penalty)
                    Best_Eval = e
            else:
                break

        # LEARNER PHASE ------------------------------------------------------+
        SnapPopulation = Population
        NewSolution = Learner(D,bounds_x,initial)
        for j in range(0,ps):
            # select one random solution
            Candidates = [n for n in range(0, ps)]
            Candidates.remove(j)
            random_index = random.choice(Candidates)
            # is current solution better than random?
            r = np.random.rand(1,D)
            if SnapPopulation[j].Cost < SnapPopulation[random_index].Cost:
                for k in range(0,D):
                    # generate new solution based on current and random
                    NewSolution.Position[k] = SnapPopulation[j].Position[k] + r[0][k]*(SnapPopulation[j].Position[k] - SnapPopulation[random_index].Position[k])
            # is random solution better than current?
            else:
                for k in range(0,D):
                    # generate new solution based on current and random
                    NewSolution.Position[k] = SnapPopulation[j].Position[k] + r[0][k]*(SnapPopulation[random_index].Position[k] - SnapPopulation[j].Position[k])

            # adjust maximum and minimum position if necessary
            NewSolution.update_position(D,bounds_x)

            # evaluate new generated solution
            if e < fe:
                NewSolution.evaluate(costFunc,gen+1)

                e += 1

                # if new solution is better replace in population
                if NewSolution.Cost < SnapPopulation[j].Cost:
                    Population[j].Cost = float(NewSolution.Cost)
                    Population[j].Position = list(NewSolution.Position)
                    Population[j].Constraint = list(NewSolution.Constraint)
                    Population[j].Penalty = float(NewSolution.Penalty)

                if Population[j].Cost < Teacher_Cost:
                    Teacher_Cost = float(Population[j].Cost)
                    Teacher_Position = list(Population[j].Position)
                    Teacher_Constraint = list(Population[j].Constraint)
                    Teacher_Penalty = float(Population[j].Penalty)
                    Best_Eval = e
            else:
                break

        # remove Duplicates
        for j in range(0,ps-1):
            for k in range(j+1,ps):
                if np.array_equal(Population[j].Position, Population[k].Position):
                    Mutate = Population[k].Position
                    isNew = False
                    while not isNew:
                        subject = random.randint(0, D-1)
                        if random.random() > 0.5:
                            Mutate[subject] = Mutate[subject] + (random.random()*Mutate[subject])
                        else:
                            Mutate[subject] = Mutate[subject] - (random.random()*Mutate[subject])
                        if Mutate[subject] > bounds_x[subject][1]:
                            Mutate[subject] = bounds_x[subject][1]
                        elif Mutate[subject] < bounds_x[subject][0]:
                            Mutate[subject] = bounds_x[subject][0]

                        for n in range(0,ps):
                            if not np.array_equal(Population[n].Position, Mutate):
                                isNew = True

                    Population[k].Position = list(Mutate)

        print ("\nGeneration: %r" % (gen+1))
        print ("Function Evaluations: %r" % e)
        print ("Best Cost: %r" % Teacher_Cost)
        print ("Best Position: %r" % Teacher_Position)
        print ("Constraint: %r" % Teacher_Constraint)
        print ("Penalty: %r" % Teacher_Penalty)

        Evol.append(Teacher_Cost)
        EvolPos.append(Teacher_Position)
        EvolCons.append(Teacher_Constraint)
        EvolPen.append(Teacher_Penalty)

        gen += 1

    return Teacher_Cost,Teacher_Position,Teacher_Constraint,Teacher_Penalty,Evol,EvolPos,EvolCons,EvolPen,gen,Best_Eval

# END ----------------------------------------------------------------------+
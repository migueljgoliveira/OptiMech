# File Name: main.py --------------------------------------------------------+
# ---------------------------------------------------------------------------+
#
#   Miguel G. Oliveira
#   Dissertation
#   MSc in Mechanical Engineer
#   University of Aveiro
#
# ---------------------------------------------------------------------------+

# IMPORT PACKAGES -----------------------------------------------------------+
import time
import os
import multiprocessing as mp

# IMPORT FILES --------------------------------------------------------------+
from de import de
from pso import pso
from tlbo import tlbo
from problem import setting, costfunc, initial, initial_pso
from postprocessing import variables, result, post, write, visual

# MAIN ----------------------------------------------------------------------+
def main():
	print ('+++ OptiMech +++')

	# GENERAL SETTINGS ------------------------------------------------------+
	algo = 'tlbo'
	parallel = False
	nproc = 2

	# PARAMETERS SETTING ----------------------------------------------------+
	# Function Independent Parameters
	runs = 2
	fe = 20000

	# Function Dependent Parameters
	D,bounds_x,bounds_v = setting()
	ps = 10*D

	#Call 'variables' function from PostProcessing
	Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,run_timer,gens = variables()

	# RUN -------------------------------------------------------------------+
	total_start_time = time.time()

	# create pool of processes
	pool = None
	if parallel == True:
		pool = mp.Pool(processes=nproc)

	for i in range(0, runs):
		print('RUN %r ...' %(i+1))
		# Starting Time of Run
		run_start_time = time.time()

		# DE
		if algo == 'de':
			Cost_Best_g,Position_Best_g,Constraint_Best_g,Penalty_Best_g,Evol,EvolPos,EvolCons,EvolPen,gen,Best_Eval = de(costfunc,initial,bounds_x,ps,D,fe)
		# PSO
		elif algo == 'pso':
			Cost_Best_g,Position_Best_g,Constraint_Best_g,Penalty_Best_g,Evol,EvolPos,EvolCons,EvolPen,gen,Best_Eval = pso(costfunc,initial_pso,bounds_x,bounds_v,ps,D,fe,parallel,pool)
		# TLBO
		elif algo == 'tlbo':
			Cost_Best_g,Position_Best_g,Constraint_Best_g,Penalty_Best_g,Evol,EvolPos,EvolCons,EvolPen,gen,Best_Eval = tlbo(costfunc,initial,bounds_x,ps,D,fe)

		# Elapsed Time of Run
		run_time = time.time() - run_start_time

		process_start_time = time.time_ns()
		# Call 'result' function from PostProcessing
		Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,run_timer,gens = result(i,Evol,EvolPos,EvolCons,EvolPen,Position_Best_g,Cost_Best_g,Constraint_Best_g,Penalty_Best_g,run_time,Best_Eval,Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,run_timer,gens,gen)

	if parallel == True:
		pool.close()
		pool.join()

	total_time = time.time() - total_start_time

	# Call 'post' function from PostProcessing
	Evolution,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,WorstCost,mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,mean_run_timer,Evol_X,Evol_G,gen = post(Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,run_timer,total_time,runs,gens)

	#Call 'write' function from PostProcessing
	write(gen,fe,ps,runs,Evolution,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,WorstCost,mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,mean_run_timer,total_time,Evol_X,Evol_G)

	# Call 'visual' function from PostProcessing
	visual(BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,WorstCost,mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,Evolution,EvolutionPenalty,Evol_X,Evol_G,mean_run_timer,total_time,gen,fe)

if __name__ == "__main__":
	main()

# END ------------------------------------------------------------------------+
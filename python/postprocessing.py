# File Name: PostProcessing.py -----------------------------------------------+
# ----------------------------------------------------------------------------+
#
#   Miguel G. Oliveira
#   Dissertation
#   MSc in Mechanical Engineer
#   University of Aveiro
#
# ----------------------------------------------------------------------------+

# IMPORT PACKAGES ------------------------------------------------------------+
import time
import numpy as np
import matplotlib.pyplot as plt

# VARIABLES ------------------------------------------------------------------+
def variables():
	Evolution = []
	EvolutionPosition = []
	EvolutionConstraints = []
	EvolutionPenalty = []
	BestPosition = []
	BestCost = []
	BestConstraint = []
	BestPenalty = []
	BestEval = []
	gens = []
	run_timer = []

	return Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,run_timer,gens

# EXTRACT RESULTS ------------------------------------------------------------+
def result(i,Evol,EvolPos,EvolCons,EvolPen,Position_Best_g,Cost_Best_g,Constraint_Best_g,Penalty_Best_g,run_time,Best_Eval,Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,run_timer,gens,gen):
	# Append Number of Generations per Run
	gens.append(gen)
	# Append Evaluation in which Best Cost was found
	BestEval.append(Best_Eval)
	# Append Evolution Runs
	Evolution.append(Evol)
	# Append Evolution of Position of Runs
	EvolutionPosition.append(EvolPos)
	# Append Evolution of Constraints of Runs
	EvolutionConstraints.append(EvolCons)
	# Append Evolution of Penalty of Runs
	EvolutionPenalty.append(EvolPen)
	# Append Best Position of runs
	BestPosition.extend([Position_Best_g])
	# Append Best Cost of runs
	BestCost.extend([Cost_Best_g])
	# Append Best Constraints of runs
	BestConstraint.extend([Constraint_Best_g])
	# Append Best Penalty of runs
	BestPenalty.extend([Penalty_Best_g])
	# Append elapsed time of runs
	run_timer.extend([run_time])

	return Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,run_timer,gens

# POST-PROCESSING ------------------------------------------------------------+
def post(Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,run_timer,total_time,runs,gens):

	# Run in which Best Cost was found
	BestCost_i = np.argmin(BestCost)
	# Mean Evaluations to Best Solutions
	mean_BestEval = 0
	count = 0
	snapBestEval = []
	for j in range(0,runs):
		if BestEval[j] > 0:
			mean_BestEval += BestEval[j]
			snapBestEval.append(BestEval[j])
			count += 1
	if mean_BestEval > 0:
		mean_BestEval = mean_BestEval/count
		# Standard Deviation of Best Solutions Evaluations
		std_BestEval = np.std(snapBestEval)
		# Evaluations in which Best Solution
		BestEval = np.amin(snapBestEval)
	else:
		mean_BestEval = 0
		std_BestEval = 0
		BestEval = 0
	# Best Position for Best Cost
	BestPosition = BestPosition[BestCost_i]
	# Constraints for Best Cost
	BestConstraint = BestConstraint[BestCost_i]
	# Penalty for Best Cost
	BestPenalty = BestPenalty[BestCost_i]
	# Mean of Best Cost of all runs
	mean_BestCost = np.mean(BestCost)
	# Standard Deviation of Best Cost
	std_BestCost = np.std(BestCost)
	# Worst Cost of all runs
	WorstCost = np.amax(BestCost)
	# Best Cost of all runs
	BestCost = np.amin(BestCost)
	# Maximum Generations
	gen = max(gens)
	# Evolution Mean for X Runs
	NewEvolution = np.zeros(gen)
	count = np.zeros(gen)
	for i in range(0,runs):
		for j in range(0,len(Evolution[i])):
			NewEvolution[j] += Evolution[i][j]
			count[j] += 1
	Evolution = np.zeros(gen)
	for i in range(0,gen):
		Evolution[i] = NewEvolution[i]/count[i]
	# Evolution of Design Variables
	nEvol_X = np.zeros(shape=(gen, len(EvolutionPosition[0][0])))
	for i in range(0,runs):
		for j in range(0,gen):
			for k in range(0,len(EvolutionPosition[0][0])):
				nEvol_X[j][k] += EvolutionPosition[i][j][k]
	Evol_X = np.zeros(shape=(len(EvolutionPosition[0][0]),gen))
	for i in range(0,gen):
		for j in range(0,len(EvolutionPosition[0][0])):
			Evol_X[j][i] = nEvol_X[i][j]/runs
	# Evolution of Constraints
	nEvol_G = np.zeros(shape=(gen, len(EvolutionConstraints[0][0])))
	for i in range(0,runs):
		for j in range(0,gen):
			for k in range(0,len(EvolutionConstraints[0][0])):
				nEvol_G[j][k] += EvolutionConstraints[i][j][k]
	Evol_G = np.zeros(shape=(len(EvolutionConstraints[0][0]),gen))
	for i in range(0,gen):
		for j in range(0,len(EvolutionConstraints[0][0])):
			Evol_G[j][i] = nEvol_G[i][j]/runs
	# Evolution Penalty Mean of Runs
	NewEvolution = np.zeros(gen)
	for i in range(0,runs):
		for j in range(0,len(EvolutionPenalty[i])):
			NewEvolution[j] += EvolutionPenalty[i][j]
	EvolutionPenalty = np.zeros(gen)
	for i in range(0,gen):
		EvolutionPenalty[i] = NewEvolution[i]/count[i]
	# Mean Time of Run
	mean_run_timer = np.mean(run_timer)

	return Evolution,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,WorstCost,mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,mean_run_timer,Evol_X,Evol_G,gen

# WRITE TO FILES -------------------------------------------------------------+
def write(gen,fe,ps,runs,Evolution,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,WorstCost,mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,mean_run_timer,total_time,Evol_X,Evol_G):
	today = time.strftime("%Y-%m-%d %H:%M")
	
	filename = "Results.txt"
	Evol_X = np.array(Evol_X).T.tolist()
	Evol_G = np.array(Evol_G).T.tolist()
	with open(filename,"w") as file:
		file.write('\n' +'Date:' + repr(today) + '\n')
		file.write('\n' + '+++ PARAMETERS +++' + '\n\n')
		file.write('Runs: ' + repr(runs) + '\n')
		file.write('Generations: ' + repr(gen) + '\n')
		file.write('Function Evaluations: ' + repr(fe) + '\n')
		file.write('Population Size: ' + repr(ps) + '\n')
		file.write('\n' + '+++ COST EVOLUTION +++' + '\n\n')
		for i in range(0,len(Evolution)):
			file.write(('%.6f' % Evolution[i]) + '\n')
		file.write('\n' + '+++ DESIGN VARIABLES EVOLUTION +++' + '\n\n')
		np.savetxt(file,Evol_X,fmt = '%0.6f')
		file.write('\n' + '+++ CONSTRAINTS EVOLUTION +++' + '\n\n')
		np.savetxt(file,Evol_G,fmt = '%0.6f')
		file.write('\n' + '+++ PENALTY EVOLUTION +++' + '\n\n')
		for i in range(0,gen):
			file.write(('%.6f' % EvolutionPenalty[i]) +'\n')
		file.write(('\n' + '+++ FINAL RESULTS +++' + '\n\n'))
		file.write(('Best Position: %r' % BestPosition) + '\n')
		file.write(('Best Cost: %.6f' % BestCost) + '\n')
		file.write(('Constraints: %r' % BestConstraint) + '\n')
		file.write(('Penalty: %.6f' % BestPenalty) + '\n')
		file.write(('Worst Cost: %.6f' % WorstCost) + '\n')
		file.write(('Mean Best Cost: %.6f' % mean_BestCost) + '\n')
		file.write(('Std. Best Cost: %.6f' % std_BestCost) + '\n')
		file.write(("Evaluations: %r" % BestEval) + '\n')
		file.write(("Mean Evaluations: %r" % mean_BestEval) + '\n')
		file.write(("Std. Evaluations: %r" % std_BestEval) + '\n')
		file.write(('Mean Run Time: %r sec' % mean_run_timer) + '\n')
		file.write(('Total Time: %r sec' % total_time) + '\n')
		file.write('\n' + '+++++++++++++++++++++++++++++++++++++++++++' + '\n')

# VISUALISATION --------------------------------------------------------------+
def visual(BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,WorstCost,mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,Evolution,EvolutionPenalty,Evol_X,Evol_G,mean_run_timer,total_time,gen,fe):

	print ("\n + --------- FINAL RESULTS --------- + \n")
	print ("Best Position: %r" % BestPosition)
	print ("Best Cost: %.6f" % BestCost)
	print ("Constraints: %r" % BestConstraint)
	print ("Penalty: %.6f" % BestPenalty)
	print ("Worst Cost: %.6f" % WorstCost)
	print ("Mean Best Cost: %.6f" % mean_BestCost)
	print ("Std. Best Cost: %.6f" % std_BestCost)
	print ("Evaluations: %r" % BestEval)
	print ("Mean Evaluations: %r" % mean_BestEval)
	print ("Std. Evaluations: %r" % std_BestEval)
	print ("Mean Run Time: %r sec" % mean_run_timer)
	print ("Total Time: %r sec" % total_time)
	print ("\nOptimization Complete! See Results :) \n")

	Evals = np.linspace(1,fe,gen)
	# Create cost evolution plot
	fig1 = plt.figure()
	plt.plot(Evals,Evolution)
	plt.ylabel('Cost')
	plt.xlabel('Function Evaluations')
	plt.xlim(1,fe)
	plt.grid(True)
	plt.savefig('Cost.png')
	plt.close(fig1)

	# Create variables evolution plot
	fig2 = plt.figure()
	for i in range(0,len(Evol_X)):
		plt.plot(Evals,Evol_X[i],ms=1)
	plt.ylabel('Design Variables')
	plt.xlabel('Function Evaluations')
	plt.xlim(1,fe)
	plt.grid(True)
	plt.savefig('Variables.png')
	plt.close(fig2)

# END ------------------------------------------------------------------------+
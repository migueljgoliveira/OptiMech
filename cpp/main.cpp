// File Name: main.cpp -------------------------------------------------------+
// ---------------------------------------------------------------------------+
//  Miguel G. Oliveira
//  Dissertation
//  MSc in Mechanical Engineer
//  University of Aveiro
//
// ---------------------------------------------------------------------------+

// IMPORT PACKAGES -----------------------------------------------------------+
#include <iostream>
#include <iomanip>
#include <math.h>
#include <vector>
#include <tuple>
#include <chrono>
#include <time.h>
#include <fstream>
#include <sstream>
using namespace std;
using namespace chrono;

// IMPORT FILES --------------------------------------------------------------+
#include "problem.cpp"
#include "de.cpp"
#include "pso.cpp"
#include "tlbo.cpp"
#include "postprocessing.cpp"

// MAIN ----------------------------------------------------------------------+
int main() {
	double cost_Best,penalty_Best;
	vector<double> evol,evolPen,position_Best,constraint_Best;
	vector<vector<double>> evolPos,evolCons;
	vector<long double> evaluation_time;
	int e,gen,best_Eval;
	srand(time(0));

	cout << "+++ OptiMeta +++" << endl;

	string algo = "tlbo";

	// DE PARAMETERS SETTING ------------------------------------------------+
	// Function Independent Parameters
	int runs = 1;
	int fe = 1000;

	// # Function Dependent Parameters
	int D;
	vector< vector<double> > bounds_x;
	vector< vector<double> > bounds_v;
	setting(D,bounds_x,bounds_v);
	int ps = 6*D;

	//Call 'variables' function from PostProcessing
	auto vars = variables(runs,fe,ps);
	auto Evolution = get<0>(vars);
	auto EvolutionPosition = get<1>(vars);
	auto EvolutionConstraints = get<2>(vars);
	auto EvolutionPenalty = get<3>(vars);
	auto BestCost = get<4>(vars);
	auto BestPosition = get<5>(vars);
	auto BestConstraint = get<6>(vars);
	auto BestPenalty = get<7>(vars);
	auto BestEval = get<8>(vars);
	auto gens = get<9>(vars);
	auto run_timer = get<10>(vars);

	// RUN -------------------------------------------------------------------+
	auto total_start_time = clock();

	for (int i = 0; i < runs; ++i)
	{
		cout << "Run " << i + 1<< "..." << endl;
		// Starting Time of Run
		auto run_start_time = clock();

		// DE
		if (algo == "de")
		{
			DE(bounds_x,ps,D,fe,cost_Best,position_Best,constraint_Best,penalty_Best,best_Eval,evol,evolPos,evolCons,evolPen,e,gen);
		} 
		// PSO
		else if (algo == "pso")
		{
			PSO(bounds_x,bounds_v,ps,D,fe,cost_Best,position_Best,constraint_Best,penalty_Best,best_Eval,evol,evolPos,evolCons,evolPen,e,gen);
		} 
		// TLBO
		else if (algo == "tlbo")
		{
			TLBO(bounds_x,ps,D,fe,cost_Best,position_Best,constraint_Best,penalty_Best,best_Eval,evol,evolPos,evolCons,evolPen,e,gen);
		}

		// Elapsed Time of Run
		auto run_time = clock() - run_start_time;

		// Call 'result' function from PostProcessing
		result(i,Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,evol,evolPos,evolCons,evolPen,cost_Best,position_Best,constraint_Best,penalty_Best,best_Eval,run_time,BestCost,BestPosition,BestConstraint,BestPenalty,BestEval,run_timer,gens,gen);

	}

	auto total_timer = clock() - total_start_time;

	// Call 'post' function from PostProcessing
	auto pos = post(Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,run_timer,total_timer,runs,gens);

	auto evolution = get<0>(pos);
	auto evolutionPenalty = get<1>(pos);
	auto bestCost = get<2>(pos);
	auto bestPosition = get<3>(pos);
	auto bestConstraint = get<4>(pos);
	auto bestPenalty = get<5>(pos);
	auto bestEval = get<6>(pos);
	auto worstCost = get<7>(pos);
	auto mean_BestCost = get<8>(pos);
	auto mean_BestEval = get<9>(pos);
	auto std_BestCost = get<10>(pos);
	auto std_BestEval = get<11>(pos);
	auto mean_run_time = get<12>(pos);
	auto total_Time = get<13>(pos);
	auto Evol_X = get<14>(pos);
	auto Evol_G = get<15>(pos);
	gen = get<16>(pos);

	// Call 'write' function from PostProcessing
	write(gen,fe,ps,runs,evolution,evolutionPenalty,bestPosition,bestCost, bestConstraint,bestPenalty,bestEval,worstCost,mean_BestCost,mean_BestEval, std_BestCost,std_BestEval,mean_run_time,total_Time,Evol_X,Evol_G);

	// Call 'visual' function from PostProcessing
	visual(bestCost,bestPosition,bestConstraint,bestPenalty,bestEval, mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,worstCost,  mean_run_time,total_Time);

	return 0;
}

// END -----------------------------------------------------------------------+
// File Name: postprocessing.cpp ---------------------------------------------+
// ---------------------------------------------------------------------------+
//
//  Miguel G. Oliveira
//  Dissertation
//  MSc in Mechanical Engineer
//  University of Aveiro
//
// ---------------------------------------------------------------------------+

// VARIABLES -----------------------------------------------------------------+
tuple< vector<vector<double>>,vector<vector<vector<double>>>,vector<vector<vector<double>>>,vector<vector<double>>,vector<double>,vector<vector<double>>,vector<vector<double>>,vector<double>,vector<int>,vector<int>,vector<long double> > variables(int runs,int fe, int ps)
{
	int generations = floor(fe/ps);
	vector<vector<double>> Evolution(runs,vector<double>(generations+1,0.0));
	vector<vector<vector<double>>> EvolutionPosition(runs*(generations+1));
	vector<vector<vector<double>>> EvolutionConstraints(runs*(generations+1));
	vector<vector<double>> EvolutionPenalty(runs,vector<double>(generations+1,0.0));
	vector<double> BestCost(runs,0.0);
	vector<vector<double>> BestPosition(runs);
	vector<vector<double>> BestConstraint(runs);
	vector<double> BestPenalty(runs,0.0);
	vector<int> BestEval(runs,0);
	vector<int> gens(runs,0);
	vector<long double> run_timer(runs,0.0);

  	return make_tuple(Evolution,EvolutionPosition,EvolutionConstraints,EvolutionPenalty,BestCost,BestPosition,BestConstraint,BestPenalty,BestEval,gens,run_timer);
};

// EXTRACT RESULTS -----------------------------------------------------------+
void result(int i,vector<vector<double>> &Evolution,vector<vector<vector<double>>> &EvolutionPosition,vector<vector<vector<double>>> &EvolutionConstraints,vector<vector<double>> &EvolutionPenalty,vector<double> evol,vector<vector<double>> evolPos,vector<vector<double>> evolCons,vector<double> evolPen,double cost_Best_g,vector<double> position_Best_g,vector<double> constraint_Best_g,double penalty_Best_g,int best_Eval,long run_time,vector<double> &BestCost,vector<vector<double>> &BestPosition,vector<vector<double>> &BestConstraint,vector<double> &BestPenalty,vector<int> &BestEval,vector<long double> &run_timer,vector<int> &gens,int gen)
{
	// Append Number of Generations per Run
	gens[i] = gen;
	// Append Evaluation i  which Best Cost was found
	BestEval[i] = best_Eval;
	// Append Evolution Runs
	for (int j = 0; j < evol.size(); ++j)
	{
		Evolution[i][j] = evol[j];
	}
	// Append Evolution of Position of Runs
	EvolutionPosition[i] = evolPos;
	// Append Evolution of Constraints of Runs
	EvolutionConstraints[i] = evolCons;
	// Append Evolution of Penalty of Runs
	for (int j = 0; j < evolPen.size(); ++j)
	{
		EvolutionPenalty[i][j] = evolPen[j];
	}
	// Append Best Position of runs
	BestPosition[i] = position_Best_g;
	// Append Best Cost of runs
	BestCost[i] = cost_Best_g;
	// Append Best Constraints of runs
	BestConstraint[i] = constraint_Best_g;
	// Append Best Penalty of runs
	BestPenalty[i] = penalty_Best_g;
	// Append elapsed time of runs
	run_timer[i] = run_time/(long double)CLOCKS_PER_SEC;
};

// POST-PROCESSING -----------------------------------------------------------+
tuple<vector<double>,vector<double>,double,vector<double>,vector<double>,double,double,double,double,double,double,double,long double,long double,vector<vector<double>>,vector<vector<double>>,int> post(vector<vector<double>> Evolution,vector<vector<vector<double>>> EvolutionPosition,vector<vector<vector<double>>> EvolutionConstraints,vector<vector<double>> EvolutionPenalty,vector<vector<double>> BestPosition,vector<double> BestCost,vector<vector<double>> BestConstraint,vector<double> BestPenalty,vector<int> BestEval,vector<long double> run_timer,long double total_timer,int runs,vector<int> gens)
{
	double bestCost,bestEval,bestPenalty,mean_BestCost,std_BestCost,worstCost,mean_BestEval,std_BestEval,sd,min;
	vector<double> bestPosition,bestConstraint;
	int count;
	vector<int> snapBestEval;

	// Best Cost of all Runs
	min = BestCost[0];
	int BestCost_i = 0;
	for (int i = 1; i < BestCost.size(); ++i)
	{
		if (BestCost[i] < min)
		{
			min = BestCost[i];
			BestCost_i = i;
		}
	}
	bestCost = min;
	// Mean Evaluations to Best Solutions
	mean_BestEval = 0;
	count = 0;
	snapBestEval = {};
	for (int j = 0; j < runs; ++j) {
		if (BestEval[j] > 0) {
			mean_BestEval += BestEval[j];
			snapBestEval.push_back(BestEval[j]);
			count ++;
		}
	}
	if (mean_BestEval > 0) {
		mean_BestEval = mean_BestEval/count;
		// Standard Deviation of Best Solutions Evaluations
		if (count == 1) {
			std_BestEval = 0;
		} else {
			sd = 0.0;
			for (int i = 0; i < snapBestEval.size(); ++i) {
				sd += pow(snapBestEval[i] - mean_BestEval,2)/snapBestEval.size();
			}
			std_BestEval = sqrt(sd);
		}
		// Evaluations in which Best Solution
		min = snapBestEval[0];
		for (int i = 1; i < snapBestEval.size(); ++i) {
			if (snapBestEval[i] < min) {
				min = snapBestEval[i];
			}
		}
		bestEval = min;
	} else {
		mean_BestEval = 0;
		std_BestEval = 0;
		bestEval = 0;
	}
	// Best Position for Best Cost
	bestPosition = BestPosition[BestCost_i];
	// Constraints for Best Cost
	bestConstraint = BestConstraint[BestCost_i];
	// Penalty for Best Cost
	bestPenalty = BestPenalty[BestCost_i];
	// Mean of Best Cost of all runs
	double sum = 0.0;
	for (int i = 0; i < BestCost.size(); ++i) {
		sum += BestCost[i];
	}
	mean_BestCost = sum/BestCost.size();
	// Standard Deviation of Best Cost
	sd = 0.0;
	for (int i = 0; i < BestCost.size(); ++i) {
		sd += pow(BestCost[i] - mean_BestCost,2)/BestCost.size();
	}
	std_BestCost = sqrt(sd);
	// Worst Cost of all runs
	double max = BestCost[0];
	for (int i = 1; i < BestCost.size(); ++i) {
		if (BestCost[i] > max) {
			max = BestCost[i];
		}
	}
	worstCost = max;
	// Evolution Mean for X Runs
	int gen = gens[0];
	vector<double> evolution(gen,0.0);
	for (int it = 0; it < gen; ++it) {
		for (int r = 0; r < runs; ++r) {
			evolution[it] += Evolution[r][it];
		}
	}
	for (int i = 0; i < evolution.size(); ++i) {
		evolution[i] = evolution[i]/runs;
	}
	// Evolution of Design Variables
	vector<vector<double>> evol_X1(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_X2(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_X3(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_X4(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_X5(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_X6(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_X7(runs,vector<double>(gen,0.0));
	for (int i = 0; i < runs; ++i) {
		for (int j = 0; j < gen; ++j) {
			evol_X1[i][j] = EvolutionPosition[i][j][0];
			evol_X2[i][j] = EvolutionPosition[i][j][1];
			evol_X3[i][j] = EvolutionPosition[i][j][2];
			evol_X4[i][j] = EvolutionPosition[i][j][3];
			evol_X5[i][j] = EvolutionPosition[i][j][4];
			evol_X6[i][j] = EvolutionPosition[i][j][5];
			evol_X7[i][j] = EvolutionPosition[i][j][6];
		}
	}
	vector<double> Evol_X1(gen,0.0);
	vector<double> Evol_X2(gen,0.0);
	vector<double> Evol_X3(gen,0.0);
	vector<double> Evol_X4(gen,0.0);
	vector<double> Evol_X5(gen,0.0);
	vector<double> Evol_X6(gen,0.0);
	vector<double> Evol_X7(gen,0.0);
	for (int i = 0; i < gen; ++i) {
		for (int j = 0; j < runs; ++j) {
			Evol_X1[i] += evol_X1[j][i];
			Evol_X2[i] += evol_X2[j][i];
			Evol_X3[i] += evol_X3[j][i];
			Evol_X4[i] += evol_X4[j][i];
			Evol_X5[i] += evol_X5[j][i];
			Evol_X6[i] += evol_X6[j][i];
			Evol_X7[i] += evol_X7[j][i];
		}
	}
	for (int i = 0; i < gen; ++i) {
		Evol_X1[i] = Evol_X1[i]/runs;
		Evol_X2[i] = Evol_X2[i]/runs;
		Evol_X3[i] = Evol_X3[i]/runs;
		Evol_X4[i] = Evol_X4[i]/runs;
		Evol_X5[i] = Evol_X5[i]/runs;
		Evol_X6[i] = Evol_X6[i]/runs;
		Evol_X7[i] = Evol_X7[i]/runs;
	}
	vector<vector<double>> Evol_X{Evol_X1,Evol_X2,Evol_X3,Evol_X4,Evol_X5,Evol_X6,Evol_X7};
	// Evolution of Constraints
	vector<vector<double>> evol_G1(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_G2(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_G3(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_G4(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_G5(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_G6(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_G7(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_G8(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_G9(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_G10(runs,vector<double>(gen,0.0));
	vector<vector<double>> evol_G11(runs,vector<double>(gen,0.0));
	for (int i = 0; i < runs; ++i) {
		for (int j = 0; j < gen; ++j) {
			evol_G1[i][j] = EvolutionConstraints[i][j][0];
			evol_G2[i][j] = EvolutionConstraints[i][j][1];
			evol_G3[i][j] = EvolutionConstraints[i][j][2];
			evol_G4[i][j] = EvolutionConstraints[i][j][3];
			evol_G5[i][j] = EvolutionConstraints[i][j][4];
			evol_G6[i][j] = EvolutionConstraints[i][j][5];
			evol_G7[i][j] = EvolutionConstraints[i][j][6];
			evol_G8[i][j] = EvolutionConstraints[i][j][7];
			evol_G9[i][j] = EvolutionConstraints[i][j][8];
			evol_G10[i][j] = EvolutionConstraints[i][j][9];
			evol_G11[i][j] = EvolutionConstraints[i][j][10];
		}
	}
	vector<double> Evol_G1(gen,0.0);
	vector<double> Evol_G2(gen,0.0);
	vector<double> Evol_G3(gen,0.0);
	vector<double> Evol_G4(gen,0.0);
	vector<double> Evol_G5(gen,0.0);
	vector<double> Evol_G6(gen,0.0);
	vector<double> Evol_G7(gen,0.0);
	vector<double> Evol_G8(gen,0.0);
	vector<double> Evol_G9(gen,0.0);
	vector<double> Evol_G10(gen,0.0);
	vector<double> Evol_G11(gen,0.0);
	for (int i = 0; i < gen; ++i) {
		for (int j = 0; j < runs; ++j) {
			Evol_G1[i] += evol_G1[j][i];
			Evol_G2[i] += evol_G2[j][i];
			Evol_G3[i] += evol_G3[j][i];
			Evol_G4[i] += evol_G4[j][i];
			Evol_G5[i] += evol_G5[j][i];
			Evol_G6[i] += evol_G6[j][i];
			Evol_G7[i] += evol_G7[j][i];
			Evol_G8[i] += evol_G8[j][i];
			Evol_G9[i] += evol_G9[j][i];
			Evol_G10[i] += evol_G10[j][i];
			Evol_G11[i] += evol_G11[j][i];
		}
	}
	for (int i = 0; i < gen; ++i) {
		Evol_G1[i] = Evol_G1[i]/runs;
		Evol_G2[i] = Evol_G2[i]/runs;
		Evol_G3[i] = Evol_G3[i]/runs;
		Evol_G4[i] = Evol_G4[i]/runs;
		Evol_G5[i] = Evol_G5[i]/runs;
		Evol_G6[i] = Evol_G6[i]/runs;
		Evol_G7[i] = Evol_G7[i]/runs;
		Evol_G8[i] = Evol_G8[i]/runs;
		Evol_G9[i] = Evol_G9[i]/runs;
		Evol_G10[i] = Evol_G10[i]/runs;
		Evol_G11[i] = Evol_G11[i]/runs;
	}
	vector<vector<double>> Evol_G{Evol_G1,Evol_G2,Evol_G3,Evol_G4,Evol_G5,Evol_G6,Evol_G7,Evol_G8,Evol_G9,Evol_G10,Evol_G11};
	// Evolution Penalty Mean for X Runs
	vector<double> evolutionPenalty(gen,0.0);
	for (int it = 0; it < gen; ++it) {
		for (int r = 0; r < runs; ++r) {
			evolutionPenalty[it] += EvolutionPenalty[r][it];
		}
	}
	for (int i = 0; i < evolutionPenalty.size(); ++i) {
		evolutionPenalty[i] = evolutionPenalty[i]/runs;
	}
	// Mean/Total Time of all runs
	long double sum1 = 0.0;
	for (int i = 0; i < run_timer.size(); ++i)
	{
		sum1 += run_timer[i];
	}
	long double run_time = sum1;
	long double mean_run_time = run_time/run_timer.size();
	// Total Time
	long double total_time = total_timer/(long double)CLOCKS_PER_SEC;

  	return make_tuple(evolution,evolutionPenalty,bestCost,bestPosition,bestConstraint,bestPenalty,bestEval,worstCost,mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,mean_run_time,total_time,Evol_X,Evol_G,gen);
};

// WRITE TO FILE -------------------------------------------------------------+
void write(int gen,int fe,int ps,int runs,vector<double> evolution,vector<double> evolutionPenalty,vector<double> bestPosition,double bestCost,vector<double> bestConstraint,double bestPenalty,double bestEval,double worstCost,double mean_BestCost,double mean_BestEval,double std_BestCost,double std_BestEval,long double mean_run_time,long double total_Time,vector<vector<double>> Evol_X,vector<vector<double>> Evol_G)
{
	time_t rawtime;
  	struct tm * timeinfo;
  	char date[80];
  	time (&rawtime);
  	timeinfo = localtime (&rawtime);

  	strftime (date,80,"%F %T",timeinfo);

	ofstream file;
  	file.open ("Results.txt",ios::app);
  	file << "\nDate: " << date << "\n";
  	file << "\n +++ PARAMETERS +++ \n\n";
  	file << "Runs: " << runs << "\n";
  	file << "Generations: " << gen << "\n";
  	file << "Function Evaluations: " << fe << "\n";
  	file << "Population Size: " << ps << "\n";
  	file << "\n +++ COST EVOLUTION +++ \n\n";
  	for (int i = 0; i < gen; ++i){
  		file << setprecision(6) << fixed <<  evolution[i] << "\n";
  	}
  	file << "\n +++ DESIGN VARIABLES EVOLUTION +++ \n";
  	file << "\n * X1 * \n\n";
  	for (int i = 0; i < gen; ++i){file << setprecision(6) << fixed << Evol_X[0][i] << "\n";}
  	file << "\n * X2 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_X[1][i] << "\n"; }
  	file << "\n * X3 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_X[2][i] << "\n"; }
  	file << "\n * X4 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_X[3][i] <<  "\n"; }
  	file << "\n * X5 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_X[4][i] << "\n"; }
  	file << "\n * X6 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_X[5][i] << "\n"; }
  	file << "\n * X7 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_X[6][i] << "\n"; }
  	file << "\n +++ CONSTRAINTS EVOLUTION +++ \n";
  	file << "\n * G1 * \n\n";
  	for (int i = 0; i < gen; ++i){ file << setprecision(6) << fixed << Evol_G[0][i] << "\n"; }
  	file << "\n * G2 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_G[1][i] << "\n"; }
  	file << "\n * G3 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_G[2][i] << "\n"; }
  	file << "\n * G4 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_G[3][i] <<  "\n"; }
  	file << "\n * G5 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_G[4][i] << "\n"; }
  	file << "\n * G6 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_G[5][i] << "\n"; }
  	file << "\n * G7 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_G[6][i] << "\n"; }
  	file << "\n * G8 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_G[7][i] << "\n"; }
  	file << "\n * G9 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_G[8][i] << "\n"; }
  	file << "\n * G10 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_G[9][i] << "\n"; }
  	file << "\n * G11 * \n\n";
  	for (int i = 0; i < gen; ++i)
  	{ file << setprecision(6) << fixed << Evol_G[10][i] << "\n"; }
 	file << "\n +++ PENALTY EVOLUTION +++ \n\n";
  	for (int i = 0; i < gen; ++i){
  		file << setprecision(6) << fixed <<  evolutionPenalty[i] << "\n";
  	}
  	file << "\n +++ FINAL RESULTS +++ \n\n";
  	file << "Best Position: [ ";
	for (int i = 0; i < bestPosition.size(); ++i)
	{ file << setprecision(6) << fixed << bestPosition[i] << " "; }
	file << "\nBest Cost: " << setprecision(6) << fixed << bestCost <<"\n";
	file << "Constraints: [ ";
	for (int i = 0; i < bestConstraint.size(); ++i)
	{ file << setprecision(6) << fixed <<  bestConstraint[i] << " "; }
	file << "\nPenalty: " << setprecision(6) << fixed <<  bestPenalty <<"\n";
	file << "Worst Cost: " << setprecision(6) << fixed << worstCost <<"\n";
	file << "Mean Best Cost: " << setprecision(6) << fixed << mean_BestCost <<"\n";
	file << "Std. Best Cost: " << setprecision(6) << fixed << std_BestCost <<"\n";
	file << "Evaluations: " << setprecision(0) << fixed << bestEval <<" %\n";
	file << "Mean Evaluations: " << setprecision(6) << fixed << mean_BestEval <<" %\n";
	file << "Std. Evaluations: " << setprecision(6) << fixed << std_BestEval <<" %\n";
	file << "Mean Run Time: " << setprecision(6) << fixed << mean_run_time <<"\n";
	file << "Total Time: " << setprecision(6) << fixed << total_Time <<"\n";
	file << "\n ++++++++++++++++++++++++++++++++++++++++++++\n";

  	file.close();
};

// VISUALISATION -------------------------------------------------------------+
void visual(double bestCost,vector<double> bestPosition,vector<double> bestConstraint,double bestPenalty,double bestEval,double mean_BestCost,double mean_BestEval,double std_BestCost,double std_BestEval,double worstCost,long double mean_run_time,long double total_Time)
{
	cout << "\n+ --------- FINAL RESULTS --------- + \n" << endl;
	cout << "Best Position: [ ";
	for (int i = 0; i < bestPosition.size(); ++i)
	{ cout << setprecision(6) << fixed << bestPosition[i] << " "; }
	cout << "]" << endl;
	cout << "Best Cost: " << setprecision(6) << fixed << bestCost << endl;
	cout << "Constraints: [ ";
	for (int i = 0; i < bestConstraint.size(); ++i)
	{ cout << setprecision(6) << fixed <<bestConstraint[i] << " "; }
	cout << "]" << endl;
	cout << "Penalty: " << setprecision(6) << fixed << bestPenalty << endl;
	cout << "Worst Cost: " << setprecision(6) << fixed << worstCost << endl;
	cout << "Mean Best Cost: " << setprecision(6) << fixed << mean_BestCost << endl;
	cout << "Std. Best Cost: " << setprecision(6) << fixed << std_BestCost << endl;
	cout << "Evaluations: "<< setprecision(0) << fixed << bestEval << endl;
	cout << "Mean Evaluations: " << setprecision(6) << fixed <<mean_BestEval << endl;
	cout << "Std. Evaluations: " << setprecision(6) << fixed << std_BestEval << endl;
	cout << "Mean Run Time: " << setprecision(6) << fixed << mean_run_time << " sec" <<endl;
	cout << "Total Time " << setprecision(6) << fixed << total_Time << endl;
	cout << "Optimization Complete! See Results :) \n" << endl;
};

// END -----------------------------------------------------------------------+
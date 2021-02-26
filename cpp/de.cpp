// File Name: de.cpp ---------------------------------------------------------+
// ---------------------------------------------------------------------------+
//
//  Miguel G. Oliveira
//  Dissertation
//  MSc in Mechanical Engineer
//  University of Aveiro
//
// ---------------------------------------------------------------------------+

// INDIVIDUAL CLASS ----------------------------------------------------------+
class Individual
{
	public:
		double cost,penalty;
		vector<double> position,constraint;

	// Member functions declaration
	public:
		Individual(int D,vector<vector<double>> bounds_x);
		void evaluate(int i);
};

Individual::Individual(int D,vector<vector<double>> bounds_x)
{
   cost = -1;
   penalty = -1;
   position = {};
   constraint = {};

   initial(D,position,bounds_x);
}

// evaluate current fitness
void Individual::evaluate(int i)
{
	costFunc(position,i,cost,constraint,penalty);
}

// POPULATION ----------------------------------------------------------------+
void DE(vector<vector<double>> bounds_x,int ps,int D, int fe,double &cost_Best,vector<double> &position_Best,vector<double> &constraint_Best,double &penalty_Best,int &best_Eval,vector<double> &evol,vector<vector<double>> &evolPos,vector<vector<double>> &evolCons,vector<double> &evolPen,int &e, int &gen) {

	int randIdx;

	cost_Best = -1;			// Best Cost for Population
	position_Best = {};		// Best Position for Population
	constraint_Best = {};	// Best Constraint for Population
	penalty_Best = {};		// Best Penalty for Population
	best_Eval = 0;

	// Establish Population
	e = 0;
	vector<Individual> population;
	for (int j = 0; j < ps; j++)
	{
		Individual individual(D,bounds_x);
     	population.push_back(individual);

     	// cycle through individual in population and evaluate fitness
     	population[j].evaluate(1);

		e++;
	}

	// DE Parameters
    double F = 0.5;		// Mutation Constant
    double CR = 0.7; 	// Crossover Probability

	// Begin optimization Loop
	gen = 0;
	evol = {};
	evolPos = {};
	evolCons = {};
	evolPen = {};

	while (e != fe) {
		// cycle through individual in population
		for (int j = 0; j < ps; ++j) {
			Individual target = population[j];
			// 1. MUTATION -------------------------------------------------- +
	       	// select three random index positions (except current target)
	       	vector<int> candidates;
	       	for (int n = 0; n < ps; ++n) {
	       		candidates.push_back(n);
	       	}
	       	candidates.erase(candidates.begin()+j);

	       	// target vectors
	       	randIdx = rand() % (ps-1);
	       	Individual target_1 = population[candidates[randIdx]];
	       	candidates.erase(candidates.begin()+randIdx);
	       	randIdx = rand() % (ps-2);
	       	Individual target_2 = population[candidates[randIdx]];
	       	candidates.erase(candidates.begin()+randIdx);
	       	randIdx = rand() % (ps-3);
	       	Individual target_3 = population[candidates[randIdx]];
	       	candidates.erase(candidates.begin()+randIdx);

	       	// generate mutant vector
	       	Individual mutant(D,bounds_x);
	       	for (int n = 0; n < D; ++n) {
	       		mutant.position[n] = target_1.position[n] + F*(target_2.position[n] - target_3.position[n]);
	       		// adjust maximum and minimum position if necessary
	       		if (mutant.position[n] < bounds_x[n][0]) {
	       			mutant.position[n] = bounds_x[n][0];
	       		} else if (mutant.position[n] > bounds_x[n][1]) {
	       			mutant.position[n] = bounds_x[n][1];
	       		}
	       	}

	       	// 2. RECOMBINATION --------------------------------------------- +
	       	Individual trial(D,bounds_x);
	       	for (int n = 0; n < D; ++n) {
	       		double crossover = ((double) rand()/RAND_MAX);
	       		if (crossover <= CR) {
	       			trial.position[n] = mutant.position[n];
	       		} else {
	       			trial.position[n] = target.position[n];
	       		}
	       	}

	       	// 3. SELECTION ------------------------------------------------- +
	       	if (e < fe){
	     		trial.evaluate(gen+1);

				e++;

				if (trial.cost < target.cost) {
					population[j].cost = trial.cost;
					population[j].position = trial.position;
					population[j].constraint = trial.constraint;
					population[j].penalty = trial.penalty;
				}
				if (population[j].cost < cost_Best || cost_Best == -1) {
					position_Best = population[j].position;
					cost_Best = population[j].cost;
					constraint_Best = population[j].constraint;
					penalty_Best = population[j].penalty;
					best_Eval = e;
				}
			} else {
				break;
			}
       	}

		cout << "\nGeneration: " << (gen+1) << endl;
		cout << "Function Evaluations: " << e << endl;
		cout << "Best Cost " << setprecision(10) << cost_Best <<endl;
		cout << "Best Position: [ ";
		for (int n = 0; n < D; ++n) { cout << setprecision(10) <<position_Best[n] << " "; }
		cout << "]" << endl;
		cout << "Best Constraint: [ ";
		for (int n = 0; n < 11; ++n) { cout << setprecision(10) << constraint_Best[n] << " "; }
		cout << "]" << endl;
		cout << "Best Penalty: " << setprecision(10) << penalty_Best << endl;


		evol.push_back(cost_Best);
		evolPos.push_back(position_Best);
		evolCons.push_back(constraint_Best);
		evolPen.push_back(penalty_Best);

		gen++;
	}
}

// END -----------------------------------------------------------------------+
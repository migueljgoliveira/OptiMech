// File Name: tlbo.cpp -------------------------------------------------------+
// ---------------------------------------------------------------------------+
//
//  Miguel G. Oliveira
//  Dissertation
//  MSc in Mechanical Engineer
//  University of Aveiro
//
// ---------------------------------------------------------------------------+

// LEARNER CLASS -------------------------------------------------------------+
class Learner {
	public:
		double cost,penalty;
		vector<double> position,constraint;

	// Member functions declaration
	public:
		Learner(int D,vector<vector<double>> bounds_x);
		void evaluate(int i);
		void update_position(int D,vector<vector<double>> bounds_x);
};

Learner::Learner(int D,vector<vector<double>> bounds_x) {
   cost = -1;
   penalty = -1;
   position = {};
   constraint = {};

   initial(D,position,bounds_x);
}

// evaluate current fitness
void Learner::evaluate(int i) {
	costFunc(position,i,cost,constraint,penalty);
}

// adjust maximum and minimum position if necessary
void Learner::update_position(int D,vector<vector<double>> bounds_x) {
	for (int n = 0; n < D; ++n) {
		if (position[n] < bounds_x[n][0]) {
	    	position[n] = bounds_x[n][0];
	    } else if (position[n] > bounds_x[n][1]) {
	    	position[n] = bounds_x[n][1];
	    }
	}
}

// POPULATION ----------------------------------------------------------------+
void TLBO(vector<vector<double>> bounds_x,int ps,int D, int fe,double &cost_Best,vector<double> &position_Best,vector<double> &constraint_Best,double &penalty_Best,int &best_Eval,vector<double> &evol,vector<vector<double>> &evolPos,vector<vector<double>> &evolCons,vector<double> &evolPen,int &e, int &gen) {

	cost_Best = -1;			// Best Cost for Population
	position_Best = {};		// Best Position for Population
	constraint_Best = {};	// Best Constraint for Population
	penalty_Best = {};		// Best Penalty for Population
	best_Eval = 0;

	// Establish Population
	e = 0;
	vector<Learner> population;
	for (int j = 0; j < ps; j++) {
		Learner Learner(D,bounds_x);
     	population.push_back(Learner);

     	// cycle through individual in population and evaluate fitness
     	population[j].evaluate(1);

		e++;

		if (population[j].cost < cost_Best || cost_Best == -1){
			position_Best = population[j].position;
			cost_Best = population[j].cost;
			constraint_Best = population[j].constraint;
			penalty_Best = population[j].penalty;
		}
	}

	// Begin optimization Loop
	gen = 0;
	evol = {};
	evolPos = {};
	evolCons = {};
	evolPen = {};

	while (e != fe) {
		// TEACHER PHASE -----------------------------------------------------+
		// calculate mean of each design variable (population)
		vector<double> mean_Variables(D,0.0);
		for (int j = 0; j < D; ++j) {
			for (int k = 0; k < ps; ++k) {
				mean_Variables[j] += population[k].position[j];
			}
		}
		for (int j = 0; j < D; ++j){
			mean_Variables[j] = mean_Variables[j]/ps;
		}
		vector<double> position_BestGen = position_Best;

		// modify solution based on teacher solution
		for (int i = 0; i < ps; ++i) {
			Learner newSolution(D,bounds_x);

			int Tf = rand() % 2 + 1;
			vector<double> difference_Mean(D);

			for (int j = 0; j < D; ++j) {
				double r = ((double) rand()/RAND_MAX);
				difference_Mean[j] = r*(position_BestGen[j] - Tf*mean_Variables[j]);
			}

			// update position based of mean difference of solutions
			for (int j = 0; j < D; ++j) {
				newSolution.position[j] = population[i].position[j] + difference_Mean[j];
			}

			// adjust maximum and minimum position if necessary
			newSolution.update_position(D,bounds_x);

			// evaluate new generated solution
			if (e < fe){
	     		newSolution.evaluate(gen+1);

				e++;

				if (newSolution.cost < population[i].cost) {
					population[i].cost = newSolution.cost;
					population[i].position = newSolution.position;
					population[i].constraint = newSolution.constraint;
					population[i].penalty = newSolution.penalty;
				}

				if (population[i].cost < cost_Best) {
					cost_Best = population[i].cost;
					position_Best = population[i].position;
					constraint_Best = population[i].constraint;
					penalty_Best = population[i].penalty;
					best_Eval = e;
				}
			} else {
				break;
			}
		}

		// LEARNER PHASE -----------------------------------------------------+
		vector<Learner> snapPopulation = population;
		Learner newSolution(D,bounds_x);
		for (int j = 0; j < ps; ++j){
			vector<int> candidates;
			for (int n = 0; n < ps; ++n) {
	       		candidates.push_back(n);
	       	}
	       	candidates.erase(candidates.begin()+j);
	       	int randIdx = rand() % (ps-1);
	       	int random_index = candidates[randIdx];

	       	if (snapPopulation[j].cost < snapPopulation[random_index].cost) {
	       		for (int k = 0; k < D; ++k){
	       			// generate new solution based on current and random
	       			double r = ((double) rand()/RAND_MAX);
	       			newSolution.position[k] = snapPopulation[j].position[k] + r*(snapPopulation[j].position[k] - snapPopulation[random_index].position[k]);
	       		}
	       	// is random solution better than current?
	       	} else {
	       		for (int k = 0; k < D; ++k){
	       			// generate new solution based on current and random
	       			double r = ((double) rand()/RAND_MAX);
	       			newSolution.position[k] = snapPopulation[j].position[k] + r*(snapPopulation[random_index].position[k] - snapPopulation[j].position[k]);
	       		}
	       	}

	       	// adjust maximum and minimum position if necessary
	       	newSolution.update_position(D,bounds_x);

	       	// evaluate new generated solution
			if (e < fe){
	     		newSolution.evaluate(gen+1);

				e++;

				if (newSolution.cost < population[j].cost) {
					population[j].cost = newSolution.cost;
					population[j].position = newSolution.position;
					population[j].constraint = newSolution.constraint;
					population[j].penalty = newSolution.penalty;
				}

				if (population[j].cost < cost_Best) {
					cost_Best = population[j].cost;
					position_Best = population[j].position;
					constraint_Best = population[j].constraint;
					penalty_Best = population[j].penalty;
					best_Eval = e;
				}

			} else {
				break;
			}
		}

		// remove Duplicates
		for (int j = 0; j < ps-1; ++j) {
			for (int k = j+1; k < ps; ++k) {
				if (population[j].position == population[k].position){
					vector<double> mutate = population[k].position;
					bool isNew = false;
					while (!isNew) {
						int subject = rand() % D;
						if (((double) rand()/RAND_MAX) > 0.5){
							mutate[subject] = mutate[subject] + (((double) rand()/RAND_MAX)*mutate[subject]);
						} else {
							mutate[subject] = mutate[subject] - (((double) rand()/RAND_MAX)*mutate[subject]);
						}
						if (mutate[subject] < bounds_x[subject][0]) {
	    					mutate[subject] = bounds_x[subject][0];
	    				} else if (mutate[subject] > bounds_x[subject][1]) {
	    					mutate[subject] = bounds_x[subject][1];
	    				}

	    				for (int n = 0; n < ps; ++n) {
	    					if (population[n].position != mutate) {
	    						isNew = true;
	    					}
	    				}
					}
					population[k].position = mutate;
				}
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
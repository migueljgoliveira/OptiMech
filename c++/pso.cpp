// File Name: pso.cpp --------------------------------------------------------+
// ---------------------------------------------------------------------------+
//
//  Miguel G. Oliveira
//  Dissertation
//  MSc in Mechanical Engineer
//  University of Aveiro
//
// ---------------------------------------------------------------------------+

// PARTICLE CLASS ------------------------------------------------------------+
class Particle
{
	public:
		double cost_i,cost_Best_i,penalty_i,penalty_Best_i;
		vector<double> position_i,velocity_i,position_Best_i,constraint_Best_i,constraint_i;

	// Member functions declaration
	public:
		Particle(int D,vector< vector<double> > bounds_x,vector< vector<double> > bounds_v);
		void evaluate(int i);
		void update_velocity(vector<double> position_Best,int D,int i,int maxiter,vector< vector<double> > bounds_x);
		void update_position(vector< vector<double> > bounds_x,int D);

};

Particle::Particle(int D,vector< vector<double> > bounds_x,vector< vector<double> > bounds_v)
{
   cost_i = -1;
   cost_Best_i = -1;
   penalty_i = -1;
   penalty_Best_i = -1;
   position_i = {};
   velocity_i = {};
   position_Best_i = {};
   constraint_Best_i = {};
   constraint_i = {};

   initial_pso(D,position_i,velocity_i,bounds_x,bounds_v);
}

// evaluate current fitness
void Particle::evaluate(int i)
{
	costFunc(position_i,i,cost_i,constraint_i,penalty_i);

	// check to see if the current position is an individual best
	if (cost_i < cost_Best_i || cost_Best_i == -1)
	{
		position_Best_i = position_i;
		cost_Best_i = cost_i;
		constraint_Best_i = constraint_i;
		penalty_Best_i = penalty_i;
	}

}

// update new particle velocity
void Particle::update_velocity(vector<double> position_Best,int D,int i,int maxiter,vector< vector<double> > bounds_v)
{
	double w,c1,c2,r1,r2,velocity_Cognitive,velocity_Social;
	w = (0.9-0.4)*((floor(maxiter)-i)/floor(maxiter))+0.4;
	c1 = 2.0;
	c2 = 2.0;

	for (int j = 0; j < D; ++j)
	{
		r1 = ((double) rand()/RAND_MAX);
		r2 = ((double) rand()/RAND_MAX);

		velocity_Cognitive = c1*r1*(position_Best_i[j] - position_i[j]);
		velocity_Social = c2*r2*(position_Best[j] - position_i[j]);
		velocity_i[j] = w*velocity_i[j] + velocity_Cognitive + velocity_Social;

		// adjust maximum and minimum velocity if necessary
		if (velocity_i[j] > bounds_v[j][1]) {
			velocity_i[j] = bounds_v[j][1];
		} else if (velocity_i[j] < bounds_v[j][0]) {
			velocity_i[j] = bounds_v[j][0];
		}
	}

}

// update new particle position
void Particle::update_position(vector< vector<double> > bounds_x,int D)
{
	for (int j = 0; j < D; ++j)
	{
		position_i[j] = position_i[j] + velocity_i[j];

		// adjust maximum and minimum position if necessary
		if (position_i[j] > bounds_x[j][1]) {
			position_i[j] = bounds_x[j][1];
		} else if (position_i[j] < bounds_x[j][0]) {
			position_i[j] = bounds_x[j][0];
		}

	}
}

// SWARM ---------------------------------------------------------------------+
void PSO(vector<vector<double>> bounds_x,vector<vector<double>> bounds_v,int ps,int D, int fe,double &cost_Best,vector<double> &position_Best,vector<double> &constraint_Best,double &penalty_Best,int &best_Eval,vector<double> &evol,vector<vector<double>> &evolPos,vector<vector<double>> &evolCons,vector<double> &evolPen,int &e, int &gen) {

	cost_Best = -1;			// Best Cost for Group
	position_Best = {};		// Best Position for Group
	constraint_Best = {};		// Best Constraint for Group
	penalty_Best = {};		// Best Penalty for Group
	best_Eval = 0;

	// Establish Swarm
	vector<Particle> swarm;
	for (int i = 0; i < ps; i++)
	{
		Particle particle(D,bounds_x,bounds_v);
     	swarm.push_back(particle);
	}

	// Begin optimization Loop
	gen = 0;
	e = 0;
	evol = {};
	evolPos = {};
	evolCons = {};
	evolPen = {};

	while (e != fe) {
		// cycle through particles in swarm and evaluate fitness
		for (int j = 0; j < ps; ++j) {
			if (e < fe) {
				swarm[j].evaluate(gen+1);

				e ++;

				// determine if current particle is the best (globally)
				if (swarm[j].cost_Best_i < cost_Best || cost_Best == -1) {
					position_Best = swarm[j].position_Best_i;
					cost_Best = swarm[j].cost_Best_i;
					constraint_Best = swarm[j].constraint_Best_i;
					penalty_Best = swarm[j].penalty_Best_i;
					best_Eval = e;
				}

			} else {
				break;
			}
		}

		// cycle through swarm and update velocities and position
		for (int k = 0; k < ps; ++k){
			swarm[k].update_velocity(position_Best,D,gen,fe/ps,bounds_v);
			swarm[k].update_position(bounds_x,D);
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
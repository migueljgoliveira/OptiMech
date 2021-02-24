// File Name: DE.java --------------------------------------------------------+
// ---------------------------------------------------------------------------+
//
//  Miguel G. Oliveira
//  Dissertation
//  MSc in Mechanical Engineer
//  University of Aveiro
//
// ---------------------------------------------------------------------------+

// IMPORT PACKAGES -----------------------------------------------------------+
import java.util.*;

// SWARM CLASS ---------------------------------------------------------------+
public class DE {

	double cost_Best,penalty_Best,best_Eval;
	double[][] evolPos,evolCons;
	double[] position_Best,constraint_Best;
	ArrayList<Individual> population;
	ArrayList<Double> evol,evolPen;
	int gen;

	public DE() { super(); }

	public DE(double[][] bounds_x,int ps,int D,int fe) {

		int randIdx;
		Random rand;

		this.cost_Best = -1;
		this.position_Best = new double[] {};
		this.constraint_Best = new double[] {};
		this.penalty_Best = -1;
		this.best_Eval = 0;

		// Establish Population
		int e = 0;
		population = new ArrayList<Individual>();
		for (int i = 0 ; i < ps ; i++ ) {
			population.add(new Individual(D,bounds_x));

			// cycle through individual in population and evaluate fitness
			population.get(i).evaluate(1);

			e += 1;
		}

		// DE Parameters
		double F = 0.5;		// Mutation Constant
		double CR = 0.7;	// Crossover Probability

		// Begin optimization Loop
		this.gen = 0;
		this.evol = new ArrayList<Double>();
		int maxiter = (int)Math.ceil((double)fe/(double)ps);
		this.evolPos = new double[maxiter][];
		this.evolCons = new double[maxiter][];
		this.evolPen = new ArrayList<Double>();
		rand = new Random();

		while (e != fe) {
			// cycle through individual in population
			for (int j = 0 ; j < ps ; j++ ) {
				Individual target = population.get(j);
				// 1. MUTATION ---------------------------------------------- +
        		// select three random index positions (except current target)
        		ArrayList<Integer> candidates = new ArrayList<Integer>();
        		for (int n = 0; n < ps ; n++) {
        			candidates.add(n);
        		}
        		candidates.remove(j);

        		// target vectors
        		randIdx = rand.nextInt(ps-1);
        		Individual target_1 = population.get(candidates.get(randIdx));
        		candidates.remove(randIdx);
        		randIdx = rand.nextInt(ps-2);
        		Individual target_2 = population.get(candidates.get(randIdx));
        		candidates.remove(randIdx);
        		randIdx = rand.nextInt(ps-3);
        		Individual target_3 = population.get(candidates.get(randIdx));
        		candidates.remove(randIdx);

        		// generate mutant vector
        		Individual mutant = new Individual(D,bounds_x);
        		for (int n = 0; n < D ; n++) {
        			mutant.position[n] = target_1.position[n] + F*(target_2.position[n] - target_3.position[n]);
        		}

        		for (int n = 0; n < D ; n++ ) {
        			if (mutant.position[n] < bounds_x[n][0]) {
        				mutant.position[n] = bounds_x[n][0];
        			} else if (mutant.position[n] > bounds_x[n][1]) {
        				mutant.position[n] = bounds_x[n][1];
        			}
        		}

        		// 2. RECOMBINATION ----------------------------------------- +
        		Individual trial = new Individual(D,bounds_x);
        		for (int n = 0; n < D ; n++) {
        			double crossover = Math.random();
        			if (crossover <= CR) {
        				trial.position[n] = mutant.position[n];
        			} else {
        				trial.position[n] = target.position[n];
        			}
        		}

        		// 3. SELECTION --------------------------------------------- +
        		if (e < fe) {
					trial.evaluate(gen+1);

					e += 1;

					if (trial.cost < target.cost) {
						population.get(j).cost = trial.cost;
						population.get(j).position = Arrays.copyOf(trial.position,D);
						population.get(j).constraint = Arrays.copyOf(trial.constraint,trial.constraint.length);
						population.get(j).penalty = trial.penalty;
					}

					// determine if current particle is the best (globally)
					if (population.get(j).cost < this.cost_Best || this.cost_Best == -1) {
						this.position_Best = Arrays.copyOf(population.get(j).position, D);
						this.cost_Best = population.get(j).cost;
						this.constraint_Best = Arrays.copyOf(population.get(j).constraint, population.get(j).constraint.length);
						this.penalty_Best = population.get(j).penalty;
						this.best_Eval = e;
					}
				} else {
					break;
				}
			}

			System.out.println("\nGeneration: " + (gen+1));
			System.out.println("Function Evaluations: " + e);
			System.out.println("Best Cost: " + this.cost_Best);
			System.out.println("Best Position: " + Arrays.toString(this.position_Best));
			System.out.println("Best Constraint: " + Arrays.toString(this.constraint_Best));
			System.out.println("Penalty: " + this.penalty_Best);

			this.evol.add(this.cost_Best);
			this.evolPos[this.gen] = Arrays.copyOf(this.position_Best, D);
			this.evolCons[this.gen] = Arrays.copyOf(this.constraint_Best, this.constraint_Best.length);
			this.evolPen.add(this.penalty_Best);

			this.gen++;
		}
	}
}

// INDIVIDUAL CLASS ----------------------------------------------------------+
class Individual implements Problem{

	double[] position,constraint;
	double cost,penalty;

	public Individual(int D, double [][] bounds_x)
	{
		this.position = new double[] {}; 		// individual position
   		this.cost = -1; 						// individual cost
        this.constraint = new double[] {};     	// individual constraints
        this.penalty = -1;    			 	 	// individual penalty

        this.position =  Problem.initial(D,bounds_x);
	}

	// evaluate current fitness
	public void evaluate(int i)
	{
		Object[] func = Problem.costFunc(position,i);

		cost = (double)func[0];
	   	constraint = (double[])func[1];
	   	penalty = (double)func[2];
	   	position = (double[])func[3];

	}

}

// END -----------------------------------------------------------------------+
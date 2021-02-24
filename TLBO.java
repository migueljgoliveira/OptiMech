// File Name: STLBO.java -----------------------------------------------------+
// ---------------------------------------------------------------------------+
//
//  Miguel G. Oliveira
//  Dissertation
//  MSc in Mechanical Engineer
//  University of Aveiro
//
// Description:  --------------------------+
// ---------------------------------------------------------------------------+

// IMPORT PACKAGES -----------------------------------------------------------+
import java.util.*;

// SWARM CLASS ---------------------------------------------------------------+
public class STLBO {

	double teacher_Cost,teacher_Penalty,best_Eval;
	double[][] evolPos,evolCons;
	double[] teacher_Position,teacher_Constraint;
	ArrayList<Learner> population;
	ArrayList<Double> evol,evolPen,evaluation_time;
	int gen;

	public STLBO() { super(); }

	public STLBO(double[][] bounds_x,int ps,int D,int fe,double Best) {

		int randIdx;
		Random rand;

		this.teacher_Cost = -1;
		this.teacher_Position = new double[] {};
		this.teacher_Constraint = new double[] {};
		this.teacher_Penalty = -1;
		this.best_Eval = 0;
		boolean best_Found = false;

		this.evaluation_time = new ArrayList<Double>();
		// Establish Population
		int e = 0;
		population = new ArrayList<Learner>();
		for (int i = 0 ; i < ps ; i++ ) {
			population.add(new Learner(D,bounds_x));

			// cycle through individual in population and evaluate fitness
			long evaluation_start_time = System.nanoTime();

			population.get(i).evaluate(1);

			long evaluation_elapsed_time = (System.nanoTime() - evaluation_start_time);
			this.evaluation_time.add((double)evaluation_elapsed_time);
			e += 1;

			if (population.get(i).cost < this.teacher_Cost || this.teacher_Cost == -1) {
				this.teacher_Position = Arrays.copyOf(population.get(i).position, D);
				this.teacher_Cost = population.get(i).cost;
				this.teacher_Constraint = Arrays.copyOf(population.get(i).constraint,population.get(i).constraint.length);
				this.teacher_Penalty = population.get(i).penalty;
			}
		}

		// Begin optimization Loop
		this.gen = 0;
		this.evol = new ArrayList<Double>();
		int maxiter = (int)Math.ceil((double)fe/(double)ps);
		this.evolPos = new double[maxiter][];
		this.evolCons = new double[maxiter][];
		this.evolPen = new ArrayList<Double>();
		rand = new Random();

		while (e != fe) {
			// TEACHER PHASE -------------------------------------------------+
			// calculate mean of each design variable (population)
			double [] mean_Variables = new double[D];
			for (int j = 0 ; j < D ; j++) {
				for (int k = 0; k < ps ; k++) {
					mean_Variables[j] += population.get(k).position[j];
				}
			}
			for (int j = 0 ; j < D ; j++) {
				mean_Variables[j] = mean_Variables[j]/ps;
			}
			double[] teacher_PositionGen = Arrays.copyOf(teacher_Position, D);

			// modify solution based on teacher solution
			for (int i = 0 ; i < ps ; i++) {
				Learner newSolution = new Learner(D,bounds_x);

				int Tf = (int)Math.round(1+Math.random()*(2-1));
				double[] difference_Mean = new double[D];

				for (int j = 0 ; j < D ; j++) {
					double r = Math.random();
					difference_Mean[j] = r*(teacher_PositionGen[j] - Tf*mean_Variables[j]);
				}

				// update position based of mean difference of solutions
				for (int j = 0 ; j < D ; j++) {
					newSolution.position[j] = population.get(i).position[j] + difference_Mean[j];
				}

				// adjust maximum and minimum position if necessary
				newSolution.update_position(D,bounds_x);

				// evaluate new generated solution
				if (e < fe) {
					long evaluation_start_time = System.nanoTime();

					newSolution.evaluate(gen+1);

					long evaluation_elapsed_time = (System.nanoTime() - evaluation_start_time);
					this.evaluation_time.add((double)evaluation_elapsed_time);
					e += 1;

					// is new solution better than existing?
					if (newSolution.cost < population.get(i).cost) {
						population.get(i).cost = newSolution.cost;
						population.get(i).position = Arrays.copyOf(newSolution.position, D);
						population.get(i).constraint = Arrays.copyOf(newSolution.constraint, newSolution.constraint.length);
						population.get(i).penalty = newSolution.penalty;
					}

					if (population.get(i).cost < this.teacher_Cost) {
						this.teacher_Position = Arrays.copyOf(population.get(i).position, D);
						this.teacher_Cost = population.get(i).cost;
						this.teacher_Constraint = Arrays.copyOf(population.get(i).constraint,population.get(i).constraint.length);
						this.teacher_Penalty = population.get(i).penalty;
					}

					if (this.teacher_Cost <= Best && !best_Found) {
						this.best_Eval = e;
						best_Found = true;
					}
				} else {
					break;
				}
			}

			// LEARNER PHASE -------------------------------------------------+
			ArrayList<Learner> snapPopulation = population;
			Learner newSolution = new Learner(D,bounds_x);
			for (int j = 0 ; j < ps ; j++) {
				// select one random solution
				ArrayList<Integer> candidates = new ArrayList<Integer>();
        		for (int n = 0; n < ps ; n++) {
        			candidates.add(n);
        		}
        		candidates.remove(j);
        		randIdx = rand.nextInt(ps-1);
        		Integer random_index = candidates.get(randIdx);

        		// is current solution better than random?
        		if (snapPopulation.get(j).cost < snapPopulation.get(random_index).cost) {
        			for (int k = 0; k < D ; k++) {
        				// generate new solution based on current and random
        				double r = Math.random();
        				newSolution.position[k] = snapPopulation.get(j).position[k] + r*(snapPopulation.get(j).position[k] - snapPopulation.get(random_index).position[k]);
        			}
        		// is random solution better than current?
        		} else {
        			for (int k = 0; k < D ; k++) {
        				// generate new solution based on current and random
        				double r = Math.random();
        				newSolution.position[k] = snapPopulation.get(j).position[k] + r*(snapPopulation.get(random_index).position[k] - snapPopulation.get(j).position[k]);
        			}
        		}

				// adjust maximum and minimum position if necessary
				newSolution.update_position(D,bounds_x);

				// evaluate new generated solution
				if (e < fe) {
					long evaluation_start_time = System.nanoTime();

					newSolution.evaluate(gen+1);

					long evaluation_elapsed_time = (System.nanoTime() - evaluation_start_time);
					this.evaluation_time.add((double)evaluation_elapsed_time);
					e += 1;

					// is new solution better than existing?
					if (newSolution.cost < population.get(j).cost) {
						population.get(j).cost = newSolution.cost;
						population.get(j).position = Arrays.copyOf(newSolution.position, D);
						population.get(j).constraint = Arrays.copyOf(newSolution.constraint, newSolution.constraint.length);
						population.get(j).penalty = newSolution.penalty;
					}

					if (population.get(j).cost < this.teacher_Cost) {
						this.teacher_Position = Arrays.copyOf(population.get(j).position, D);
						this.teacher_Cost = population.get(j).cost;
						this.teacher_Constraint = Arrays.copyOf(population.get(j).constraint,population.get(j).constraint.length);
						this.teacher_Penalty = population.get(j).penalty;
					}

					if (this.teacher_Cost <= Best && !best_Found) {
						this.best_Eval = e;
						best_Found = true;
					}
				} else {
					break;
				}
			}

			// remove Duplicates
			for (int j = 0 ; j < ps - 1 ; j++) {
				for (int k = j+1; k < ps ; k++) {
					if (Arrays.equals(population.get(j).position, population.get(k).position)) {
						double [] mutate = population.get(k).position;
						boolean isNew = false;
						while (!isNew) {
							int subject = rand.nextInt(D);
							if (Math.random() > 0.5) {
								mutate[subject] = mutate[subject] + (Math.random()*mutate[subject]);
							} else {
								mutate[subject] = mutate[subject] - (Math.random()*mutate[subject]);
							}
							if (mutate[subject] > bounds_x[subject][1]) {
								mutate[subject] = bounds_x[subject][1];
							} else if (mutate[subject]< bounds_x[subject][0]) {
								mutate[subject] = bounds_x[subject][0];
							}

							for (int n = 0; n < ps ; n++ ) {
								if (!Arrays.equals(population.get(n).position,mutate)) {
									isNew = true;
								}
							}
						}
						population.get(k).position = Arrays.copyOf(mutate,mutate.length);
					}
				}
			}

			//System.out.println("Generation: " + (gen+1));
			//System.out.println("Function Evaluations: " + e);
			//System.out.println("Best Cost: " + this.teacher_Cost);
			//System.out.println("Best Position: " + Arrays.toString(this.teacher_Position));
			//System.out.println("Best Constraint: " + Arrays.toString(this.teacher_Constraint));
			//System.out.println("Penalty: " + this.teacher_Penalty);

			this.evol.add(this.teacher_Cost);
			this.evolPos[this.gen] = Arrays.copyOf(this.teacher_Position, D);
			this.evolCons[this.gen] = Arrays.copyOf(this.teacher_Constraint, this.teacher_Constraint.length);
			this.evolPen.add(this.teacher_Penalty);

			this.gen++;
		}
	}
}

// LEARNER CLASS -------------------------------------------------------------+
class Learner implements Reducer{

	double[] position,constraint;
	double cost,penalty;

	public Learner(int D, double [][] bounds_x)
	{
		this.position = new double[] {}; 		// individual position
   		this.cost = -1; 						// individual cost
        this.constraint = new double[] {};     	// individual constraints
        this.penalty = -1;    			 	 	// individual penalty

        this.position =  Reducer.initial(D,bounds_x);
	}

	// evaluate current fitness
	public void evaluate(int i)
	{
		Object[] func = Reducer.costFunc(position,i);

		cost = (double)func[0];
	   	constraint = (double[])func[1];
	   	penalty = (double)func[2];
	   	position = (double[])func[3];

	}

	// adjust maximum and minimum position if necessary
	public void update_position(int D,double[][] bounds_x)
	{
		for (int j = 0; j < D; j++ ) {
			if (position[j] > bounds_x[j][1]) {
				position[j] = bounds_x[j][1];
			} else if (position[j] < bounds_x[j][0]) {
				position[j] = bounds_x[j][0];
			}
		}

	}

}

// END -----------------------------------------------------------------------+
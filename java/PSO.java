// File Name: PSO.java -------------------------------------------------------+
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
import java.io.*;

// SWARM CLASS ---------------------------------------------------------------+
public class PSO {

	double cost_Best,penalty_Best,best_Eval;
	double[][] evolPos,evolCons;
	double[] position_Best,constraint_Best;
	ArrayList<Particle> swarm;
	ArrayList<Double> evol,evolPen;
	int gen;

	public PSO() { super(); }

	public PSO(double[][] bounds_x,double[][] bounds_v,int ps,int D,int fe) throws IOException{

		this.cost_Best = -1;
		this.position_Best = new double[] {};
		this.constraint_Best = new double[] {};
		this.penalty_Best = -1;
		this.best_Eval = 0;

		// Establish Swarm
		swarm = new ArrayList<Particle>();
		for (int i = 0 ; i < ps ; i++ ) {
			swarm.add(new Particle(D,bounds_x,bounds_v));
		}

		// Begin optimization Loop
		this.gen = 0;
		int e = 0;
		this.evol = new ArrayList<Double>();
		int maxiter = (int)Math.ceil((double)fe/(double)ps);
		this.evolPos = new double[maxiter][];
		this.evolCons = new double[maxiter][];
		this.evolPen = new ArrayList<Double>();

		while (e != fe) {
			// cycle through particles in swarm and evaluate fitness
			for (int j = 0 ; j < ps ; j++ ) {
				if (e < fe) {
					swarm.get(j).evaluate(gen+1);

					e += 1;

					// determine if current particle is the best (globally)
					if (swarm.get(j).cost_Best_i < this.cost_Best || this.cost_Best == -1) {
						this.position_Best = Arrays.copyOf(swarm.get(j).position_Best_i, D);
						this.cost_Best = swarm.get(j).cost_Best_i;
						this.constraint_Best = Arrays.copyOf(swarm.get(j).constraint_Best_i, swarm.get(j).constraint_Best_i.length);
						this.penalty_Best = swarm.get(j).penalty_Best_i;
						this.best_Eval = e;
					}
				} else {
					break;
				}
			}

			// cycle through swarm and update velocities and position
			for (int k = 0 ; k < ps ; k++) {
				swarm.get(k).update_velocity(this.position_Best,D,gen,maxiter,bounds_v);
				swarm.get(k).update_position(bounds_x,D);
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

// PARTICLE CLASS ------------------------------------------------------------+
class Particle implements Problem{

	double[] position_i,velocity_i,position_Best_i;
	double[] constraint_Best_i,constraint_i;
	double cost_i,cost_Best_i,penalty_i,penalty_Best_i;

	public Particle(int D, double [][] bounds_x, double [][] bounds_v) {

		this.position_i = new double[] {}; 		 // particle position
   		this.velocity_i = new double[] {}; 		 // particle velocity
   		this.cost_i = -1; 						 // cost individual
   		this.position_Best_i = new double[] {};  // position best individual
        this.cost_Best_i = -1;         			 // cost best individual
        this.constraint_Best_i = new double[] {};// contraints best individual
        this.constraint_i = new double[] {};     // constraints individual
        this.penalty_i = -1;    			 	 // penalty individual
        this.penalty_Best_i = -1;      			 // penalty best individual

        Object[] init = Problem.initial_pso(D,bounds_x,bounds_v);

        this.position_i = (double[])init[0];
	   	this.velocity_i = (double[])init[1];

	}
	// evaluate current fitness
	public void evaluate(int i)
	{
		Object[] func = Problem.costFunc(position_i,i);

		cost_i = (double)func[0];
	   	constraint_i = (double[])func[1];
	   	penalty_i = (double)func[2];
	   	position_i = (double[])func[3];

	   	// check to see if the current position is an individual best
	   	if (cost_i < cost_Best_i || cost_Best_i == -1)
	   	{
	   		position_Best_i = Arrays.copyOf(position_i, position_i.length);
            cost_Best_i = cost_i;
            constraint_Best_i =Arrays.copyOf(constraint_i,constraint_i.length);
            penalty_Best_i = penalty_i;
	   	}

	}

	// update new particle velocity
	public void update_velocity(double[] position_Best, int D, int i, int maxiter,double[][] bounds_v) {
		double w,velocity_Cognitive,velocity_Social,r1,r2,c1,c2;
		// linear decreasing weight
		w = (0.9-0.4)*((double)(maxiter-i)/maxiter)+0.4;
		c1 = 2.0;		// cognitive Constant
		c2 = 2.0;		// social constant

	   	for (int j = 0 ; j < D ; j++ )
	   	{
	   		r1 = Math.random();
	   		r2 = Math.random();

	   		velocity_Cognitive = c1*r1*(position_Best_i[j] - position_i[j]);
	   		velocity_Social = c2*r2*(position_Best[j] - position_i[j]);

	   		velocity_i[j] = w*velocity_i[j] + velocity_Cognitive + velocity_Social;

	   		// adjust maximum and minimum velocity if necessary
	   		if (velocity_i[j] > bounds_v[j][1])
	   		{
	   			velocity_i[j] = bounds_v[j][1];
	   		} else if (velocity_i[j] < bounds_v[j][0])
	   		{
	   			velocity_i[j] = bounds_v[j][0];
	   		}
	   	}
	}

	// update new particle position
	public void update_position(double[][] bounds_x,int D) {
	   	for (int j = 0 ; j < D ; j++ ) {
	   		position_i[j] = position_i[j] + velocity_i[j];

	   		// adjust maximum position if necessary
	   		if (position_i[j] > bounds_x[j][1])
	   		{
	   			position_i[j] = bounds_x[j][1];
	   		} else if (position_i[j] < bounds_x[j][0])
	   		{
	   			position_i[j] = bounds_x[j][0];
	   		}
	   	}
	}
}

// END -----------------------------------------------------------------------+
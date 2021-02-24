// File Name: Run_DE.java -----------------------------------------------------+
// ---------------------------------------------------------------------------+
//
//  Miguel G. Oliveira
//  Dissertation
//  MSc in Mechanical Engineer
//  University of Aveiro
//
// ---------------------------------------------------------------------------+

// IMPORT PACKAGES -----------------------------------------------------------+
import java.io.*;

// MAIN ----------------------------------------------------------------------+
public class Run_DE extends DE implements Problem,PostProcessing {

    public static void main(String []args) throws IOException,InterruptedException {
   		System.out.println("+++ OptiMeta +++");

   		// PARAMETERS SETTING ------------------------------------------------+
		// Function Independent Parameters
		int runs = 1;
		int fe = 1000;

		// Function Dependent Parameters
		Object[] settings = Problem.setting();
	   	int D = (int)settings[0];
	   	double[][] bounds_x = (double[][])settings[1];
	   	int ps = 6*D;

	   	// Call 'variables' method from PostProcessing
	   	Object[] vars = PostProcessing.variables(runs,fe,ps);
	   	double[][] evolution = (double[][])vars[0];
	   	double[][][] evolutionPosition = (double[][][])vars[1];
	   	double[][][] evolutionConstraints = (double[][][])vars[2];
	   	double[][] evolutionPenalty = (double[][])vars[3];
	   	double[] bestCost = (double[])vars[4];
	   	double[][] bestPosition = (double[][])vars[5];
	   	double[][] bestConstraint = (double[][])vars[6];
	   	double[] bestPenalty = (double[])vars[7];
	   	double[] bestEval = (double[])vars[8];
	   	int[] gens = (int[])vars[9];
	   	double[] run_timer = (double[])vars[10];

	   	// RUN ---------------------------------------------------------------+
	   	long total_start_time = System.nanoTime();

	   	for (int i = 0; i < runs ; i++) {
	   		System.out.println("Run " + (i+1) + " ...");
	   		// Starting Time of Run
	   		long run_start_time = System.nanoTime();

			// DE
			DE results = new DE(bounds_x,ps,D,fe);

	   		// Elapsed Time of Run
	   		long run_time = (System.nanoTime() - run_start_time);

	   		Object[] res = PostProcessing.result(i,results.evol,results.evolPos,results.evolCons,results.evolPen,results.position_Best,results.cost_Best,results.constraint_Best,results.penalty_Best,run_time,results.best_Eval,evolution,evolutionPosition,evolutionConstraints,evolutionPenalty,bestPosition,bestCost,bestConstraint,bestPenalty,bestEval,run_timer,gens,results.gen);
	   	}

	   	long total_timer = (System.nanoTime() - total_start_time);

	   	Object[] pos = PostProcessing.post(evolution,evolutionPosition,evolutionConstraints,evolutionPenalty,bestPosition,bestCost,bestConstraint,bestPenalty,bestEval,run_timer,total_timer,runs,gens);

	   	double[] Evolution = (double[])pos[0];
        double[] EvolutionPenalty = (double[])pos[1];
      	double BestCost = (double)pos[2];
	   	double[] BestPosition = (double[])pos[3];
	   	double[] BestConstraint = (double[])pos[4];
	   	double BestPenalty = (double)pos[5];
        double BestEval = (double)pos[6];
      	double WorstCost = (double)pos[7];
      	double mean_BestCost = (double)pos[8];
        double mean_BestEval = (double)pos[9];
        double std_BestCost = (double)pos[10];
        double std_BestEval = (double)pos[11];
        double mean_run_time = (double)pos[12];
      	double total_time = (double)pos[13];
      	double[][] Evol_X = (double[][])pos[14];
      	double[][] Evol_G = (double[][])pos[15];
      	int gen = (int)pos[16];

		PostProcessing.write(gen,fe,ps,runs,Evolution,EvolutionPenalty,BestPosition,BestCost,BestConstraint,BestPenalty,BestEval,WorstCost,mean_BestCost,mean_BestEval,std_BestCost,std_BestEval,mean_run_time,total_time,Evol_X,Evol_G);

	   	PostProcessing.visual(BestCost,BestPosition,BestConstraint,BestPenalty,WorstCost,mean_BestCost,std_BestCost,BestEval, mean_BestEval, std_BestEval,mean_run_time,total_time);
   }
}

// END -----------------------------------------------------------------------+
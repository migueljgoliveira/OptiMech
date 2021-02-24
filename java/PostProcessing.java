// File Name: PostProcessing.java --------------------------------------------+
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
import java.text.SimpleDateFormat;

// MAIN ----------------------------------------------------------------------+
public interface PostProcessing {

   // VARIABLES -------------------------------------------------------------+
   public static Object[] variables(int runs,int fe,int ps) {

         int generations = (int)Math.ceil((double)fe/(double)ps);
         double [][] evolution = new double[runs][generations];
         double [][][] evolutionPosition= new double [runs][generations][];
         double [][][] evolutionConstraints = new double [runs][generations][];
         double [][] evolutionPenalty = new double [runs][generations];
         double [] bestCost = new double[runs];
         double [][] bestPosition = new double[runs][];
         double [][] bestConstraint = new double[runs][];
         double [] bestPenalty = new double[runs];
         double [] bestEval = new double[runs];
         int [] gens = new int[runs];
         double [] run_timer = new double[runs];

         // Wrap settings into object to return
         Object[] vars = new Object[11];
         vars [0] = evolution;
         vars [1] = evolutionPosition;
         vars [2] = evolutionConstraints;
         vars [3] = evolutionPenalty;
         vars [4] = bestCost;
         vars [5] = bestPosition;
         vars [6] = bestConstraint;
         vars [7] = bestPenalty;
         vars [8] = bestEval;
         vars [9] = gens;
         vars [10] = run_timer;

         return vars;
      }

   // EXTRACT RESULTS -------------------------------------------------------+
   public static Object[] result(int i,ArrayList<Double> evol,double[][] evolPos,double[][] evolCons,ArrayList<Double> evolPen,double[] position_Best,double cost_Best,double[] constraint_Best,double penalty_Best,long run_time,double best_Eval,double[][] evolution,double[][][] evolutionPosition,double[][][] evolutionConstraints,double[][] evolutionPenalty,double[][] bestPosition,double[] bestCost,double[][] bestConstraint,double[] bestPenalty,double [] bestEval,double[] run_timer,int[] gens,int gen) {

         // Append Number of Generations per Run
         gens[i] = gen;
         // Append Evaluation in which Best Cost was found
         bestEval[i] = best_Eval;
         // Append Evolution Runs
         for (int j = 0; j < evol.size(); j++) {
            evolution[i][j] = evol.get(j);
         }
         // Append Evolution of Position of Runs
         evolutionPosition[i] = evolPos;
         // Append Evolution of Constraints of Runs
         evolutionConstraints[i] = evolCons;
         // Append Evolution of Penalty of Runs
         for (int j = 0; j < evolPen.size(); j++) {
            evolutionPenalty[i][j] = evolPen.get(j);
         }
         // Append Best Position of runs
         bestPosition[i] = position_Best;
         // Append Best Cost of runs
         bestCost[i] = cost_Best;
         // Append Best Constraints of runs
         bestConstraint[i] = constraint_Best;
         // Append Best Penalty of runs
         bestPenalty[i] = penalty_Best;
         // Append elapsed time of runs
         run_timer[i] = (double)run_time;

         // Wrap settings into object to return
         Object[] res = new Object[11];
         res [0] = evolution;
         res [1] = evolutionPosition;
         res [2] = evolutionConstraints;
         res [3] = evolutionPenalty;
         res [4] = bestPosition;
         res [5] = bestCost;
         res [6] = bestConstraint;
         res [7] = bestPenalty;
         res [8] = bestEval;
         res [9] = run_timer;
         res [10] = gens;

         return res;
      }

   // POST-PROCESSING -------------------------------------------------------+
   public static Object [] post(double[][] evolution,double[][][]evolutionPosition,double[][][] evolutionConstraints,double[][]evolutionPenalty,double[][] bestPosition,double[] bestCost,double[][] bestConstraint,double[] bestPenalty,double[] bestEval,double[] run_timer,long total_timer,int runs,int[] gens) {

         double sum,mean_BestCost,sd,std_BestCost,max,WorstCost,min,BestCost,BestPenalty,mean_run_time,run_time,total_time,mean_BestEval,std_BestEval,BestEval;
         double[] BestPosition,BestConstraint,Evolution,EvolutionPenalty;
         ArrayList<Double> snapBestEval;
         int count;

         // Best Cost of all runs
         min = bestCost[0];
         int BestCost_i = 0;
         for (int i = 1; i < bestCost.length; i++){
            if (bestCost[i] < min) {
               min = bestCost[i];
               BestCost_i = i;
            }
         }
         BestCost = min;
         // Mean Evaluations to Best Solutions
         mean_BestEval = 0;
         count = 0;
         snapBestEval = new ArrayList<Double>();
         for (int j = 0; j < runs; j++) {
            if (bestEval[j] > 0) {
               mean_BestEval += bestEval[j];
               snapBestEval.add(bestEval[j]);
               count += 1;
            }
         }
         if (mean_BestEval > 0) {
            mean_BestEval = mean_BestEval/count;
            // Standard Deviation of Best Solutions Evaluations
            if (count == 1) {
               std_BestEval = 0;
            } else {
               sd = 0;
               for (int i = 0 ; i < snapBestEval.size(); i++) {
                  sd += Math.pow(snapBestEval.get(i) - mean_BestEval, 2)/snapBestEval.size();
               }
               std_BestEval = Math.sqrt(sd);
            }
            // Evaluations in which Best Solution
            min = snapBestEval.get(0);
            for (int i = 1; i < snapBestEval.size(); i++){
               if (snapBestEval.get(i) < min) {
                  min = snapBestEval.get(i);
               }
            }
            BestEval = min;
         } else {
            mean_BestEval = 0;
            std_BestEval = 0;
            BestEval = 0;
         }
         // Best Position for Best Cost
         BestPosition = bestPosition[BestCost_i];
         // Constraints for Best Cost
         BestConstraint = bestConstraint[BestCost_i];
         // Penalty for Best Cost
         BestPenalty = bestPenalty[BestCost_i];
         // Mean of Best Cost of all runs
         sum = 0;
         for (double i:bestCost) { sum += i;}
            mean_BestCost = sum/bestCost.length;
         // Standard Deviation of Best Cost
         sd = 0;
         for (int i = 0 ; i < bestCost.length ; i++) {
            sd += Math.pow(bestCost[i] - mean_BestCost, 2)/bestCost.length;
         }
         std_BestCost = Math.sqrt(sd);
         // Worst Cost of all runs
         max = bestCost[0];
         for (int i = 1; i < bestCost.length; i++){
            if (bestCost[i] > max) { max = bestCost[i]; }
         }
         WorstCost = max;
         // Evolution Mean for X Runs
         int gen = gens[0];
         Evolution = new double[gen];
         for (int it = 0; it < gen; it ++) {
            for (int r = 0 ; r < runs ; r++) {
               Evolution[it] += evolution[r][it];
            }
         }
         for (int item = 0; item < Evolution.length ; item++ ) {
            Evolution[item] = Evolution[item]/runs;
         }
         // Evolution of Design Variables
         double [][] nEvol_X = new double [gen][evolutionPosition[0][0].length];
         for (int i = 0; i < runs ; i++) {
            for (int j = 0; j < gen ; j++) {
               for (int k = 0; k < evolutionPosition[0][0].length; k++) {
                  nEvol_X[j][k] += evolutionPosition[i][j][k];
               }
            }
         }
        double [][] Evol_X = new double [evolutionPosition[0][0].length][gen];
        for (int i = 0; i < gen; i++) {
         for (int j = 0; j < evolutionPosition[0][0].length; j++) {
            Evol_X[j][i] = nEvol_X[i][j]/runs;
         }
        }
         // Evolution of Constraints
         double [][] nEvol_G = new double [gen][evolutionConstraints[0][0].length];
         for (int i = 0; i < runs ; i++) {
            for (int j = 0; j < gen ; j++) {
               for (int k = 0; k < evolutionConstraints[0][0].length; k++) {
                  nEvol_G[j][k] += evolutionConstraints[i][j][k];
               }
            }
         }
        double [][] Evol_G = new double [evolutionConstraints[0][0].length][gen];
        for (int i = 0; i < gen; i++) {
         for (int j = 0; j < evolutionConstraints[0][0].length; j++) {
            Evol_G[j][i] = nEvol_G[i][j]/runs;
         }
        }
         // Evolution Penalty Mean of Runs
         EvolutionPenalty = new double[gen];
         for (int it = 0; it < gen; it ++) {
            for (int r = 0 ; r < runs ; r++) {
               EvolutionPenalty[it] += evolutionPenalty[r][it];
            }
         }
         for (int item = 0; item < EvolutionPenalty.length ; item++ ) {
            EvolutionPenalty[item] = EvolutionPenalty[item]/runs;
         }
         // Mean/Total Time of all runs
         run_time = 0;
         for (double i:run_timer) { run_time += i;}
         run_time = run_time*1e-9;
         mean_run_time = (run_time/run_timer.length);
         // Total Time
         total_time = (double)total_timer*1e-9;

         // Wrap settings into object to return
         Object[] pos = new Object[19];
         pos [0] = Evolution;
         pos [1] = EvolutionPenalty;
         pos [2] = BestCost;
         pos [3] = BestPosition;
         pos [4] = BestConstraint;
         pos [5] = BestPenalty;
         pos [6] = BestEval;
         pos [7] = WorstCost;
         pos [8] = mean_BestCost;
         pos [9] = mean_BestEval;
         pos [10] = std_BestCost;
         pos [11] = std_BestEval;
         pos [12] = mean_run_time;
         pos [13] = total_time;
         pos [14] = Evol_X;
         pos [15] = Evol_G;
         pos [16] = gen;

         return pos;
      }

      // WRITE TO FILES ------------------------------------------------------+
      public static Object[] write(int gen, int fe,int ps,int runs,double[]Evolution,double[] EvolutionPenalty,double[]BestPosition,double BestCost,double[] BestConstraint,double BestPenalty,double BestEval,double WorstCost,double mean_BestCost,double mean_BestEval,double std_BestCost,double std_BestEval,double mean_run_time,double total_time,double[][] Evol_X,double[][] Evol_G)throws IOException {

         SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
         Date date = new Date();

         File file = new File("Results.txt");
         file.createNewFile();
         FileWriter writer = new FileWriter(file,true);
         writer.write("\nDate: " + formatter.format(date)+ "\n");
         writer.write("\n +++ PARAMETERS +++ \n\n");
         writer.write("Runs: " + runs + "\n");
         writer.write("Generations: " + gen + "\n");
         writer.write("Function Evaluations: " + fe + "\n");
         writer.write("Population Size: " + ps + "\n");
         writer.write("\n +++ COST EVOLUTION +++ \n\n");
         for (int i = 0; i < Evolution.length ; i++) {
            writer.write(String.format("%.6f", Evolution[i]) + "\n");
         }
         writer.write("\n +++ DESIGN VARIABLES EVOLUTION +++ \n\n");
         for (int i = 0; i < Evol_X[0].length ; i++) {
           for (int j = 0; j < Evol_X.length ; j++) {
              writer.write(String.format("%.6f", Evol_X[j][i]) + " ");
           }
           writer.write("\n");
         }
         writer.write("\n +++ CONSTRAINTS EVOLUTION +++ \n\n");
         for (int i = 0; i < Evol_G[0].length ; i++) {
           for (int j = 0; j < Evol_G.length ; j++) {
             writer.write(String.format("%.6f", Evol_G[j][i]) + " ");
           }
           writer.write("\n");
         }
         writer.write("\n +++ PENALTY EVOLUTION +++ \n\n");
         for (int i = 0; i < EvolutionPenalty.length ; i++) {
           writer.write(String.format("%.6f", EvolutionPenalty[i]) + "\n");
         }
         writer.write("\n +++ FINAL RESULTS ++ \n\n");
         writer.write("Best Position: " + Arrays.toString(BestPosition) + "\n");
         writer.write("Best Cost: " + String.format("%.6f", BestCost) + "\n");
         writer.write("Constraints: " + Arrays.toString(BestConstraint) + "\n");
         writer.write("Penalty: " + String.format("%.6f", BestPenalty) + "\n");
         writer.write("Worst Cost: " + String.format("%.6f", WorstCost) + "\n");
         writer.write("Mean Best Cost: " + String.format("%.6f",mean_BestCost) + "\n");
         writer.write("Std. Best Cost: " + String.format("%.6f", std_BestCost) + "\n");
         writer.write("Evaluations: " + BestEval + "\n");
         writer.write("Mean Evaluations: " + mean_BestEval + "\n");
         writer.write("Std. Evaluations: " + std_BestEval + "\n");
         writer.write("Mean Run Time: " + mean_run_time + " sec\n");
         writer.write("Total Time: " + total_time + " sec\n");
         writer.write("\n+++++++++++++++++++++++++++++++++++++++++++\n");
         writer.close();

         // Wrap settings into object to return
         Object[] wri = new Object[0];

         return wri;
      }

      // VISUAL --------------------------------------------------------------+
      public static Object[] visual(double BestCost,double[] BestPosition,double[] BestConstraint,double BestPenalty,double WorstCost,double mean_BestCost,double std_BestCost,double BestEval,double mean_BestEval,double std_BestEval,double mean_run_time,double total_time) {

         System.out.println("\n + --------- FINAL RESULTS --------- + \n");
         System.out.println("Best Position: " + Arrays.toString(BestPosition));
         System.out.println("Best Cost: " + String.format("%.6f", BestCost));
         System.out.println("Constraints: " + Arrays.toString(BestConstraint));
         System.out.println("Penalty: " + String.format("%.6f", BestPenalty));
         System.out.println("Worst Cost: " + String.format("%.6f", WorstCost));
         System.out.println("Mean Best Cost: " + String.format("%.6f", mean_BestCost));
         System.out.println("Std. Best Cost: " + String.format("%.6f", std_BestCost));
         System.out.println("Evaluations: " + BestEval);
         System.out.println("Mean Evaluations: " + mean_BestEval);
         System.out.println("Std. Evaluations: " + std_BestEval);
         System.out.println("Mean Run Time: " + mean_run_time + " sec");
         System.out.println("Total Time: " + total_time + " sec");
         System.out.println("Optimization Complete! See Results :) \n");

         // Wrap settings into object to return
         Object[] vis = new Object[0];

         return vis;
      }
}

// END -----------------------------------------------------------------------+
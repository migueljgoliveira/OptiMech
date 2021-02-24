// File Name: problem.java ---------------------------------------------------+
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

// MAIN ----------------------------------------------------------------------+
public interface Reducer {

   // SET DIMENSION AND BOUNDS -----------------------------------------------+
   public static Object[] setting() {

	  double vmax,vmin;
      double[] bound_x1,bound_x2,bound_x3,bound_x4,bound_x5,bound_x6,bound_x7;

      // Number of Design Variables
      int D = 7;
      // Search Range of Design Variables
      bound_x1 = new double[] {2.6, 3.6}; // Face Width
      bound_x2 = new double[] {0.7, 0.8}; // Module of Teeth
      bound_x3 = new double[] {17, 29};   // Number of Teeth Pinion
      bound_x4 = new double[] {7.3, 8.3}; // Lenght First Shaft
      bound_x5 = new double[] {7.8, 8.3}; // Lenght Second Shaft
      bound_x6 = new double[] {2.9, 3.9}; // Diameter First Shaft
      bound_x7 = new double[] {5.0, 5.5}; // Diameter Second Shaft

      double [][] bounds_x = {bound_x1,bound_x2,bound_x3,bound_x4,bound_x5,bound_x6,bound_x7};

	  // Velocity Range of Design Variables (only for PSO)
      double [][] bounds_v = new double[D][2];

      for (int i = 0; i < D ; i++ ) {
         vmax = (bounds_x[i][1]-bounds_x[i][0])/2;
         vmin = -vmax;
         bounds_v[i][0] = vmin;
         bounds_v[i][1] = vmax;
      }

      // Wrap settings into object to return
      Object[] settings = new Object[3];
      settings [0] = D;
      settings [1] = bounds_x;
	  settings [2] = bounds_v;

      return settings;
   }

   // SET INITIAL VALUES -----------------------------------------------------+
   public static double[] initial(int D, double [][] bounds_x) {

      double xval;
      double[] x0 = new double[D];

      for (int i = 0; i < D; i++) {
         xval = bounds_x[i][0]+Math.random()*(bounds_x[i][1]-bounds_x[i][0]);
         if (i == 2) {
            xval = Math.floor(xval);
         }
         x0[i] = xval;
      }

      return x0;
   }

   // OBJECTIVE FUNCTION -----------------------------------------------------+
   public static Object[] costFunc(double[] x, int i) {
      double f1, f2, f3, f4, f, F;
      x[2] = Math.floor(x[2]);

      // UNCONSTRAINED OBJECTIVE FUNCTION
      f1 = 0.7854*x[0]*Math.pow(x[1],2)*(3.3333*Math.pow(x[2],2)+14.9334*x[2]-43.0934);
      f2 = 1.508*x[0]*(Math.pow(x[5],2)+Math.pow(x[6],2));
      f3 = 7.4777*(Math.pow(x[5],3)+Math.pow(x[6],3));
      f4 = 0.7854*(x[3]*Math.pow(x[5],2) + x[4]*Math.pow(x[6],2));
      f = f1 - f2 + f3 + f4;

      // CONSTRAINTS FUNCTION
      double[] Gj = constraints(x);

      // PENALTY FUNCTION
      double P = penalty(Gj,i);

      // CONSTRAINED OBJECTIVE FUNCTION
      F = f + P;

      // Wrap results into object to return
      Object[] results = new Object[4];
      results [0] = F;
      results [1] = Gj;
      results [2] = P;
      results [3] = x;

      return results;
   }

   // CONSTRAINTS FUNCTION ---------------------------------------------------+
   public static double[] constraints(double[] x) {

      double g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,g11;

      g1 = 27.0*(1/(x[0]*Math.pow(x[1],2)*x[2])) - 1;
      g2 = 397.5*(1/(x[0]*Math.pow(x[1],2)*Math.pow(x[2],2))) - 1;
      g3 = 1.93*(Math.pow(x[3],3)/(x[1]*x[2]*Math.pow(x[5],4))) - 1;
      g4 = 1.93*(Math.pow(x[4],3)/(x[1]*x[2]*Math.pow(x[6],4))) - 1;
      g5 = ((1.0/(110.0*Math.pow(x[5],3)))*(Math.pow((Math.pow((745.0*x[3]/(x[1]*x[2])),2)+16.9e6),0.5))) - 1;
      g6 = ((1.0/(85.0*Math.pow(x[6],3)))*Math.pow(Math.pow(745.0*x[4]/(x[1]*x[2]),2)+157.5e6,0.5)) - 1;
      g7 = x[1]*x[2]*(1.0/40) - 1;
      g8 = 5.0*(x[1]/x[0]) - 1;
      g9 = (1.0/12)*(x[0]/x[1]) - 1;
      g10 = (1.0/x[3])*(1.5*x[5]+1.9)  - 1;
      g11 = (1.0/x[4])*(1.1*x[6]+1.9) - 1;

      double[] Gj = {g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,g11};

      return Gj;
   }

   // PENALTY FUNCTION -------------------------------------------------------+
   public static double penalty(double[] Gj,int i) {

      double D , P;
      int C = 60;
      int a = 2;
      int B = 1;
      double svc = 0;

      for (int j = 0; j < Gj.length ; j++) {
         if (Gj[j] <= 0) {
            D = 0;
         }
         else {
            D = Math.abs(Gj[j]);
         }
         svc = svc + Math.pow(D,B);
      }

      P = Math.pow(C*i,a)*svc;

      return P;
   }

}

// END -----------------------------------------------------------------------+
// File Name: Driver.java ----------------------------------------------------+
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
public class Driver implements Reducer{

   public static void main(String []args) {

   		System.out.println("+++ OptiMeta +++\n");

	   	double[] x,Gj;
	   	int i;
	   	double F, P;
	   	Object[] results;

	   	x = new double[] {3.49999, 0.6999, 17.0, 7.3, 7.8, 3.3502, 5.2866};
	   	i = 1;

	   	results = Reducer.costFunc(x,i);

	   	F = (double)results[0];
	   	Gj = (double[])results[1];
	   	P = (double)results[2];

	   	System.out.println("Cost = " + F);
	   	System.out.println("Constraints = " + Arrays.toString(Gj));
	   	System.out.println("Penalty = " + P);
   }
}

// END -----------------------------------------------------------------------+
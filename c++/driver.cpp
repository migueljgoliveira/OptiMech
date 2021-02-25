// File Name: driver.cpp -----------------------------------------------------+
// ---------------------------------------------------------------------------+
//
//  Miguel G. Oliveira
//  Dissertation
//  MSc in Mechanical Engineer
//  University of Aveiro
//
// ---------------------------------------------------------------------------+

// IMPORT PACKAGES -----------------------------------------------------------+
#include <iostream>
#include <iomanip>
#include <math.h>
#include <vector>
using namespace std;

// IMPORT FILES --------------------------------------------------------------+
#include "problem.cpp"

int main()
{
  vector<double> Gj;
  double F,P;

  cout << "+++ OptiMeta +++" << endl;
  vector<double> x = {3.49999, 0.6999, 17.0, 7.3, 7.8, 3.3502, 5.2866};
  Gj = {};
  int i = 1;

  costFunc(x,i,F,Gj,P);

  cout << "\nCost = " << setprecision(17) << F << endl;;
  cout << "Constraints = [ ";
     for (int n = 0; n < 11; ++n) cout << setprecision(17) << Gj[n] << ' '; cout << ']' << endl;
  cout << "Penalty = " << setprecision(17) << P << endl;

  return 0;
}

// END -----------------------------------------------------------------------+

// File Name: Reducer.cpp ----------------------------------------------------+
// ---------------------------------------------------------------------------+
//
//  Miguel G. Oliveira
//  Dissertation
//  MSc in Mechanical Engineer
//  University of Aveiro
//
// Description:  --------------------------+
// ---------------------------------------------------------------------------+

// SET BOUNDS ----------------------------------------------------------------+
void setting(int &D,vector< vector<double> > &bounds_x,vector< vector<double> > &bounds_v)
{
	vector<double> bound_x1,bound_x2,bound_x3,bound_x4,bound_x5,bound_x6,bound_x7;
	double vmax,vmin;

	// Number of Design Variables
	D = 7;
	// Search Range of Design Variables
    bound_x1.push_back(2.6); bound_x1.push_back(3.6);
    bound_x2.push_back(0.7); bound_x2.push_back(0.8);
    bound_x3.push_back(17.0); bound_x3.push_back(29.0);
    bound_x4.push_back(7.3); bound_x4.push_back(8.3);
    bound_x5.push_back(7.8); bound_x5.push_back(8.3);
    bound_x6.push_back(2.9); bound_x6.push_back(3.9);
    bound_x7.push_back(5.0); bound_x7.push_back(5.5);

    bounds_x.push_back(bound_x1);
    bounds_x.push_back(bound_x2);
    bounds_x.push_back(bound_x3);
    bounds_x.push_back(bound_x4);
    bounds_x.push_back(bound_x5);
    bounds_x.push_back(bound_x6);
    bounds_x.push_back(bound_x7);

	// Velocity Range of Design Variables (only for PSO)
    for (int i = 0; i < bounds_x.size(); ++i)
    {
    	vmax = (bounds_x[i][1] - bounds_x[i][0])/2;
    	vmin = -vmax;
    	vector<double> bound_v;
    	bound_v.push_back(vmin);
    	bound_v.push_back(vmax);
    	bounds_v.push_back(bound_v);
    }


}

// SET INITIAL VALUES --------------------------------------------------------+
void initial(int D,vector<double>& position_i,vector< vector<double> > bounds_x)
{
	double xval;

	position_i.resize(D);
	for (int i = 0; i < D; ++i)
	{
		xval = bounds_x[i][0] + ((double) rand()/RAND_MAX)*(bounds_x[i][1]-bounds_x[i][0]);
		if (i == 2)
		{
			xval = floor(xval);
		}
		position_i[i] = xval;
	}
}


// SET INITIAL VALUES FOR PSO ------------------------------------------------+
void initial_pso(int D,vector<double>& position_i,vector<double>& velocity_i,vector< vector<double> > bounds_x,vector< vector<double> > bounds_v)
{
	double xval,vval;

	position_i.resize(D);
	velocity_i.resize(D);
	for (int i = 0; i < D; ++i)
	{
		xval = bounds_x[i][0] + ((double) rand()/RAND_MAX)*(bounds_x[i][1]-bounds_x[i][0]);
		vval = bounds_v[i][0] + ((double) rand()/RAND_MAX)*(bounds_v[i][1]-bounds_v[i][0]);
		if (i == 2)
		{
			xval = floor(xval);
		}
		position_i[i] = xval;
		velocity_i[i] = vval;
	}
}

// CONSTRAINTS FUNCTION ------------------------------------------------------+
void constraints(vector<double>& x,vector<double>& Gj)
{
	Gj.resize(11);
	Gj[0] = 27.0*(1/(x[0]*pow(x[1],2)*x[2])) - 1;
    Gj[1] = 397.5*(1/(x[0]*pow(x[1],2)*pow(x[2],2))) - 1;
    Gj[2] = 1.93*(pow(x[3],3)/(x[1]*x[2]*pow(x[5],4))) - 1;
    Gj[3] = 1.93*(pow(x[4],3)/(x[1]*x[2]*pow(x[6],4))) - 1;
    Gj[4] = ((1.0/(110.0*pow(x[5],3)))*(pow((pow((745.0*x[3]/(x[1]*x[2])),2)+16.9e6),0.5))) - 1;
    Gj[5] = ((1.0/(85.0*pow(x[6],3)))*pow(pow(745.0*x[4]/(x[1]*x[2]),2)+157.5e6,0.5)) - 1;
    Gj[6] = x[1]*x[2]*(1.0/40) - 1;
    Gj[7] = 5.0*(x[1]/x[0]) - 1;
    Gj[8] = (1.0/12)*(x[0]/x[1]) - 1;
    Gj[9] = (1.0/x[3])*(1.5*x[5]+1.9)  - 1;
    Gj[10] = (1.0/x[4])*(1.1*x[6]+1.9) - 1;
}

// PENALTY FUNCTION ----------------------------------------------------------+
void penalty(vector<double> Gj,int& i,double& P)
{
	int C,a,B;
	double SVC,D;

	C = 60;
	a = 2;
	B = 1;
	SVC = 0.0;

	for (int j = 0; j < Gj.size(); ++j)
	{
		if (Gj[j] <= 0.0)
  			D = 0;
		else
  			D = abs(Gj[j]);

  		SVC += pow(D,B);
  	}

  	P =  pow(C*i,a)*SVC;
}

// OBJECTIVE FUNCTION --------------------------------------------------------+
void costFunc(vector<double>& x,int i,double &F,vector<double>& Gj,double &P)
{
	double f1,f2,f3,f4,f;

	x[2] = floor(x[2]);

	// UNCONSTRAINED OBJECTIVE FUNCTION
	f1 = 0.7854*x[0]*pow(x[1],2)*(3.3333*pow(x[2],2) + 14.9334*x[2] - 43.0934);
	f2 = 1.508*x[0]*(pow(x[5],2) + pow(x[6],2));
	f3 = 7.4777*(pow(x[5],3) + pow(x[6],3));
	f4 = 0.7854*(x[3]*pow(x[5],2) + x[4]*pow(x[6],2));
	f = f1 - f2 + f3 + f4;

	// CONSTRAINTS FUNCTION
	constraints(x,Gj);

	// PENALTY FUNCTION
	penalty(Gj,i,P);

	// CONSTRAINED OBJECTIVE FUNCTION
	F = f + P;
}

// END -----------------------------------------------------------------------+
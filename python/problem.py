# File Name: problem.py ------------------------------------------------------+
# ----------------------------------------------------------------------------+
#
#   Miguel G. Oliveira
#   Dissertation 
#   MSc in Mechanical Engineer
#   University of Aveiro
#
# ----------------------------------------------------------------------------+

# IMPORT PACKAGES ------------------------------------------------------------+
import numpy as np
import math
import random

# SET DIMENSION AND BOUNDS ---------------------------------------------------+
def setting():
	# Number of Design Variables
	D = 3

	# Search Range of Design Variables
	bound_x1 = (0, 2)
	bound_x2 = (0, 2)
	bound_x3 = (0, 2)

	bounds_x = [bound_x1, bound_x2, bound_x3]

	# Velocity Range of Design Variables (only for PSO)
	bounds_v = []
	for i in range(0,D):
		vmax = (bounds_x[i][1]-bounds_x[i][0])/2    # Max velocity
		vmin = -vmax    							# Min velocity
		bound_v = (vmin,vmax)
		bounds_v.append(bound_v)

	return D,bounds_x,bounds_v

# SET INITIAL VALUES DE ------------------------------------------------------+
def initial(D,bounds_x):
	# Initial Values (X0) of Design Variables
	x0 = []
	for i in range(0,D):
		xval = bounds_x[i][0]+np.random.rand()*(bounds_x[i][1]-bounds_x[i][0])
		x0.append(xval)

	return x0

# SET INITIAL VALUES PSO -----------------------------------------------------+
def initial_pso(D,bounds_x,bounds_v):
	# Initial Values (X0,V0) of Design Variables
	x0 = []
	v0 = []
	for i in range(0,D):
		xval = bounds_x[i][0]+np.random.rand()*(bounds_x[i][1]-bounds_x[i][0])
		vval = bounds_v[i][0]+np.random.rand()*(bounds_v[i][1]-bounds_v[i][0])
		x0.append(xval)
		v0.append(vval)

	return x0,v0

# CONSTRAINTS ----------------------------------------------------------------+
def constraints(x):
	# INEQUALITY CONSTRAINTS
	# g1 = ...
	# g2 = ...

	# Gj = [g1,...]
	Gj = []

	return Gj

# PENALTY FUNCTION -----------------------------------------------------------+
def penalty(Gj,i):
	C = 60
	a = 2
	B = 1
	SVC = 0
	for j in range(0,len(Gj)):
		if Gj[j] <= 0:
			D = 0
		else:
			D = abs(Gj[j])

		SVC += D**B
	P = ((C*i)**a)*SVC

	return P

# OBJECTIVE FUNCTION ---------------------------------------------------------+
def costfunc(x,i):
	x = np.array(x)

	# UNCONSTRAINED OBJECTIVE FUNCTION
	f = sum(100.0*(x[1:]-x[:-1]**2.0)**2.0 + (1-x[:-1])**2.0)

	# CONSTRAINTS FUNCTION
	Gj = constraints(x)

	# PENALTY FUNCTION
	P = penalty(Gj,i)

	# CONSTRAINED OBJECTIVE FUNCTION
	F = f + P

	return F,x,Gj,P

# END ------------------------------------------------------------------------+
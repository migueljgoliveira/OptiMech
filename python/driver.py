# File Name: driver.py -------------------------------------------------------+
# ----------------------------------------------------------------------------+
#
#   Miguel G. Oliveira
#   Dissertation 
#   MSc in Mechanical Engineer
#   University of Aveiro
#
# ----------------------------------------------------------------------------+

# IMPORT FILES ---------------------------------------------------------------+
from problem import costfunc

# MAIN -----------------------------------------------------------------------+
def main():
	print ('+++ OptiMech - Driver +++')

	x, i = [2.0,2.0,2.0], 1
	F,x,Gj,P = costfunc(x,i)

	print ('Cost = %r' % F)
	print ('Constraints = %r' % Gj)
	print ('Penalty = %r' % P)

if __name__ == "__main__":
	main()


# END ------------------------------------------------------------------------+
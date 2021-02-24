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
	print ('+++ OptiMeta - Driver +++')

	x, i = [1.0,1.0,1.0], 1
	F,x,Gj,P = costfunc(x,i)

	print ('Cost = %r' % F)
	print ('Constraints = %r' % Gj)
	print ('Penalty = %r' % P)

if __name__ == "__main__":
	main()


# END ------------------------------------------------------------------------+
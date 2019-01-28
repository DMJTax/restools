import numpy
from restools import *

# generate some artificial outcomes
x = numpy.abs(numpy.random.randn(4,2,10))
# annotation of axes
val1 = [1.5,20,3.333,4]
val2 = ['method A','method Bb']
val3 = 10       
# and store:
R = results(x,val1,val2,val3)
R.name = 'EersteResultaten'
R.set_dimnames(['experiment','model','folds'])
print(R)
# show the first slice of results:
R[:,:,0].show()

# average over the third dim
S = R.average(2)
print(S)
S.show()

# average over the third dim, and highlight the maximum value of each
# column (and all values that are not significantly worse)
S1 = R.average(2,boldtype='max0',testtype='dep')
print(S1)
S1.show()

# you can do simple operations on the results
S2 = 100.*R
S3 = S2.average(2,boldtype='max0',testtype='dep')
S3.show('latex')      # you can show it in Latex
S3.T().show('latex')  # or show the transposed matrix



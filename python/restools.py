# RESULTS module in Python
#
# This is a port of the Restools from Matlab (restools 1.8.1). For an
# example on how to use this toolbox, look at testrestools.py
#
# This toolbox is a general toolbox that should make it simpler to
# collect experimental results, annotate them, plot/print/show them in
# countless formats (like graphs, text tables, latex tables, html tables,
# bar graphs, surface graphs) and store them.
#
# For this a new Matlab object 'results' is created. The idea of the results-object is:
# 1. To extend the Matlab matrix with 'feature annotations', such that
#    printing a matrix also shows the meaning of each row and column
# 2. To be able to print the content of a matrix consistently in
#    different formats (like text, latex, in a graph, etc)
#    This is done by the command  show()
# 3. To extend the averaging over a dimension such that significantly
#    different entries in a matrix are highlighted, and such that missing
#    values (=NaN's) are handled correctly
#    This is done by the command  average()
#
# Standard mathematical operations, like +,-,*,/, are all defined.
#
# The average command works like:
#   S = R.average(DIM, BOLDTYPE, TESTTYPE)
# 
# Average the results in object R along dimension DIM. When dimension
# DIM has more than one element, both the mean and standard error of the
# mean is computed. Furthermore, it is checked which values are
# significantly different. This significance test is performed along the
# dimension indicated by BOLDTYPE:
#
#   BOLDTYPE = 'max0' find the elements along dimension 0 that is not
#                     significantly worse than the max value
#   BOLDTYPE = 'min2' find the elements along dimension 2 that is not
#                     significantly higher than the min value
#
# Finally, TESTTYPE indicates if the significance test can assume that
# the elements along the dimension mentioned in BOLDTYPE should be the
# same, or are independently drawn from a distribution:
#   TESTTYPE = 'win'  only give the winning entry (this means no
#                     significance is computed)
#            = 'dep'  assume idetically sampled (this means that a
#                     T-test on the differences is done to see if the
#                     differences are significantly different from
#                     zero: the paired-differences T-test on n-fold
#                     crossvalidation )
#            = 'ind'  assume independent samples (default, this means
#                     that only a T-test on the differences in the
#                     means is performed)
# For this ttest per default a significance level of 5% is used.
#

import numpy
import scipy.stats
import copy   # I hate python
import matplotlib.pyplot as plt
import pickle

# === results object ===
class results(object):
    "Results object to store experimental results"

    def __init__(self,res,*args):
        self.name = ''
        self.res = res
        sz = res.shape
        nrd = len(sz)

        dimnames = ['Dim 0']
        for i in range(1,nrd):
            dimnames.append('Dim '+str(i))
        self.dimnames=dimnames

        self.dim = [None for i in range(nrd)]
        self.ismeanstd = False

        if (len(args)==0):
            for i in range(0,nrd):
                self.dim[i] = list(map(str,range(sz[i]))) #DXD: check!!
        else:  # the dimension values are supplied:
            if (len(args)!=nrd):
                raise ValueError('I am expecting %d input arguments'%(nrd+1))
            for i in range(0,nrd):
                if (isinstance(args[i],(int,numpy.int))):
                    self.dim[i] = list(map(str,range(0,args[i])))
                else:
                    if (len(args[i])!=sz[i]):
                        raise ValueError('Nr elements in dim %d should be %d.'%(i,sz[i]))
                    if (isinstance(args[i][0],str)):
                        self.dim[i] = args[i]
                    else:
                        self.dim[i] = map(str,args[i])

    def __str__(self):
        sz = self.res.shape
        out = 'Results '
        if (len(self.name)>0):
            out += self.name + ','
        nr = len(self.dimnames)
        if (nr>0):
            if (len(sz)!=nr):
                raise ValueError('Number of dim.names inconsistent.')
            if (len(self.dim[0])!=sz[0]):
                raise ValueError('Number of values in dim 0 inconsistent.')
            out += ' [%d'%len(self.dim[0])
            for i in range(1,nr):
                if (len(self.dim[i])!=sz[i]):
                    raise ValueError('Number of values in dim %d inconsistent.'%i)
                out += 'x%d'%len(self.dim[i])
            out += ']'
            out += ' [%s'%self.dimnames[0]
            for i in range(1,nr):
                out += ',%s'%self.dimnames[i]
            out += ']'
        return(out)

    def __getitem__(self,key):
        newr = copy.deepcopy(self)
        newr.res = newr.res[key]
        for i in range(0,len(key)):
            newr.dim[i] = newr.dim[i][key[i]]
        return newr

    def get_name(self):
        return self.name
    def set_name(self,name):
        self.name = name
    def get_dimnames(self):
        return self.dimnames
    def set_dimnames(self,names):
        if (len(names)!=len(self.res.shape)):
            raise ValueError('Nr elements in "dimnames" does not fit the data.')
        self.dimnames = names
    def shape(self):
        return self.res.shape

    def __add__(self,other):  # should I make a copy???
        newr = copy.deepcopy(self)
        if (isinstance(other,results)):
            other = other.float()
        newr.res += other
        return newr
    def __sub__(self,other):
        newr = copy.deepcopy(self)
        if (isinstance(other,results)):
            other = other.float()
        newr.res -= other
        return newr
    def __mul__(self,other):
        newr = copy.deepcopy(self)
        if (isinstance(other,results)):
            other = other.float()
        newr.res *= other
        return newr
    def __rmul__(self,other):
        newr = copy.deepcopy(self)
        if (isinstance(other,results)):
            other = other.float()
        newr.res *= other
        return newr
    def __div__(self,other):
        newr = copy.deepcopy(self)
        if (isinstance(other,results)):
            other = other.float()
        newr.res /= other
        return newr

    def float(self):
        return self.res.copy()

    def permute(self,neworder):
        sz = self.res.shape
        dim = len(sz)
        if (dim!=len(neworder)):
            raise ValueError('Permutation vector does not fit results matrix.')
        self.res = numpy.transpose(self.res,neworder) # WTF: 'transpose'???
        self.dimnames = tuple(self.dimnames[i] for i in neworder)
        self.dim = tuple(self.dim[i] for i in neworder)
        return self

    def transpose(self):
        sz = self.res.shape
        if (len(sz)==3):
            # maybe we have results that already averaged:
            if (self.ismeanstd):  # yes!
                I = self.dimnames.index('Average')
                if (I==0): # don't make the programming too difficult: 
                    self.permute([0,2,1])
                elif (I==1):
                    self.permute([2,1,0])
                else:
                    self.permute([1,0,2])
                return self
            else:
                raise ValueError('Transpose is only defined for 2D data.')
        if (len(sz)>2):
            raise ValueError('Transpose is only defined for 2D data.')
        self.res = self.res.transpose()
        self.dimnames = tuple(self.dimnames[i] for i in [1,0])
        self.dim = tuple(self.dim[i] for i in [1,0])
        return self

    def T(self):
        return self.transpose()

    def squeeze(self):
        sz = self.res.shape
        if (len(sz)<=2):
            return self
        I = [i for i,x in enumerate(sz) if x==1] # my god..
        self.res = self.res.squeeze()
        for i in reversed(I): # start from the back to not screw-up indices
            del self.dimnames[i]
            del self.dim[i]
        return self

    def shiftdim(self,src,target):
        if (src==target):
            return self
        sz = self.res.shape
        I = list(range(len(sz)))
        I[src] = target
        I[target] = src
        self.permute(I)
        return self

    def extenddim(self):
        sz = self.res.shape
        self.res = numpy.expand_dims(self.res,len(sz))
        self.dimnames.append('New dim')
        self.dim.append(['0'])
        return self

    def concatenate(self,other,axis=0):
        sz = self.shape()
        sz2 = other.shape()
        if (len(sz)!=len(sz2)):
            raise ValueError('Dimensionalities do not match.')
        for i in range(0,len(sz)):
            if (i!=axis):
                if (sz[i]!=sz2[i]):
                    raise ValueError('Dimension %d do not fit.'%i)
                if (self.dim[i]!=other.dim[i]):
                    raise ValueError('Dimension values %d do not fit.'%i)
        self.res = numpy.concatenate((self.res,other.res),axis=axis)
        self.dim[axis] = self.dim[axis]+other.dim[axis]
        return self


    def average(self,dim=0, boldtype=None, testtype='ind', alpha=0.05):
        sz = self.res.shape
        if (dim>len(sz)):
            raise ValueError('Cannot take average over dim %d.' % dim)
        if (len(sz)==2):
            self.extenddim()
            self.dimnames[2] = 'Average'
            self.dim[2] = ['']
            sz = self.res.shape
        newmean = numpy.nanmean(self.res,axis=dim)
        newstd = numpy.nanstd(self.res,axis=dim)
        newI = numpy.zeros(newmean.shape)
        if (boldtype is not None):
            newI = findsignif(self.res,dim,boldtype,testtype,alpha)

        newr = copy.deepcopy(self)
        newr.res = numpy.stack((newmean,newstd,newI),axis=dim)
        newr.dimnames[dim] = 'Average'
        newr.dim[dim] = ['mean','std','signif']
        newr.ismeanstd = True
        return newr


    def show(self, type = 'text', numformat = '%4.1f'):
        thisres = copy.deepcopy(self)
        sz = thisres.res.shape
        if (thisres.ismeanstd):
            if (len(sz)>3):
                raise ValueError('Show can only show averaged 2D data.')
            numformat = '%s (%s)' % (numformat,numformat)
            I = thisres.dimnames.index('Average')
            # exceptions exceptions.. :
            if (len(sz)==2):
                thisres.extenddim()
            thisres.shiftdim(I,2)
            sz = thisres.res.shape
            cellwidth = len(numformat % (1.23456789,1.23456789))
        else:
            if (len(sz)>2):
                raise ValueError('Show can only show 2D data.')
            cellwidth = len(numformat % 1.23456789)
        # setup parameters
        if (type=='text'):
            sep = ' | '
            endline = ' |'
            hl = '-'
            hlsep = '-+-'
            hlend = '-+'
            bstart = chr(27)+'[1m'
            bend = chr(27)+'[0;0m'
        elif (type=='latex'):
            sep = ' & '
            endline = ' \\\\'
            hl = ''
            hlsep = ''
            hlend = '\\hline '
            bstart = '{\\bf '
            bend = '}'
        else:
            raise ValueError('Plotting type %s is not defined.'%type)
        # first headerline
        w0=0
        for i in range(sz[0]):
            w0 = max(w0,len(thisres.dim[0][i]))
        w0 = max(w0,len(thisres.dimnames[0]))
        headline0 = ' '*w0 + sep +thisres.dimnames[1] + endline
        print(headline0)
        # second headerline
        w0str = '%'+str(w0)+'s'
        headline1 = w0str % thisres.dimnames[0]
        w1str = sep+'%'+str(cellwidth)+'s'
        for j in range(0,sz[1]):
            headline1 += w1str%thisres.dim[1][j] 
        print(headline1+endline)
        # third headerline
        headline2 = hl*w0 
        for j in range(0,sz[1]):
            headline2+=  hlsep + hl*cellwidth
        print(headline2+hlend)
        # the rest:
        for i in range(0,sz[0]):
            newstr =  w0str % thisres.dim[0][i]
            for j in range(0,sz[1]):
                if (thisres.ismeanstd):  # we should write  num (num)
                    if (thisres.res[i,j,2]==0):
                        newstr += sep+numformat % (thisres.res[i,j,0],thisres.res[i,j,1])
                    else:
                        newstr += sep+bstart+\
                                numformat % (thisres.res[i,j,0],thisres.res[i,j,1])+bend
                else:
                    newstr += sep+numformat % thisres.res[i,j]
            newstr += endline
            print(newstr)

    def plot(self,linestyle='-'):
        thisres = copy.deepcopy(self)
        sz = thisres.res.shape
        if (thisres.ismeanstd):
            if (len(sz)>3):
                raise ValueError('Plot can only plot averaged 2D data.')
            I = thisres.dimnames.index('Average')
            # exceptions exceptions.. :
            if (len(sz)==2):
                thisres.extenddim()
            thisres.shiftdim(I,2)
            sz = thisres.res.shape
        else:
            if (len(sz)>2):
                raise ValueError('Plot can only plot 2D data.')

        xticklabs = thisres.dim[0]
        xvals = range(sz[0])
        for i in range(sz[1]):
            plt.errorbar(xvals,thisres.res[:,i,0], thisres.res[:,i,1],label=thisres.dim[1][i],linestyle=linestyle,ecolor='b')
        plt.legend()
        plt.xticks(xvals,xticklabs)

    def save(self,fname):
        fid = open(fname,'w')
        pickle.dump(self,fid)
        fid.close()

def load(fname):
    fid = open(fname,'r')
    R = pickle.load(fid)
    fid.close()
    return R



def ttest_dep(bestx,x):
    K = len(bestx)
    df = bestx-x
    meandf = numpy.mean(df)
    stddf = numpy.std(df)
    # if we have zero variance, all differences are significant:
    tol = 1e-6
    if (stddf<tol):
        # wait: the means can also be the same!
        if (meandf<tol):
            return 0.5
        else:
            return 0.
    t = numpy.sqrt(K)*meandf/stddf
    return scipy.stats.t.cdf(-t,K-1)

def ttest_indep(bestx,x):
    n1 = len(bestx)
    n2 = len(x)
    dmean = numpy.nanmean(bestx) - numpy.nanmean(x)
    s1 = numpy.nanstd(bestx)
    s2 = numpy.nanstd(x)

    tol = 1e-6
    dof = n1+n2-2

    s12 = numpy.sqrt(((n1-1)*s1*s1 + (n2-1)*s2*s2)/dof)
    if (s12<tol):
        if (numpy.abs(dmean)<tol):
            return 0.5
        else:
            return 0.
    t = numpy.abs(dmean)/(s12*numpy.sqrt(1./n1 + 1./n2))
    return 2.*scipy.stats.t.cdf(t,dof)

        
def findsignif(res,dim,boldtype,testtype,alpha):
    # dim    dimension where to average over
    # sdim   dimension where to take the min/max over
    # ldim   leftover dimension
    sz = res.shape
    nrd = len(sz)
    stype = boldtype[0:3]
    if (stype=='min'):
        res = -res
    sdim = int(boldtype[3])
    if (sdim==dim):
        raise ValueError('Cannot bold over dim.%d, because we average over that.'%sdim)

    # Permute the data, such that the comparison is taken over the second
    # dimension, and that the average was taken over the first dimension
    orgorder = range(0,3)
    ldim = list(set(orgorder) - set([dim,sdim]))[0]
    res = numpy.transpose(res,[sdim,ldim,dim])
    sz = res.shape
    # which are the winners:
    Imax = numpy.argmax(numpy.mean(res,axis=2),axis=0)
    I = numpy.zeros((sz[0],sz[1]))
    for j in range(0,sz[1]):
        bestr = res[Imax[j],j,:]
        for i in range(0,sz[0]):
            if (testtype=='win'):
                if (Imax[j]==i):
                    I[i,j] = 1
            if (testtype=='dep'):
                if (ttest_dep(bestr,res[i,j,:])>alpha):
                    I[i,j] = 1
            if (testtype=='ind'):
                if (ttest_indep(bestr,res[i,j,:])>alpha):
                    I[i,j] = 1
    if (ldim<sdim):
        I = I.transpose()

    return I




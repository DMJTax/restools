% Results Toolbox
% Version 1.8.0 22-Febr-2013
%
%Results manipulation
%--------------------
%results          create a results object
%getname/setname  get/set the title of a results object
%getdimname/
%    setdimname   get/set the axis names
%getdimvalues/
%    setdimvalues get/set the values along an axis
%ressqueeze       remove the singleton dimensions
%shiftdim         shift the dimensions
%cat              concatenate result objects
%catfiles         concatenate result objects from file
%permute          permute the dimensions of results
%average          average a result along a certain dimension
%                 (NOTE: this is the main feature of the toolbox)
%sum              sum a result along a certain dimension
%updateresults    update one entry in a results structure
%sortdim          sort results according to dim-values
%
% Standard Matlab operators [],(:), ' are defined to manipulate result
% objects (concatenating, extracting sub-results, subasignment,
% transpose, etc). 
% Furthermore, mathematical operations like +, -, *, /, .^, log, exp
% are also possible.
%
%Plot functions
%--------------
%show             show the results structure in different formats
%sh               shortcut to show results directly from a file
%cellprintf       print formatted in a cell-array
%errorband        improved errorbar function
%semibar          bar plot with transparant colors
%
%Support functions
%-----------------
%mymean           robust mean
%mymedian         robust median
%mystd            robust standard deviation
%myste            robust standard error
%mycov            robust covariance matrix
%mynormcdf        normal cumulative distribution
%mytcdf           Student's T cumulative distribution
%
%Examples
%--------
%resex_simple     example on the basic use
%resex_plots      example on plotting possibilities
%resex_averaging  example on averaging results
%resex_cut        example on cutting result entries
%
%
% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

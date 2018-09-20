%TESTFRIEDMAN Friedman/Nemenyi test for comparisons of several classifiers
%
%    [SIG, FVAL, CRITVAL, RANKS, CRITDIF] = TESTFRIEDMAN(R,DIM,ALPHA)
%
% The test ranks the classifiers, determines whether the differences in
% ranks are significant (SIG=1 for significant differences, 0 otherwise)
% and returns a the minimum difference in ranks (CRITDIF) for any
% individual difference to be significant.
%
% R contains performances on N datasets of K classifiers. R is either an
%    @RESULTS object, or an NxK matrix.    
%
% DIM specifies the direction in which the classifiers are stored
%    ('rows' or 'cols' or 1 or 2)
%    
% ALPHA specifies the significance level (default 0.05 or 0.1)
%
% The test is described in detail in:
%
%   @article{demšar2006statistical,
%       title={Statistical comparisons of classifiers over multiple data sets},
%       author={Dem{\v{s}}ar, J.},
%       journal={The Journal of Machine Learning Research},
%       volume={7},
%       pages={1--30},
%       year={2006},
%       publisher={JMLR. org}
%   }
%    
% Implementation by Veronika Cheplygina

function [sig fVal critVal ranks critDif] = testfriedman(R, dim, alpha)


if nargin < 3
    alpha = 0.05;
elseif ~ismember(alpha, [0.05, 0.1])
    warning('You have specified an invalid value for ALPHA. Only values 0.05 and 0.1 are supported. Setting ALPHA to 0.05')
    alpha = 0.05;
end

if alpha==0.05          %This is a lookup table of values we need later
    lookupq = [1.960 2.343 2.569 2.728 2.850 2.949 3.031 3.102 3.164 3.219];
elseif alpha==0.1
    lookupq = [1.645 2.052 2.291 2.459 2.589 2.693 2.780 2.855 2.920 2.978];
end
       
        
if nargin < 2
    dim = 1;
elseif ischar(dim)
       [dimflag dimix] = ismember(dim, ['rows'; 'cols'], 'rows');
       if dimflag == 0
           warning('You have specified an invalid value for DIM. Only values rows and cols (or 1 and 2) are allowed. Setting DIM to rows')
           dim=1;
       else
           dim = dimix;
       end
elseif isnumeric(dim)
       [dimflag dimix] = ismember(dim, [1 2]);
       if dimflag == 0
           warning('You have specified an invalid value for DIM. Only values 1 and 2 (or rows and cols) are allowed. Setting DIM to 1')
           dim=1;
       else
           dim = dimix;
       end
end


%Check whether we need to average
if isa(R, 'results')
    perfVals = R.res;
    
    dim3 = size(perfVals,3);
    if dim3 == 3
        warning('Assuming the values in R are already averaged')
        perfVals = perfVals(:,:,1);
    elseif (dim3 > 1)
        warning('Multiple values provided, averaging...')
        perfVals = nanmean(perfVals,3);
    end
else
    perfVals = R;
    if (size(perfVals,3) > 1)
        warning('Multiple values provided, averaging...')
        perfVals = nanmean(perfVals,3);
    end
end

if sum(sum(isnan(perfVals))) > 0
    warning('Some values are NaN, setting to 0.5 (assuming AUC)')
    
    perfVals(isnan(perfVals)) = 0;
    
end


%Transpose if necessary
if dim == 1
    perfVals = perfVals';
end


[N K] = size(perfVals);                          %N datasets, k classifiers

ranks = zeros(size(perfVals));

for i=1:N
    i;
    j=1;
    while j<=K
        j;
        [maxVal maxI] = max(perfVals(i,:));                     %Find next best classifier
        
        tiedix = find(perfVals(i,:)==maxVal);
        
        if(size(tiedix,2) == 1)                                %Just 1 best
            ranks(i, maxI) = j;                                 %Rank it
            perfVals(i, maxI) = -1;                             %Do not consider this anymore
            j=j+1;
        else                                                    %Several best
            tiedrank = (j + (j+size(tiedix,2)-1))/2;
                              
            for a=1:size(tiedix,2)
                ranks(i, tiedix(a)) = tiedrank;  
                perfVals(i,  tiedix(a)) = -1;    
            end
            j=j+size(tiedix,2);
        end
    end
end

ranks = sum(ranks,1)/N;


%Statistic for these results
x = 12*N/(K*(K+1)) * (sum(ranks.^2)-(K*(K+1)^2)/4);     % Friedman statistic
fVal=((N-1)*x)/(N*(K-1)-x);                                % F statistic (Iman and Davenport 1980) - More relaxed than x 

%Critical value
v1 = K-1;
v2 = (K-1)*(N-1);
critVal = finv(1-alpha,v1,v2);     


sig = fVal > critVal;

if sig
    disp('Reject the null hypothesis, differences are significant');

    q=lookupq(K-1);
    critDif=q*sqrt((K*(K+1))/(6*N));     %Value for Nemenyi post hoc test
else
    disp('Do not reject the null hypothesis, differences are not significant');
    critDif=-1;
end


fig1=figure;
axes1 = axes('Parent',fig1);
hold on;
%set(axes1, 'YColor',[0.8 0.8 0.8]);
set(gca,'ytick',[])

%set(axes1, 'XAxisLocation', 'top');
set(axes1, 'XLim', [1 K]);


if isa(R, 'results')
    clasfNames = cellstr(R.dim{dim});
else
    
    clasfNames = arrayfun(@num2str, 1:K, 'UniformOutput', false)';
    
end



[sortedRanks sortedix] = sort(ranks, 'descend');
clasfNames = clasfNames(sortedix, :)

for i=1:K
    
    arrowLength = (i+1); %mod(i,(K/2));

            
    %Plot the rank of the classifier
    plot(repmat(sortedRanks(i), arrowLength,1), [1:arrowLength], 'k--');
    
    %Plot the significance area
            plot([sortedRanks(i) sortedRanks(i)+critDif], [arrowLength-0.75 arrowLength-0.75], 'Color',[0 0.5 0.75], 'LineWidth', 2, 'LineStyle', '-' );
    

            
    text(sortedRanks(i), arrowLength, sprintf('%s (%2.2f)',  strtrim(clasfNames{i}), sortedRanks(i)));
   
    
    
end
hold off;







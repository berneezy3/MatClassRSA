classdef cvpart
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% partitionObj = cvpart(n,k)
% --------------------------------
% Bernard Wang, June 27, 2017
% 
% This class is an alternative to the matlab cvpartition class.  It
% partitions cross validation folds without randomization.
% 
% INPUT ARGS:
%   - n: number of training samples
%   - k: number of folds
%
% OUTPUT ARGS:
%   - obj:  ann object of the cvpart class
    
   properties
      folds
      NumTestSets
      training
      test
   end
   methods
      function obj = cvpart(n, k)
                  
        assert(n >= k, 'first parameter, k, must be lager than second parameter, n');

          
        %initialize indices list
        obj.folds = {};
        
        %initialize number of sets
        obj.NumTestSets = k;
        
        %get remainder
        remainder = rem(n, k);
    
        %get quotient
        %this is the number of trials each fold
        quotient = floor(n/k);

        %case divisible
        if remainder == 0
            for i = 1:k
                trainIndices = ones( n,1 );
                
                for j = 1:quotient
                    trainIndices(j+(i-1)*quotient) = 0;
                    
                end
                obj.training{end+1} = trainIndices;
                obj.test{end+1} = 1-trainIndices;
            end
        %case indivisible
        else
            indexlocation = 0;
            for i = 1:k-remainder
                trainingIndices = ones( n,1 );
                for j = 1:quotient
                    trainingIndices(j+(i-1)*quotient) = 0;
                    indexlocation = indexlocation + 1;
                end
                obj.training{end+1} = trainingIndices;
                obj.test{end+1} = 1-trainingIndices;
            end
            for i = 1:remainder
                %disp('ajhdbfajhsdbfljahsdf');
                %disp(indexlocation);
                trainingIndices = ones( n,1 );
                for j = 1:quotient+1
                    trainingIndices(j+(i-1)*quotient+indexlocation+(i-1)) = 0;
                end
                obj.training{end+1} = trainingIndices;
                obj.test{end+1} = 1-trainingIndices;
            end
        end
      
      end
      
      
   end
end
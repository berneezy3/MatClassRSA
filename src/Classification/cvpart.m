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

% This software is licensed under the 3-Clause BSD License (New BSD License), 
% as follows:
% -------------------------------------------------------------------------
% Copyright 2017 Bernard C. Wang, Anthony M. Norcia, and Blair Kaneshiro
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
% this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice, 
% this list of conditions and the following disclaimer in the documentation 
% and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
% contributors may be used to endorse or promote products derived from this 
% software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ?AS IS?
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.
    
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
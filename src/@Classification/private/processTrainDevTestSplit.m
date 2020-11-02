function y = processTrainDevTestSplit(trainDevTestSplit, X, nfolds)
%  processTrainDevTestSplit(trainDevTestSplit, X)
% --------------------------------
% Bernard Wang, September 17, 2020
% 
% This function checks that the train/devlopment/test data splits used for 
% optimization functions abides by the restrictions of the data and cross
% validation procedure.  If array was in decimal format, it then converts 
% the decimals representing fractions to integers representing number of trials
% in each train/development/test fold.
% 
% INPUT ARGS:
%   - trainDevTestSplit: a 2 or 3 element vector.  If vector contains
%   3 elements, then they represent the training set, development set and
%   the test set respectively.  If the vector contains 2 elements, then
%   only the training set and the test set is represented.  The values can
%   either be in integer format for decimal format(<=1).  If the values are
%   integers, then the values should represent the number of trials in each
%   class, and the vector should sum up to N, where N is the number of
%   trials in X.  If the values are decimals, then they represent the
%   fraction of N each partition contains, thus the vector should sum up to
%   1.  
%   - X: full training data matrix

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

    [r c] = size(X);
    
    % make sure the size of X is enough to allow for 2 or 3 data splits
    if r < length(trainDevTestSplit)
        error('X must have at least as many trials as data splits');
    end
    
    % test if the trainDevTestSplit values sum correctly
    % if integers passed in, trainDevTestSplit must sum to N
    if any(trainDevTestSplit > 1)
        if (sum(trainDevTestSplit) ~= r)
            error('if trainDevTest is expressed as integers, then values must sum to number of trials');
        end
    
    % if decimals passed in, trainDevTestSplit must sum to 1
    elseif any(trainDevTestSplit < 1)
        if (sum(trainDevTestSplit) ~= 1)
            error('if trainDevTest is expressed as fractions, then values must sum to 1');
        end
    end
    
    % if the test/dev/train split is in decimal form, convert to integer
    decimalFlag = 0;
    for i = 1:length(trainDevTestSplit)
        if (trainDevTestSplit(i) < 1 && trainDevTestSplit(i) > 0)
            decimalFlag = 1;
        end
    end
    
    if (decimalFlag)
        for i = 1:length(trainDevTestSplit)
            trainDevTestSplit(i) = round(trainDevTestSplit(i) * r);
        end

        %add remainders to training set
        for i = 1:r-sum(trainDevTestSplit)
            trainDevTestSplit(1) = trainDevTestSplit(1) + 1 ;
        end
    end

    if length(trainDevTestSplit) ~= 2 && length(trainDevTestSplit) ~= 3
        error('trainDevTestSplit should contain either 2 or 3 values')
    end
    
    % return trainDevTestSplit as integers
    y = trainDevTestSplit;

end
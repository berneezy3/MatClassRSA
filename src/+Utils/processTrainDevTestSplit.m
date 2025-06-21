function y = processTrainDevTestSplit(trainDevTestSplit, X)
%  y = processTrainDevTestSplit(trainDevTestSplit, X)
% --------------------------------
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
%
% OUTPUT
% - y: updated version of trainDevTestSplit input (integer representation)

% This software is released under the MIT License, as follows:
%
% Copyright (c) 2025 Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, 
% Feng Ruan, Anthony M. Norcia, and Blair Kaneshiro.
% 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to 
% permit persons to whom the Software is furnished to do so, subject to 
% the following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    [r c] = size(X);
    
    % make sure the size of X is enough to allow for 2 or 3 data splits
    if r < length(trainDevTestSplit)
        error('X must have at least as many trials as data splits');
    end
    
    if length(trainDevTestSplit) ~= 2 && length(trainDevTestSplit) ~= 3
        error('trainDevTestSplit should contain either 2 or 3 values')
    end
    
    % test if the trainDevTestSplit values sum correctly
    % if integers passed in, trainDevTestSplit must sum to N
    if any(trainDevTestSplit > 1)
        if (sum(trainDevTestSplit) ~= r)
            error('if trainDevTest is expressed as integers greater than 1, then values must sum to number of trials');
        end
    
    % if decimals passed in, trainDevTestSplit must sum to 1
    elseif any(trainDevTestSplit < 1)
        if (abs(sum(trainDevTestSplit) - 1) > .01)
            error('if trainDevTest is expressed as fractions, then values must sum to 1');
        end
    end
    
    % if the test/dev/train split is in decimal form, convert to integer
    decimalFlag = 0;
    for i = 1:length(trainDevTestSplit)
        if (trainDevTestSplit(i) < 1 && trainDevTestSplit(i) > 0)
            decimalFlag = 1;
            break;
        end
    end
    if (sum(trainDevTestSplit) == 0)
        
    end
    
    if (decimalFlag)
        for i = 1:length(trainDevTestSplit)
            trainDevTestSplit(i) = floor(trainDevTestSplit(i) * r);
        end

        %add remainders to training set
        for i = 1:r-sum(trainDevTestSplit)
            trainDevTestSplit(1) = trainDevTestSplit(1) + 1 ;
        end
    end


    
    % return trainDevTestSplit as integers
    y = trainDevTestSplit;

end
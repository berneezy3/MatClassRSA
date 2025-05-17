function y = processTrainDevSplit(trainDevSplit, X)
%  processTrainDevSplit(trainDevSplit, X)
% --------------------------------
% Bernard Wang, September 17, 2020
% 
% This function checks that the train/devlopment/test data splits used for 
% optimization functions abides by the restrictions of the data.  Then, it 
% converts the 3 element array into integer format, where each integer 
% represents the number of trials in each train/development/test fold.
% 
% INPUT ARGS:
%   - trainDevTestSplit: a 3 element vector, containing either:
%       - 3 decimals summing up to 1, which represents the fraction of
%       trials used for each train/dev/test data split.
%       - 3 integers summing up to N, where N is the number of trials in X.
%       Each number represents the number of trials used in each
%       train/dev/test data split.
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
    
    % make sure the size of X is enough to allow for 2 data splits
    if r < 2
        error('X must have 2 or more trials to split into train & dev sets');
    end

    % test if the trainDevSplit values sum correctly
    if any(trainDevSplit < 1)
        if (sum(trainDevSplit) ~= 1)
            error('if trainDevTest is expressed as fractions, then values must sum to 1');
        end
    elseif any(trainDevSplit < 1)
        if (sum(trainDevSplit) ~= r)
            error('if trainDevTest is expressed as integers, then values must sum to number of trials');
        end
    end

    % if the test/dev split is in decimal form, convert to integer
    if any(trainDevSplit < 1)
        for i = 1:2
            trainDevSplit(i) = trainDevSplit(i) * r;
        end
        %add remainders to training set
        for i = 1:r-sum(trainDevSplit)
            trainDevSplit(1) = trainDevSplit(1) + 1 ;
        end
    end

    % warning if the splits do not align well with the number of folds


    % return trainDevTestSplit as integers
    y = trainDevSplit;

end
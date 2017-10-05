function pVal = pbinom(Y, nFolds, accuracy)
%-------------------------------------------------------------------
% pVal = pbinom(Y, nFolds, accuracy)
% -----------
% Bernard Wang
% January 30 2012
%
% This function computes the p-value via binomial CDF (cumutalive
% Distribution Function)
%
% INPUT ARGS:
%   - Y: the labels for the training data
%   - nFolds: the number of folds 
%   - accuracy: the actual accuracy of the classifier
%
% OUTPUT ARGS:
%   - pVal: P-value

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

classes = unique(Y);
classCount = sum(Y == classes(1));
foldSize = floor(length(Y)/nFolds);

% make sure nObs > 100, so we have at least the minimal amount of trials
if (length(Y)) < 100
    warning('To use binomial CDF to compute P-value, number of observatons must > 100.')
end

% make sure N > nObs/10, to prevent going over maximum amount of folds
if nFolds > 10
    warning(['To use binomial CDF to compute P-value, the size of each fold ' ...
        'should be greater than the number of observations/10. Make sure number ' ...
        'of folds is <= 10'])
end

% check to make sure the amount of each class is equal
for i = 1:length(classes)
    if classCount ~= sum(Y == classes(i))
        warning('Should have equal amount of trials of each class');
        break;
    end
end

%rate = 13.16;  % number between 0-100
chance = 1/length(classes);
trialsPerFold = round(length(Y)/nFolds);

pVal = 1-binocdf(trialsPerFold*accuracy, trialsPerFold, chance);
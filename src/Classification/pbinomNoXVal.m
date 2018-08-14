function pVal = pbinomNoXVal(actualLabels, actualAcc, nClasses)
%-------------------------------------------------------------------
% pVal = pbinomNoXVal(Y, nFolds, accuracy)
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

classes = unique(actualLabels);
classHist = histogram(actualLabels, 'BinMethod', 'integers');
classHist = classHist.Values(:)'; 
classCount = sum(actualLabels == classes(1));

% check to make sure the amount of each class is equal
for i = 1:length(classes)
    if classCount ~= sum(actualLabels == classes(i))
        warning(['Binomial Test p-value requires balanced classes.  ' ...
            'Current distribution of observations by class is ' mat2str(classHist)]);
    end
end

if (actualAcc > 1)
    warning('Input ''actualAcc'' was greater than 1.  Dividing by 100 to normalize.');
    actualAcc = actualAcc/100;
end

pVal = 1-binocdf(length(actualLabels)*actualAcc, length(actualLabels), 1/nClasses);
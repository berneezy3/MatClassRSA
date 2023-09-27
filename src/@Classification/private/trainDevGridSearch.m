function [gamma_opt, C_opt] = trainDevGridSearch(trainX, trainY, devX, devY, ip)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2020.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% mdl = trainDevGridSearch(X, Y, gammaRange, cRange)
% --------------------------------
% Bernard Wang, April 5, 2020
%
% Given training data matrix X, label vector Y, and a vector of gamma's 
% and C's to search over, this function runs cross validation over a grid 
% of all possible combinations of gammas and C's.
% 
% INPUT ARGS:
%   - trainX: 2D trial by feature training data matrix
%   - trainY: label vector
%   - devX: 2D trial by feature training data matrix
%   - devY:label vector
%   - ip: input parser passed from parent script, which calls this function
%
% OUTPUT ARGS:
%   - gamma_opt: gamma value that produces the highest cross validation
%   accuracy
%   - C_opt: C value that produces that highest cross validation accuracy
%
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

%     accGrid = zeros(length(ip.Results.cSpace), length(ip.Results.gammaSpace));
    accVec = zeros(1, length(ip.Results.cSpace)*length(ip.Results.gammaSpace));
    cGrid = cell(length(ip.Results.cSpace), length(ip.Results.gammaSpace));
    cLen = length(ip.Results.cSpace);
    gammaLen = length(ip.Results.gammaSpace);
    flatLen = cLen * gammaLen; 
    cSpace = ip.Results.cSpace;
    gammaSpace = ip.Results.gammaSpace;
    RSA = MatClassRSA;
    
    
    % parallelized grid search
    parfor i = 1:cLen*gammaLen
        cInd = mod(i-1, gammaLen)+1;
        gammaInd = ceil(i/gammaLen);
        tempM = trainMultiEvalc(trainX, trainY, 0, 'SVM', ...
            cSpace(cInd), gammaSpace(gammaInd));
        tempC = predictEvalc(tempM, devX, devY);
        accVec(i) = tempC.accuracy;
        cVec{i} = tempC;
    end
    
    
    [maxVal, maxIdx] = max(accVec(:));
    [xInd yInd] = ind2sub([cLen gammaLen], maxIdx);

    gamma_opt = gammaSpace(yInd);
    C_opt = cSpace(xInd);  

end


function M = trainMultiEvalc(trainData, trainLabels, PCA, classifier, C, gamma)
    RSA = MatClassRSA;
    [~, M] = evalc(['RSA.Classification.trainMulti(' ... 
        'trainData, trainLabels, ''PCA'', PCA, ''classifier'', classifier, ' ...
        ' ''C'', C, ' ...
        ' ''gamma'', gamma);']);
end

function C = predictEvalc(M, testData, testLabels)
    RSA = MatClassRSA;
    [~, C] = evalc(['RSA.Classification.predict(M, testData,' ...
        ' ''actualLabels'', testLabels);']);
end
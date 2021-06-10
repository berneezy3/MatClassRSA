function [gamma_opt, C_opt] = nestedCvGridSearch(X, Y, ip, cvDataObj, excludeIndx)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2020.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% mdl = gridSearch(X, Y, gammaRange, cRange)
% --------------------------------
% Bernard Wang, April 5, 2020
%
% Given training data matrix X, label vector Y, and a vector of gamma's 
% and C's to search over, this function runs cross validation over a grid 
% of all possible combinations of gammas and C's.
% 
% INPUT ARGS:
%   - gammas: 2D trial by feature training data matrix
%   - Cs: label vector
%   - kernel:  SVM classification kernel
%   - optFolds: number of folds used for optimization
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

    gammaSpace = ip.Results.gammaSpace;
    cSpace = ip.Results.cSpace;
    kernel = ip.Results.kernel;

    accGrid = zeros(length(cSpace), length(gammaSpace));
    cGrid = cell(length(cSpace), length(gammaSpace));
    
    nFolds = NaN;
    if (sum(contains(ip.Parameters, 'nFolds_opt')))
        nFolds = ip.Results.nFolds_opt;
    elseif (sum(contains(ip.Parameters, 'nFolds')))
        nFolds = ip.Results.nFolds;
    end
    
    try
        matlabpool
        closePool=1;
    catch
        parpool
        closePool=0;
    end
    
    if ( (exist('excludeIndx', 'var') == 0) )
        
        RSA = MatClassRSA;
        % initialize parallel worker pool
        try
            matlabpool;
            closePool=1;
        catch
            try 
                parpool;
                closePool=0;
            catch
                % do nothing if no parpool functions exist
            end
        end
        cLen = length(ip.Results.cSpace);
        gammaLen = length(ip.Results.gammaSpace);
        flatLen = cLen * gammaLen; 
        % parallel grid search
        parfor i = 1:cLen*gammaLen
            cInd = mod(i-1, gammaLen)+1;
            gammaInd = ceil(i/gammaLen);
            tempM = cvMuliEvalc(X, Y, 0, 'SVM', cSpace(cInd), gammaSpace(gammaInd), 3, 'rbf');
            accVec(i) = tempM.accuracy;
        end
        accGrid = reshape(accVec, cLen, gammaLen);
        % close parallel workers
        if exist('closePool', 'var')
            if closePool
                matlabpool close;
            else
                delete(gcp('nocreate'));
            end
        end
                

    elseif ( exist('cvDataObj') && (exist('excludeIndx', 'var')==1))

        XFolds = cvDataObj.testXall;
        XFolds(excludeIndx) = [];
        YFolds = cvDataObj.testYall;
        YFolds(excludeIndx) = [];

        RSA = MatClassRSA;
        for i = 1:length(Cs)
            for j = 1:length(gammaSpace)

                labelsConcat = [];
                predictionsConcat = [];

                for k = 1:nFolds

                    trainIndx = [1:nFolds];
                    trainIndx(k) = [];
                    testIndx = k;

                    trainX = [];
                    trainY = [];

                    for l = 1:nFolds-1
                        trainX = [trainX; XFolds{trainIndx(l)}];
                        trainY = [trainY; YFolds{trainIndx(l)}];
                    end

                    testX = XFolds{k};
                    testY = YFolds{k};

                    [mdl, scale] = fitModel(trainX, trainY, ip, gammaSpace(j), cSpace(i));

                    [predictions decision_values] = modelPredict(testX, mdl, scale);

                    labelsConcat = [labelsConcat testY'];
                    predictionsConcat = [predictionsConcat predictions];
                    modelsConcat{i} = mdl;  


    %                 [~, tempC] = evalc(['RSA.Classification.crossValidateMulti(' ...
    %                     'trainX, trainY, ''PCA'', -1, ''classifier'', ''SVM'',''C'', Cs(i), ' ...
    %                     ' ''gamma'', gammas(j), ''kernel'', kernel, ''nFolds'', optFolds);']);                

                end

                accGrid(i,j) = computeAccuracy(labelsConcat, predictionsConcat);
                %cGrid{i,j} = tempC;

            end
        end

        % get maximum accuracy, and return the gamma and C value for the
        % maximum accuracy

    end

    [maxVal, maxIdx] = max(accGrid(:));
    [xInd yInd] = ind2sub(size(accGrid), maxIdx);

    gamma_opt = gammaSpace(yInd);
    C_opt = cSpace(xInd);
    
    if closePool
        matlabpool close
    else
        delete(gcp('nocreate'));
    end


end

function tempC = cvMuliEvalc(X, Y, PCA, classifier, C, gamma, nFolds, kernel)
    RSA = MatClassRSA;
    [~, tempC] = evalc(['RSA.Classification.crossValidateMulti(' ...
        ' X, Y, ''PCA'', 0, ''classifier'', ''SVM'',''C'', C, ' ...
        ' ''gamma'', gamma, ''nFolds'', nFolds, ''kernel'', kernel);']);
end
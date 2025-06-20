function [gamma_opt, C_opt] = nestedCvGridSearch(X, Y, ip, cvDataObj, excludeIndx)
%-------------------------------------------------------------------
% [gamma_opt, C_opt] = nestedCvGridSearch(X, Y, ip, cvDataObj, excludeIndx)
% ------------------------------------------------------------------
%
% Given training data matrix X, label vector Y, and a vector of gamma's 
% and C's to search over, this function runs over a grid 
% of all possible combinations of gammas and C's to find the values that 
% produce the highest cross validation accuracy.  
%
% Gamma is a hyperparameter of the rbf kernel for SVM classification, and 
% 'C' is a hyperparameter of both the rbf and linear kernel for SVM 
% classification. 
% 
% INPUT ARGS:
%   - X: 2D trial by feature training data matrix
%   - Y: label vector
%   - ip: inputParser pass from parent script which called this function
%   - cvDataObj: Cross validation object containing the train/test data
%   splits for X,Y.  Created by the function Utils.cvData(). 
%   - excludeIndx: Indicies of trials to skip during cross validation
%   - kernel:  SVM classification kernel
%   - optFolds: number of folds used for optimization
%
% OUTPUT ARGS:
%   - gamma_opt: gamma value that produces the highest cross validation
%   accuracy
%   - C_opt: C value that produces that highest cross validation accuracy

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
    
    
    
    if ( (exist('excludeIndx', 'var') == 0) )
        
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
                

    elseif ( exist('cvDataObj') && (exist('excludeIndx', 'var')==1))

        XFolds = cvDataObj.testXall;
        XFolds(excludeIndx) = [];
        YFolds = cvDataObj.testYall;
        YFolds(excludeIndx) = [];

        for i = 1:length(cSpace)
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
    
   


end

function tempC = cvMuliEvalc(X, Y, PCA, classifier, C, gamma, nFolds, kernel)
    RSA = MatClassRSA;
    [~, tempC] = evalc(['RSA.Classification.crossValidateMulti(' ...
        ' X, Y, ''PCA'', 0, ''classifier'', ''SVM'',''C'', C, ' ...
        ' ''gamma'', gamma, ''nFolds'', nFolds, ''kernel'', kernel);']);
end
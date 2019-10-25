 function [CM, accuracy, predY, pVal] = trainModelTestData(X, Y, ip)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% checkInputData(X, Y)
% --------------------------------
% Bernard Wang, Sept 28, 2019
% 
% INPUT ARGS:
%   - X: 
%   - Y: 
%
% OUTPUT ARGS:
% 
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
 
    
    if (~testCellInput(X,Y))
        error(['Mismatch detected within input.  Input should be in as follows: '...
            'X - {xtrain, xtest}, Y - {ytrain, ytest}'])
    end
   
    trainData = X{1};
    trainLabels = Y{1};
    testData = X{2};
    testLabels = Y{2};
    
    if (find(isnan(trainData(:))) |...
        find(isnan(trainLabels(:))) |...
        find(isnan(testData(:))) |...
        find(isnan(testLabels(:))) ) 
        error('MatClassRSA classifiers cannot handle missing values (NaNs) in the data at this time.')
    end

    
        
    % Convert to column vector if needed
    if ~iscolumn(trainLabels)
       warning('Transposing input labels vector to column.') 
       trainLabels = trainLabels(:);
    end
    if ~iscolumn(testLabels)
       warning('Transposing input labels vector to column.') 
       testLabels = testLabels(:);
    end

    % PCA
    if (ip.Results.PCA > 0)
        [trainData, V, nPC] = getPCs(trainData, ip.Results.PCA);
        testData = testData*V;
        testData = testData(:,1:nPC); 
    end
    
    % Train Model
    mdl = fitModel(trainData, trainLabels', ip);
    
    % Predict Labels for Test Data
    predY = modelPredict(testData, mdl);
    
    % Get Confusion Matrix
    CM = confusionmat(testLabels, predY);
    
    % Get Accuracy
    accuracy = computeAccuracy(predY, testLabels); 
    
    % Get p-Value
    %pVal = pbinom(Y, ip.Results.nFolds, accuracy);
    pVal = pbinomNoXVal( testLabels, accuracy, length(unique(trainLabels)));
    
 
 end
 
 
 function y = testCellInput(X, Y)
    [rx cx] = size(X);
    [ry cy] = size(Y);
    
    if (rx == 1 && cx == 2 && ry == 1 && cy == 2)
        xtrain = X{1};
        xtest = X{2};
        ytrain = Y{1};
        ytest = Y{2};
        
        if ~isvector(ytrain) || ~isvector(ytest)
            error('The labels matrices must have a dimension 1');
        end
        
        % Convert to column vector if needed
        if ~iscolumn(ytrain)
           warning('Transposing input labels vector to column.') 
           ytrain = ytrain(:);
        end
        if ~iscolumn(ytest)
           warning('Transposing input labels vector to column.') 
           ytest = ytest(:);
        end
        
        [xtrainR xtrainC] = size(xtrain);
        [xtestR xtestC] = size(xtest);
        [ytrainR ytrainC] = size(ytrain);
        [ytestR ytestC] = size(ytest);
        
        if (xtrainC == xtestC && ...
                xtrainR == ytrainR && ... 
                xtestR == ytestR && ...
                ytrainC == 1 && ...
                ytestC == 1)
            y = 1;
        else
            y = 0;
        end 
    else
        error('X and Y must both be cell arrays of size [1 2]');
    end
 end

function [gamma_opt, C_opt] = trainDevGridSearch(trainX, trainY, devX, devY, ip)
%-------------------------------------------------------------------
% [gamma_opt, C_opt] = trainDevGridSearch(trainX, trainY, devX, devY, ip)
% --------------------------------
%
% Given training and development partitions of data and labels, as well as
% vectors of gamma and C values to search over, this function runs cross
% validations over a grid of all possible combinations of gammas and Cs and
% returns the optimal value for each. 
% 
% INPUT ARGS:
%   - trainX: 2D trial-by-feature training data matrix
%   - trainY: labels vector for training data
%   - devX: 2D trial-by-feature development data matrix
%   - devY: labels vector for development data 
%   - ip: input parser passed from parent script, which calls this
%   function. Includes gammaSpace and cSpace parameters, which specify the
%   grid over which to search.
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

%     accGrid = zeros(length(ip.Results.cSpace), length(ip.Results.gammaSpace));
    
    cGrid = cell(length(ip.Results.cSpace), length(ip.Results.gammaSpace));
    cLen = length(ip.Results.cSpace);
    gammaLen = length(ip.Results.gammaSpace);
    flatLen = cLen * gammaLen; 
    cSpace = ip.Results.cSpace;
    gammaSpace = ip.Results.gammaSpace;
    rngType = ip.Results.rngType;
    
    
    kernel = ip.Results.kernel;
    
    % Create a parallel data queue
    D = parallel.pool.DataQueue;
               
    % update function
        function updateWaitbar(~)
            progressCount = progressCount + 1;
            waitbar(progressCount/numIterations, hWait);
        end

    
    % callback function to update the waitbar.
        afterEach(D, @(x) updateWaitbar());
    
    % parallelized grid search
    
    if (strcmpi(kernel, 'rbf'))
        accVec = zeros(1, length(ip.Results.cSpace)*length(ip.Results.gammaSpace));
        
         % Create a waitbar on the client
        hWait = waitbar(0, 'Processing RBF Kernel Grid Search...');      

        % Create a persistent variable to track progress.
        progressCount = 0;
        
        numIterations = cLen*gammaLen;
         
        parfor i = 1:cLen*gammaLen
            
            cInd = ceil(i / gammaLen); 
            gammaInd = mod(i-1, gammaLen) + 1;
            
            
            tempM = trainMultiEvalc(trainX, trainY, 0,  'SVM',  kernel, ...
                cSpace(cInd), gammaSpace(gammaInd), rngType);

            tempC = predictEvalc(tempM, devX, devY);

            accVec(i) = tempC.accuracy;
            cVec{i} = tempC;
            
            % Send an update to the DataQueue to update the waitbar
            send(D, 1);
        end
        
        for debugIdx = 1:numIterations
            ic  = ceil(debugIdx/gammaLen);
            ig  = mod(debugIdx-1, gammaLen)+1;
            fprintf("idx=%d → C=%.3g, gamma=%.3g, acc=%.2f%%\n", ...
                    debugIdx, cSpace(ic), gammaSpace(ig), 100*accVec(debugIdx));
        end
        
        [maxVal, maxIdx] = max(accVec);
        [colIndex, rowIndex] = ind2sub([gammaLen, cLen], maxIdx);
        
        C_opt     = cSpace(rowIndex);
        gamma_opt = gammaSpace(colIndex);

        % Close the waitbar when done
        if exist('hWait', 'var') && isvalid(hWait)
            close(hWait);
        end

        
    elseif (strcmpi(kernel, 'linear'))
        
        accVec = zeros(1, cLen);
        
        % Create a waitbar on the client
        hWait = waitbar(0, 'Processing Linear Kernel Grid Search...');      

        % Create a persistent variable to track progress.
        progressCount = 0;
        
        numIterations = cLen;
        
        parfor i = 1:cLen
           
            tempM = trainMultiEvalc(trainX, trainY, 0, 'SVM', kernel, ...
                 cSpace(i), gammaSpace(i), rngType);

            tempC = predictEvalc(tempM, devX, devY);

            accVec(i) = tempC.accuracy;
            cVec{i} = tempC;
            
            % Send an update to the DataQueue to update the waitbar
            send(D, 1);
        end
        
       [maxVal, maxIdx] = max(accVec(:));
        C_opt = cSpace(maxIdx);
        gamma_opt = 0;
        
        % Close the waitbar when done
        if exist('hWait', 'var') && isvalid(hWait)
            close(hWait);
        end
        
    else
        disp('The kernel is not correctly specified');
    end
        

    
fprintf("→ Best RBF parameters: C=%.5g, gamma=%.5g (accuracy=%.2f%%)\n", ...
        C_opt, gamma_opt, 100*maxVal);
    
% Then run the same combination in a simple single‐loop call:
tempM_test = trainMultiEvalc(trainX, trainY, 0, 'SVM', kernel, C_opt, gamma_opt, rngType);
tempC_test = predictEvalc(tempM_test, devX, devY);
fprintf("Verification: accuracy with (C=%.5g, γ=%.5g) = %.2f%%\n", ...
        C_opt, gamma_opt, 100*tempC_test.accuracy);
    
    
end


function M = trainMultiEvalc(trainData, trainLabels, PCA, classifier, kernel, C, gamma, rngType)
    
    [~, M] = evalc(['Classification.trainMulti(' ... 
        'trainData, trainLabels, ''PCA'', PCA, ''classifier'', classifier , ''kernel'', kernel,' ...
         ' ''C'', C, ''gamma'', gamma, ''rngType'', rngType);']);
     
     
end

function C = predictEvalc(M, testData, testLabels)
    
    [~, C] = evalc(['Classification.predict(M, testData,' ...
        ' ''actualLabels'', testLabels);']);
end
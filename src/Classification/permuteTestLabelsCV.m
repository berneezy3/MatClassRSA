function accArr = permuteTestLabelsCV(Y, cvPartObj, ip)

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

    % make sure nObs > 100, so we have at least the minimal amount of trials
    if (length(Y)) < 100
        error(['To use binomial CDF to computer P-value, number of ' ...
        'observatons must > 100.'])
    end

    % make sure N > nObs/10, to achieve minimal amount of nfolds viable 
    if ip.Results.nFolds > 10
        error(['To use binomial CDF to computer P-value, the size of each fold ' ...
            'should be greater than the number of observations/10. Make ' ...
            'sure number of nfolds is < 10'])
    end

    % initialize return variable and also intermediary storage variable
    accArr = NaN(ip.Results.permutations, 1);
    %correct and all prediction # matrix
    corrMat = NaN(ip.Results.permutations, ip.Results.nFolds);
    allMat = NaN(ip.Results.permutations, ip.Results.nFolds);
    
    % initialize variables to store correct vs. incorrect
    correctPreds = 0;
    incorrectPreds = 0;
    
    %loop same # of times as cross validation
    for i = 1:ip.Results.nFolds
        %change CV fold and stuff
        trainX = cvPartObj.trainXall{i};
        trainY = cvPartObj.trainYall{i};
        testX = cvPartObj.trainXall{i};
        testY = cvPartObj.trainYall{i};
            
        
        %get correctly predicted labels
        mdl = fitModel(trainX, trainY, ip);
        predictedY = modelPredict(testX, mdl);
    
        for j = 1:ip.Results.permutations
        
            %permute the test labels
            % (check if randperm is seeded every single time differently)
            % (yes, it is)
            disp(['calculating ' num2str((i-1)*ip.Results.permutations + j) ' of '...
                num2str(ip.Results.permutations*ip.Results.nFolds) ' fold-permutations']);
            pTestY = testY(randperm(length(testY)));
            %store accuracy
            for k = 1:length(predictedY)
                if predictedY(k) == pTestY(k)
                    correctPreds = correctPreds + 1;
                else
                    incorrectPreds = incorrectPreds + 1;
                end
            end
            corrMat(j,i) = correctPreds;
            allMat(j,i) = correctPreds + incorrectPreds;
            correctPreds = 0;
            incorrectPreds = 0;
        end
        
    end
    
    %technically needs to changed
    for j=1:ip.Results.permutations
        accArr(j) = sum(corrMat(j,:))/sum(allMat(j,:));
    end
    

end
function accArr = permuteFullModel(Y, cvDataObj, ip)

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

    % initialize return variable
    accArr = NaN(ip.Results.permutations, 1);

    % initialize variables to store correct vs. incorrect
    correctPreds = 0;
    incorrectPreds = 0;
    
    %loop same # of times as cross validation
%     parpool;
    for i = 1:ip.Results.permutations
        correctPreds = 0;
        incorrectPreds = 0;
        for j = 1:ip.Results.nFolds
                        
            disp(['calculating ' num2str((i-1)*ip.Results.nFolds + j) ' of '...
            num2str(ip.Results.permutations*ip.Results.nFolds) ' fold-permutations']);
            trainX = cvDataObj.trainXall{j};
            testX = cvDataObj.testXall{j};
            
            % randomize
            shufY = Y(randperm(length(Y)));
            
            [rTrain cTrain] = size(trainX);
            [rTest cTest] = size(testX);
            trainY = shufY(1:rTrain);
            testY = shufY(rTrain+1:length(shufY));

            %get correctly predicted labels
%             mdl = fitModel(pTrainX, trainY, classifier, ...
%             classifyOptions);
%             [funcOutput mdl] = evalc( ['fitModel(pTrainX, trainY, classifier,' ...
%             'classifyOptions)']);
            mdl =  fitModel(trainX, trainY, ip);
            predictedY = modelPredict(testX, mdl);


            %store accuracy
            for k = 1:length(predictedY)
                size( predictedY)
                length(testY)
                if predictedY(k) == testY(k)
                    correctPreds = correctPreds + 1;
                else
                    incorrectPreds = incorrectPreds + 1;
                end
            end
        
        end
        accArr(i) = correctPreds/(correctPreds + incorrectPreds);

    end
    
%     pVal = correctPreds/(correctPreds + incorrectPreds);
%     delete(gcp('nocreate'));

    
end
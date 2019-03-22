function [P, varargout] = classifyPredict(M, X, varargin)
% -------------------------------------------------------------------------
% [CM, accuracy, classifierInfo] = classifyPredict(X, Y, shuffleData)
% -------------------------------------------------------------------------
% Blair/Bernard - Feb. 22, 2017
%
% The main function for fitting data to create a model.  
%
% INPUT ARGS (REQUIRED)
%   M - EEG Model (output from classifyTrain)
%   X - training data
%
% INPUT ARGS (OPTIONAL NAME-VALUE PAIRS)
%   'actualLabels' - actual labels of test data X.  Length of this vector
%   must equal the number of trials in X.
%   'randomSeed' - This option determines whether the randomization is to produce
%       varying or unvarying results each different execution.  
%        --options--
%       'shuffle' (default option)
%       'default' (option to replicate results)
%   'shuffleData' - determine whether to shuffle the order of trials within 
%       training data matrix X (order of labels in the labels vector Y will be
%       shuffled in the same order)
%       --options--
%       1 - shuffle (default)
%       0 - do not shuffle
%
% OUTPUT ARGS 
%   P - Prediciton output produced by classifyPredict().  This contains a
%   few fields: 
%       - P.predY, or the predicted labels for the input data
%       - P.accuracy, accuracy of predicted values compared to actual labels
%       - P.confusion matrix of predicted values vs actual labels
%       - P.predictionInfo contians classification related information
%   Note that unless optional input 'actualLabels' is set, P.accuracy and 
%   P.confusionMatrix will be NaN.

% TODO:
%   Check when the folds = 1, what we should do 

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

    disp("Running classifyPredict()")

    ip = inputParser;
    ip.CaseSensitive = false;
    
    addRequired(ip, 'M', @isstruct);
    addRequired(ip, 'X', @is2Dor3DMatrix);
    
    defaultY = NaN;
    defaultRandomSeed = 'shuffle';
    defaultShuffleData = 1;
    defaultAverageTrials = -1;
    defaultAverageTrialsHandleRemainder = 'discard';
    
    expectedRandomSeed = {'default', 'shuffle'};
    expectedShuffleData = [0, 1];
    expectedAverageTrialsHandleRemainder = {'discard','newGroup', 'append', 'distribute'};

    %addParameter(ip, 'actualLabels', defaultY, @(x) assert( isvector(x) ));
    addOptional(ip, 'actualLabels', defaultY, @isvector);
    addParameter(ip, 'shuffleData', defaultShuffleData, ...
        @(x)  (x==1 || x==0));
    %{
	addParameter(ip, 'averageTrials', defaultAverageTrials, ...
        @(x) assert(rem(x,1) == 0 ));
    addParameter(ip, 'averageTrialsHandleRemainder', ...
        defaultAverageTrialsHandleRemainder, ...
        @(x) any(validatestring(x, expectedAverageTrialsHandleRemainder)));
    %}
    addParameter(ip, 'randomSeed', defaultRandomSeed,  @(x) isequal('default', x)...
        || isequal('shuffle', x) || (isnumeric(x) && x > 0));
    
    try 
        parse(ip, M, X, varargin{:});
    catch ME
        disp(getReport(ME,'extended'));
    end
    
    % Check input data
    testDataSize = size(X);
    if ( ~isnan(ip.Results.actualLabels) ) 
        checkInputData(X, ip.Results.actualLabels);
    end
    if (length(M.classifierInfo.trainingDataSize == 2))
        assert(M.classifierInfo.trainingDataSize(2) == testDataSize(2), ...
            "Dimension 2 (feature) of test data does not match Dimension 2 of training data used in classifyTrain().");
    elseif (length(M.classifierInfo.trainingDataSize == 3))
        assert(M.classifierInfo.trainingDataSize(1) == testDataSize(1), ...
            "Dimension 1 (space) of test data does not match Dimension 1 of training data used in classifyTrain().");
        assert(M.classifierInfo.trainingDataSize(2) == testDataSize(2), ...
            "Dimension 2 (time) of test data does not match Dimension 2 of training data used in classifyTrain().");

    else
        error("Data formatting issue.  Check input data matrix to classifyTrain and to classifyPredict");
    end
    
    % Subset data 
    [X, Y, nSpace, nTime, nTrials] = subsetTrainTestMatrices(X, ...
                                                ip.Results.actualLabels, ...
                                                M.classifierInfo.spaceUse, ...
                                                M.classifierInfo.timeUse, ...
                                                M.classifierInfo.featureUse);
                                     
    
    % SET RANDOM SEED
    % for data shuffling and permutation testing purposes
    rng(ip.Results.randomSeed);                                        
                                         
    % DATA SHUFFLING (doing)
    % Default 1
    if (ip.Results.shuffleData)
        disp('Shuffling Trials...');
        [X, Y, shuffledInd] = shuffleData(X, Y);
    else
        classifierInfo.shuffleData = 'off';
        Y = Y';maybe
    end

    %{
    % TRIAL AVERAGING (doing)
     if(ip.Results.averageTrials > 0)
        disp('Averaging Trials...');
        [X, Y] = averageTrials(X, Y, ip.Results.averageTrials, ...
            'handleRemainder' ,ip.Results.averageTrialsHandleRemainder);
        classifierInfo.averageTrials = 'on';
        [r c] = size(X);
     end
    %}

    
    % If PCA was turned on for training, we will select principal
    % compoenents for prediciton as well
    if (M.classifierInfo.PCA > 0) 
        testData = X*M.classifierInfo.PCA_V;
        testData = testData(:,1:M.classifierInfo.PCA_nPC);
    else
        testData = X;
    end
    
    % Predict Labels for Test Data
    disp('Predicting Model...')
    P.predY = modelPredict(testData, M.mdl);
    
    % Get Accuracy and confusion matrix
    if ( ~isnan(ip.Results.actualLabels) )
        P.accuracy = computeAccuracy(P.predY, Y); 
        P.CM = confusionmat(Y, P.predY);
    else
        P.accuracy = NaN; 
        P.CM = NaN;
    end
    
    predictionInfo = struct('actualLabels', ip.Results.actualLabels, ...    
%{                     
'averageTrials', ip.Results.averageTrials, ...
                   'averageTrialsHandleRemainder', ip.Results.averageTrialsHandleRemainder, ...
%}
                    'PCA', 1, ...
                    'PCA_V', M.classifierInfo.PCA_V, ...
                    'PCA_nPC', M.classifierInfo.PCA_nPC, ...
                    'spaceUse', M.classifierInfo.spaceUse, ...
                    'timeUse', M.classifierInfo.timeUse, ...
                    'featureUse', M.classifierInfo.featureUse, ...
                    'shuffleData', ip.Results.shuffleData,...
                    'randomSeed', ip.Results.randomSeed);
    
    P.predictionInfo = predictionInfo;
    
    disp('Prediction Finished')
    disp('classifyPredict() Finished!')



end
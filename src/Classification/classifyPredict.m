function [P, varargout] = classifyPredict(M, X, varargin)
% -------------------------------------------------------------------------
% [CM, accuracy, classifierInfo] = classifyPredict(X, Y)
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
%
% OUTPUT ARGS 
%   P - Prediciton output produced by classifyPredict().  This contains a
%   few fields: 
%       - P.predY, or the predicted labels for the input data
%       - P.accuracy, accuracy of predicted values compared to actual labels
%       - P.CM matrix of predicted values vs actual labels
%       - P.predictionInfo contians classification related information
%   Note that unless optional input 'actualLabels' is set, P.accuracy and 
%   P.confusionMatrix will be NaN.
%
%   If 'pairwise' was turned on for classifyTrain(), then the output will
%   be a cell array of prediction outputs P.  P will additionally include
%   the field "classBoundary", which contains length 2 array of which
%   classes are being comapred in the said boundary.  

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

    disp('Running classifyPredict()')

    ip = inputParser;
    ip.CaseSensitive = false;
    
    addRequired(ip, 'M');
    addRequired(ip, 'X', @is2Dor3DMatrix);
    
    defaultY = NaN;
    defaultRandomSeed = 'shuffle';
    defaultAverageTrials = -1;
    defaultAverageTrialsHandleRemainder = 'discard';
    
    expectedRandomSeed = {'default', 'shuffle'};
    expectedAverageTrialsHandleRemainder = {'discard','newGroup', 'append', 'distribute'};

    %addParameter(ip, 'actualLabels', defaultY, @(x) assert( isvector(x) ));
    %addOptional(ip, 'actualLabels', defaultY, @isvector);

    %{
	addParameter(ip, 'averageTrials', defaultAverageTrials, ...
        @(x) assert(rem(x,1) == 0 ));
    addParameter(ip, 'averageTrialsHandleRemainder', ...
        defaultAverageTrialsHandleRemainder, ...
        @(x) any(validatestring(x, expectedAverageTrialsHandleRemainder)));
    %}
    addParameter(ip, 'randomSeed', defaultRandomSeed,  @(x) isequal('default', x)...
        || isequal('shuffle', x) || (isnumeric(x) && x > 0));
%     addParameter(ip, 'pairwise', defaultRandomSeed,  @(x) isequal('default', x)...
%         || isequal('shuffle', x) || (isnumeric(x) && x > 0));
    
    try 
        parse(ip, M, X, varargin{:});
    catch ME
        disp(getReport(ME,'extended'));
    end
    
    tempM = M;
    if length(M) > 1 && iscell(M)
        tempM = M{1};
    end
    pairwise = tempM.classifierInfo.pairwise;
    
    % Check input data
    testDataSize = size(X);
    
%     if ( ~isnan(ip.Results.actualLabels) ) 
%         checkInputData(X, ip.Results.actualLabels);
%     end
    if (length(tempM.classifierInfo.trainingDataSize == 2))
        assert(tempM.classifierInfo.trainingDataSize(2) == testDataSize(2), ...
            'Dimension 2 (feature) of test data does not match Dimension 2 of training data used in classifyTrain().');
    elseif (length(tempM.classifierInfo.trainingDataSize == 3))
        assert(tempM.classifierInfo.trainingDataSize(1) == testDataSize(1), ...
            'Dimension 1 (space) of test data does not match Dimension 1 of training data used in classifyTrain().');
        assert(tempM.classifierInfo.trainingDataSize(2) == testDataSize(2), ...
            'Dimension 2 (time) of test data does not match Dimension 2 of training data used in classifyTrain().');

    else
        error('Data formatting issue.  Check input data matrix to classifyTrain and to classifyPredict');
    end
    
    % Subset data 
    [X, nSpace, nTime, nTrials] = subsetTrainTestMatrices(X, ...
                                                tempM.classifierInfo.spaceUse, ...
                                                tempM.classifierInfo.timeUse, ...
                                                tempM.classifierInfo.featureUse);
                                     
    
    % SET RANDOM SEED
    % for data shuffling and permutation testing purposes
    rng(ip.Results.randomSeed);                                        

    
    % If PCA was turned on for training, we will select principal
    % compoenents for prediciton as well
    if (tempM.classifierInfo.PCA > 0) 
        testData = X*tempM.classifierInfo.PCA_V;
        testData = testData(:,1:tempM.classifierInfo.PCA_nPC);
    else
        testData = X;
    end
    
    classifier = NaN;
    if iscell(M)
        classifier = M{1}.classifierInfo.classifier;
    else
        classifier = M.classifierInfo.classifier;
    end
    
    P = struct();
    
    % Predict Labels for Test Data
    disp('Predicting Model...')
        
    if (length(M) == 1) && ...
       (strcmp(classifier, 'LDA') || strcmp(classifier, 'RF'))
        
        P.predY = modelPredict(testData, M.mdl);
    
        % Get Accuracy and confusion matrix
%         if ( ~isnan(ip.Results.actualLabels) )
%             P.accuracy = computeAccuracy(P.predY, Y); 
%             P.CM = confusionmat(Y, P.predY);
%         else
%             P.accuracy = NaN; 
%             P.CM = NaN;
%         end

        predictionInfo = struct(...
                        'PCA', 1, ...
                        'PCA_V', M.classifierInfo.PCA_V, ...
                        'PCA_nPC', M.classifierInfo.PCA_nPC, ...
                        'spaceUse', M.classifierInfo.spaceUse, ...
                        'timeUse', M.classifierInfo.timeUse, ...
                        'featureUse', M.classifierInfo.featureUse, ...
                        'randomSeed', ip.Results.randomSeed);

        P.predictionInfo = predictionInfo;

        disp('Prediction Finished')
        disp('classifyPredict() Finished!')
        
    elseif (pairwise == 1 ) && strcmp(classifier, 'SVM')
        
        numClasses = M.classifierInfo.numClasses;
        numDecBounds = nchoosek(numClasses, 2);
        pairwiseCell = initPairwiseCellMat(numClasses);
        pairwiseMat3D = zeros(2,2, numDecBounds);
        decMatchups = nchoosek(1:numClasses, 2);
        
        [predictions decision_values] = modelPredict(testData, M.mdl);           
        
%         [pairwiseAccuracies, pairwiseMat3D, pairwiseCell] = ...
%             decValues2PairwiseAcc(pairwiseMat3D, testY, mdl.Label, decision_values, pairwiseCell);
        [r c] = size(decision_values);
        allPredictions = zeros(size(decision_values));
        for i = 1:r
            for j = 1:c
                decSign = sign(decision_values(i, j));
                if decSign > 0
                    allPredictions(i, j) = decMatchups(j,1);
                else
                    allPredictions(i, j) = decMatchups(j,2);
                end
            end
        end

        % convert decision values matrix into predictions
        P = cell(1, numDecBounds);
        predictionInfo = struct(...
                'PCA', 1, ...
                'PCA_V', M.classifierInfo.PCA_V, ...
                'PCA_nPC', M.classifierInfo.PCA_nPC, ...
                'spaceUse', M.classifierInfo.spaceUse, ...
                'timeUse', M.classifierInfo.timeUse, ...
                'featureUse', M.classifierInfo.featureUse, ...
                'randomSeed', ip.Results.randomSeed);
            
        for i = 1:numDecBounds
            P{i}.predY = allPredictions(:, i);  
            P{i}.predictionInfo = predictionInfo;
            P{i}.predictionInfo.classBoundary = decMatchups(i,:);
        end
        
        disp('Prediction Finished')
        disp('classifyPredict() Finished!')
    
    elseif (length(M) > 1) && ...
            (strcmp(classifier, 'LDA') || strcmp(classifier, 'RF'))
        
        numClasses = tempM.classifierInfo.numClasses;
        numDecBounds = length(M);
        P = cell(1, numDecBounds);
        decMatchups = nchoosek(1:numClasses, 2);

        for i = 1:numDecBounds
            [~, P{i}] = evalc(' classifyPredict(M{i}, X) ' );
            P{i}.predictionInfo.classBoundary = decMatchups(i, :);
            %P{i} = classifyPredict(M{i}, X);            
        end
        
    
    end
    
    



end
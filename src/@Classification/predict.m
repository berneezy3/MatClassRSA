function [P, varargout] = predict(obj,M, X, varargin)
% -------------------------------------------------------------------------
% RSA = MatClassRSA;
% [CM, accuracy, classifierInfo] = RSA.classify.predict(X, Y)
% -------------------------------------------------------------------------
% Blair/Bernard - Feb. 22, 2017
%
% Given test data and a model trained by trainMulti or trainMulti_opt, this
% function predicts the labels of the test data. 
%
% INPUT ARGS 
%   M (REQUIRED) - EEG Model (output from classifyTrain)
%   X (REQUIRED) - training data
%   actualLabels (OPTIONAl) - actual labels of test data X.  Length of this vector
%   must equal the number of trials in X.
%
% INPUT ARGS (OPTIONAL NAME-VALUE PAIRS)
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
    expectedRandomSeed = {'default', 'shuffle'};
    expectedAverageTrialsHandleRemainder = {'discard','newGroup', 'append', 'distribute'};
    addOptional(ip, 'actualLabels', defaultY, @isvector);
    addParameter(ip, 'randomSeed', defaultRandomSeed,  @(x) isequal('default', x)...
        || isequal('shuffle', x) || (isnumeric(x) && x > 0));
    

    parse(ip, M, X, varargin{:});

    
    tempInfo = M.classifierInfo;
    if length(M.classifierInfo) > 1 && iscell(M.classifierInfo)
        tempInfo = M.classifierInfo{1};
    end
    
    % Check input data
    testDataSize = size(X);
    
    if (length(tempInfo.trainingDataSize == 2))
        assert(tempInfo.trainingDataSize(2) == testDataSize(2), ...
            'Dimension 2 (feature) of test data does not match Dimension 2 of training data used in classifyTrain().');
    elseif (length(tempInfo.trainingDataSize == 3))
        assert(tempM.classifierInfo.trainingDataSize(1) == testDataSize(1), ...
            'Dimension 1 (space) of test data does not match Dimension 1 of training data used in classifyTrain().');
        assert(tempInfo.trainingDataSize(2) == testDataSize(2), ...
            'Dimension 2 (time) of test data does not match Dimension 2 of training data used in classifyTrain().');
    else
        error('Data formatting issue.  Check input data matrix to classifyTrain and to classifyPredict');
    end
    
    % Subset data 
    [X, nSpace, nTime, nTrials] = subsetTrainTestMatrices(X, ...
                                                tempInfo.spaceUse, ...
                                                tempInfo.timeUse, ...
                                                tempInfo.featureUse);
                                     
    
    % SET RANDOM SEED
    % for data shuffling and permutation testing purposes
    rng(ip.Results.randomSeed);                                        

    RSA = MatClassRSA;    
    P = struct();
    
    % Predict Labels for Test Data
    disp('Predicting Model...')
        
    % CASE: multiclass classification
    if (M.pairwise == 0)
    
        % If PCA was turned on for training, we will select principal
        % compoenents for prediciton as well
        if (M.classifierInfo.PCA > 0) 
            [X, ~, ~] = centerAndScaleData(X, M.classifierInfo.colMeans, M.classifierInfo.colScales);
            testData = X*M.classifierInfo.PCA_V;
            testData = testData(:,1:M.classifierInfo.PCA_nPC);
        else
            testData = X;
        end
        
        P.predY = modelPredict(testData, M.mdl, M.scale);
    
        % Get Accuracy and confusion matrix
        if ( ~isnan(ip.Results.actualLabels) )
            Y = ip.Results.actualLabels;
            P.accuracy = computeAccuracy(P.predY, Y); 
            P.CM = confusionmat(Y, P.predY);
        else
            P.accuracy = NaN; 
            P.CM = NaN;
        end

        predictionInfo = struct(...
                        'PCA', 1, ...
                        'PCA_V', M.classifierInfo.PCA_V, ...
                        'PCA_nPC', M.classifierInfo.PCA_nPC, ...
                        'spaceUse', M.classifierInfo.spaceUse, ...
                        'timeUse', M.classifierInfo.timeUse, ...
                        'featureUse', M.classifierInfo.featureUse, ...
                        'randomSeed', ip.Results.randomSeed);

        P.predictionInfo = predictionInfo;
        P.classifiationInfo = M.classifierInfo;
        P.model = M.mdl;
        disp('Prediction Finished')
        disp('classifyPredict() Finished!')
        
    % CASE: pairwise classification for LDA, RF and SVM (w/ PCA)
    elseif (M.pairwise == 1 && length(M.classifierInfo) > 1)
      
        numClasses = tempInfo.numClasses;
        numDecBounds = length(M.mdl);
        predY = cell(1, numDecBounds);
        P.AM = NaN(numClasses, numClasses);
        Y = ip.Results.actualLabels;    

        [firstClass, secondClass] = getNChoose2Ind(numClasses);
%         P.predictionInfo = cell(1, numDecBounds);
%         P.accuracy = cell(1, numDecBounds);
        P.CM = cell(numClasses, numClasses);
        P.CM(:,:) = {NaN};
        P.classificationInfo = struct();
        P.pairwiseInfo = struct();
        pairwiseCell = initPairwiseCellMat(numClasses);
        decMatchups = nchoosek(1:numClasses, 2);

        for i = 1:numDecBounds
            % If PCA was turned on for training, we will select principal
            % compoenents for prediciton as well
            class1 = firstClass(i);
            class2 = secondClass(i);
            currUse = ismember(Y, [class1 class2]);
            
            tempX = X(currUse, :);
            tempY =  ip.Results.actualLabels(currUse);

            tempInfo = M.classifierInfo{i};
            if (tempInfo.PCA > 0) 
                [tempX, ~, ~] = centerAndScaleData(tempX, tempInfo.colMeans, tempInfo.colScales);
                testData = tempX*tempInfo.PCA_V;
                testData = testData(:,1:tempInfo.PCA_nPC);
            else
                testData = tempX;
            end
            
            predY{i} = modelPredict(testData, M.mdl{i}, M.scale{i});
%             P.classBoundary{i} = [num2str(firstClass(i)) ' vs. ' num2str(secondClass(i))];
%             P.predictionInfo{i}.classBoundary = decMatchups(i, :);
            P.classificationInfo.classBoundary{i} = [num2str(firstClass(i)) ' vs. ' num2str(secondClass(i))];
            
            tempStruct = struct();
           % Get Accuracy and confusion matrix
            if ( ~isnan(ip.Results.actualLabels) )
%                 P.accuracy{i} = computeAccuracy(predY{i}, tempY); 
                P.CM{class1, class2} = confusionmat(tempY, predY{i});
                P.CM{class2, class1} = P.CM{class1, class2};

                P.AM(class1, class2) = sum(diag(P.CM{class1, class2}))/sum(sum(P.CM{class1, class2}));
                P.AM(class2, class1) = P.AM(class1, class2); 
            else
%                 P.accuracy{i} = NaN; 
                P.CM{i} = NaN;
            end
           
                
            tempStruct.classBoundary = [num2str(class1) ' vs. ' num2str(class2)];
            tempStruct.accuracy = sum(diag(P.CM{class1, class2}))/sum(sum(P.CM{class1, class2}));
            tempStruct.actualY = tempY;
            tempStruct.predY = predY';
                
                
            %tempStruct.decision
%             AM(class1, class2) = tempStruct.accuracy;
%             AM(class2, class1) = tempStruct.accuracy;
%             modelsConcat(:, classTuple2Nchoose2Ind([class1, class2], 6)) = ...
%                 tempC.modelsConcat';
            pairwiseCell{class1, class2} = tempStruct;
            pairwiseCell{class2, class1} = tempStruct;
         
        end
        
        P.pairwiseInfo = pairwiseCell;


    % CASE: pairwise classification SVM w/ PCA off (correct AM!!!)
    elseif (M.pairwise == 1 && length(M.classifierInfo) == 1 && strcmp(M.classifier, 'SVM'))
        
        numClasses = M.classifierInfo.numClasses;
        numDecBounds = nchoosek(numClasses, 2);
        pairwiseCell = initPairwiseCellMat(numClasses);
        pairwiseMat3D = zeros(2,2, numDecBounds);
        decMatchups = nchoosek(1:numClasses, 2);
        AM = NaN(numClasses, numClasses);

        
        [predictions decision_values] = modelPredict(X, M.mdl, M.scale);           
        
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
        P = struct();
%         P.predY = {};
%         P.predictionInfo = {};
%         P = cell(1, numDecBounds);

        
        predictionInfo = struct(...
                'PCA', 1, ...
                'PCA_V', M.classifierInfo.PCA_V, ...
                'PCA_nPC', M.classifierInfo.PCA_nPC, ...
                'spaceUse', M.classifierInfo.spaceUse, ...
                'timeUse', M.classifierInfo.timeUse, ...
                'featureUse', M.classifierInfo.featureUse, ...
                'randomSeed', ip.Results.randomSeed);
        
        pairwiseMat3D = zeros(2,2, numDecBounds);
        
        if (sum(contains( fieldnames( ip.Results) , 'actualLabels' )))
            [P.AM, ~, P.CM] = ...
            decValues2PairwiseAcc(pairwiseMat3D, ip.Results.actualLabels, M.mdl.Label, decision_values, pairwiseCell);
        end
        

        for i = 1:numDecBounds
%             P.predY{i} = allPredictions(:, i);  
            P.classBoundary{i} = [ decMatchups(i,1) ' vs. ' decMatchups(i,2)];
%             P.predictionInfo{i}.classBoundary = decMatchups(i,:);
%             P.accuracy{i} = predictions/;
        end
        
    end
    
    disp('Prediction Finished')
    disp('classifyPredict() Finished!')

end
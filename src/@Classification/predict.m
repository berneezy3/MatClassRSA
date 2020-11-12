function P = predict(obj, M, X, varargin)
% -------------------------------------------------------------------------
% RSA = MatClassRSA;
% % any of the train functions could be used in the following line
% M = RSA.Classification.trainModel(trainData, testData); 
% P = RSA.classify.predict(M, X, Y)
% -------------------------------------------------------------------------
% Blair/Bernard - Feb. 22, 2017
%
% Given a MatClassRSA classification model and input data X, this function
% will predict the labels of the trials contained in X.
%
% INPUT ARGS 
%   M (REQUIRED) - EEG Model (output from either trainMulti(), 
%       trainMulti_opt(), trainPairs(), or trainPairs_opt())
%   X (REQUIRED) - Data matrix.  Either a 2D (trial-by-feature) matrix or a 3D 
%       (space-by-time-by-trial) matrix. 
%   actualLabels (OPTIONAl) - Vector of trial labels. The length of Y must match the length of
%       the trial dimension of X. 
%
%
% OUTPUT ARGS 
%   P - Prediciton output produced by classifyPredict(), which may slightly 
%   differ depending on which function is used to train the model M.  If
%   the classification model M was created using trainMulti() or
%   trainMulti_opt(), the P will contain the following fields:
%       - P.predY, or the predicted labels for the input data
%       - P.accuracy, accuracy of predicted values compared to actual labels
%       - P.CM matrix of predicted values vs actual labels
%       - P.predictionInfo contians prediction related information
%       - P.classificationInfo contains classification related info
%       - P.model contains classification model(s)
%   Note that unless optional input 'actualLabels' is set, P.accuracy and 
%   P.confusionMatrix will be NaN.
%   If M was created using trainPairs() or trainPairs_opt(), then the
%   following fields will be in P:
%       - P.AM, a diagonal matrix containing the pairwise accuracies
%       - modelsConcat contains a concatenated list of classifiation
%       model(s)
%       - P.predictionInfo contians prediction related information
%       - P.classificationInfo contains classification related info

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
    addOptional(ip, 'actualLabels', defaultY, @isvector);
    addParameter(ip, 'permutations', 0);

    parse(ip, M, X, varargin{:});

    tempInfo = M.classifierInfo;
    if length(M.classifierInfo) > 1 && iscell(M.classifierInfo)
        tempInfo = M.classifierInfo{1};
    end
    
    % Check input data
    testDataSize = size(X);
    
    % Subset data 
    [X, nSpace, nTime, nTrials] = subsetTrainTestMatrices(X, ...
                                                tempInfo.spaceUse, ...
                                                tempInfo.timeUse, ...
                                                tempInfo.featureUse);

    if (length(M.classifierInfo) > 1)
        classifierInfo = M.classifierInfo{1};
    else
        classifierInfo = M.classifierInfo;
    end
    
    % SET RANDOM SEED
    % for data shuffling and permutation testing purposes
    rng(classifierInfo.randomSeed);                                        

    RSA = MatClassRSA;    
    P = struct();
    
    % Principal Component Analysis
    %initialize variables
    trainData = M.trainData;
    trainLabels = M.trainLabels;
    testLabels = ip.Results.actualLabels;        
    trainTestSplit = [length(trainLabels) length(testLabels)];
    


    PCA = classifierInfo.PCA;

    % Predict Labels for Test Data
    disp('Predicting Model...')
        
    % CASE: multiclass classification
    if (M.pairwise == 0)
    
        % PCA
        if (classifierInfo.PCA > 0) 
            [X, ~, ~] = centerAndScaleData(X, classifierInfo.colMeans, classifierInfo.colScales);
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
            if ( ip.Results.permutations ~= 0 )
                P.pVal = permTestPVal(P.accuracy, accDist);
            end
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
                        'randomSeed', M.classifierInfo.randomSeed);

        P.predictionInfo = predictionInfo;
        P.classifiationInfo = M.classifierInfo;
        P.model = M.mdl;
        disp('Prediction Finished')
        disp('classifyPredict() Finished!')
        
    % CASE: pairwise classification for LDA, RF and SVM (w/ PCA)
    elseif (M.pairwise == 1 && length(M.classifierInfo) > 1 && ...
             (strcmp(M.classifier, 'LDA') || strcmp(M.classifier, 'RF') || ...
            (strcmp(M.classifier, 'SVM') && PCA > 0)))
      
        numClasses = tempInfo.numClasses;
        numDecBounds = length(M.mdl);
        predY = cell(1, numDecBounds);
        P.AM = NaN(numClasses, numClasses);
        Y = ip.Results.actualLabels;    

%         [firstClass, secondClass] = getNChoose2Ind(numClasses);
        classPairs = nchoosek(1:numClasses, 2);

%         P.predictionInfo = cell(1, numDecBounds);
%         P.accuracy = cell(1, numDecBounds);
%         P.CM = cell(numClasses, numClasses);
%         P.CM(:,:) = {NaN};
        P.classificationInfo = struct();
        P.pairwiseInfo = struct();
        pairwiseCell = initPairwiseCellMat(numClasses);
        decMatchups = nchoosek(1:numClasses, 2);
        
        classifierInfo = struct(...
            'PCA', M.classifierInfo{1}.PCA, ...
            'classifier', M.classifierInfo{1}.classifier);
        P.classificationInfo = classifierInfo;
        
        % Initilize info struct
        for i = 1:numDecBounds
            
            class1 = classPairs(i, 1);
            class2 = classPairs(i, 2);
            currUse = ismember(Y, [class1 class2]);
            
            tempX = X(currUse, :);
            tempY = ip.Results.actualLabels(currUse);
            
            % PCA
            [tempX_PCA, ~, ~] = centerAndScaleData(tempX, ...
                M.classifierInfo{i}.colMeans, M.classifierInfo{i}.colScales);
            testData = tempX_PCA*M.classifierInfo{i}.PCA_V;
            testData = testData(:,1:M.classifierInfo{i}.PCA_nPC);

            tempInfo = M.classifierInfo{i};

            predY{i} = modelPredict(testData, M.mdl{i}, M.scale{i});
            P.classificationInfo.classBoundary{i} = [num2str(class1) ' vs. ' num2str(class2)];
            
            tempStruct = struct();
           % Get Accuracy and confusion matrix
            if ( ~isnan(ip.Results.actualLabels) )
%                 P.accuracy{i} = computeAccuracy(predY{i}, tempY); 
%                 P.CM{class1, class2} = confusionmat(tempY, predY{i});
%                 P.CM{class2, class1} = P.CM{class1, class2};
                thisCM = confusionmat(tempY, predY{i});
                P.AM(class1, class2) = sum(diag(thisCM))/sum(sum(thisCM));
                P.AM(class2, class1) = P.AM(class1, class2); 
            else
%                 P.accuracy{i} = NaN; 
%                 P.CM{i} = NaN;
            end
           
                
            tempStruct.classBoundary = [num2str(class1) ' vs. ' num2str(class2)];
            tempStruct.accuracy = sum(diag(thisCM))/sum(sum(thisCM));
            tempStruct.actualY = tempY;
            tempStruct.predY = predY';
            tempStruct.CM = thisCM;
                
            pairwiseCell{class1, class2} = tempStruct;
            pairwiseCell{class2, class1} = tempStruct;
         
        end
        
        % calculate pVal return matrix for all pairs. 
        if (ip.Results.permutations > 0) && sum(~isnan(ip.Results.actualLabels))
            P.pVal = nan(numClasses, numClasses);
            for class1 = 1:numClasses-1
                for class2 = (class1+1):numClasses
                    thisAccDist = accDist(class1, class2, :);
                    P.pVal(class1, class2) = permTestPVal(P.AM(class1, class2), thisAccDist);
                    P.pVal(class2, class1) = P.pVal(class1, class2);
                end
            end
        end
        P.pairwiseInfo = pairwiseCell;
        P.modelsConcat = M.mdl;

    % CASE: pairwise classification SVM w/ PCA off (correct AM!!!)
    elseif (M.pairwise == 1 && length(M.classifierInfo) == 1 ...
            && strcmp(M.classifier, 'SVM') && PCA<=0)
        
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
            [P.AM, ~, P.pairwiseInfo] = ...
            decValues2PairwiseAcc(pairwiseMat3D, ip.Results.actualLabels, M.mdl.Label, decision_values, pairwiseCell);
        end
        
        P.mdl = M.mdl;
        P.classificationInfo = struct(...
            'PCA', M.classifierInfo.PCA, ...
            'classifier', M.classifierInfo.classifier);
        
    end
    
%     %PERMUTATION TEST (assigning)
%     if (ip.Results.permutations > 0) && sum(~isnan(ip.Results.actualLabels))
%         % return distribution of accuracies (Correct clasification percentage)
% 
%         M.cvDataObj.testXall{1} = testData;
%         M.cvDataObj.testYall{1} = ip.Results.actualLabels;
% 
%         accDist = permuteModel(M.functionName, [trainData; testData], ...
%                     [trainLabels; testLabels], ...
%                     M.cvDataObj, 1, ip.Results.permutations , ...
%                     M.classifier, trainTestSplit, M.ip);
%     end
    
    
    disp('Prediction Finished')
    disp('classifyPredict() Finished!')

end
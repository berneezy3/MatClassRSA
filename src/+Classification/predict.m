function P = predict(M, X, varargin)
% -------------------------------------------------------------------------
% % any of the train functions could be used in the following line
% M = Classification.trainMulti(X, Y); 
% P = Classification.predict(M, X)
% -------------------------------------------------------------------------
%
% Given a MatClassRSA classification model and input data X, this function
% will predict the labels of the trials contained in X.
%
% INPUT ARGS (REQUIRED)
%   M - EEG Model (output from either trainMulti(), 
%       trainMulti_opt(), trainPairs(), or trainPairs_opt())
%   X - Data matrix.  Either a 2D (trial-by-feature) matrix or a 3D 
%       (space-by-time-by-trial) matrix. 
%
% INPUT ARGS (OPTIONAL NAME-VALUE PAIRS)
%   actualLabels - Vector of trial labels. The length of Y must match the 
%       length of the trial dimension of X. 
%   permTestData - Data used to conduct permutation testing.  This 
%       corresponds to the second output from trainMulti_opt(), trainPairs(), 
%       or trainPairs_opt().  This input is required if permutation testing 
%       is turned on.
%       --note on permutation testing--
%       Permutation testing in this function depends on which function and 
%       classifier was called to train the model (i.e., trainMulti(), 
%       trainMulti_opt(), trainPairs(), trainPairs_opt()). Specifically, 
%       for each train function, details of permutation testing are given 
%       in the corresponding crossValidate function. For instance, if 
%       trainMulti() was used, then the permutation testing implementation 
%       is designed to match that of crossValidateMulti(). Please refer 
%       to the permutations section in the corresponding crossValidate 
%       function documentation or the code docstring to learn more.
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
%       - P.pVal contains the permutation testing p-vaue
%   Note that unless optional input 'actualLabels' is set, P.accuracy and 
%   P.confusionMatrix will be NaN.
%   If M was created using trainPairs() or trainPairs_opt(), then the
%   following fields will be in P:
%       - P.AM, a diagonal matrix containing the pairwise accuracies
%       - P.modelsConcat contains a concatenated list of classifiation
%       model(s)
%       - P.predictionInfo contians prediction related information
%       - P.classificationInfo contains classification related info
%       - P.pValMat contains a matrix of p-values, in which each off-diagonal
%         element corresponds to every pair of labels. 
%   permAccs - Permutation testing accuracies.  This field will be NaN if 
%       permuatation testing is not specfied.  
%   classificationInfo - This struct contains the specifications used
%       during classification, including 'PCA', 'PCAinFold', 'nFolds', 
%       'classifier' and 'dataPartitionObj'
%   dataPartitionObj - This struct contains the train/test data partitions 
%       for cross validation (and a dev data partition if hyperparameter 
%       optimization is specified).
%
% MatClassRSA dependencies (all +Utils): is2Dor3DMatrix(),
%   subsetTrainTestMatrices(), setUserSpecifiedRng(), centerAndScaleData(),
%   modelPredict(), computeAccuracy(), fitModel(), modelPredict(),
%   computeAccuracy(), permTestPVal(), trainDevGridSearch(),
%   nestedCvGridSearch(), initPairwiseCellMat(), decValues2PairwiseAcc()

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

    disp('Running classifyPredict()')
    predict_time = tic;

    ip = inputParser;
    ip.CaseSensitive = false;
    
    addRequired(ip, 'M');
    addRequired(ip, 'X', @Utils.is2Dor3DMatrix);
    defaultY = NaN;
    addParameter(ip, 'actualLabels', defaultY, @isvector);
    addParameter(ip, 'permTestData', defaultY, @isvector);
    addParameter(ip, 'permutations', 0);

    parse(ip, M, X, varargin{:});

    if length(M.classificationInfo) >= 1 && iscell(M.classificationInfo)
        tempInfo = M.classificationInfo{1};
    else
        tempInfo = M.classificationInfo;
    end
    
    % check for permTestData and initialize data variables
    if (~isnan(ip.Results.permutations) && ip.Results.permutations > 0)
       if (~iscell(ip.Results.permTestData))
           error(['If permutation testing is specified, then input parameter' ...
               ' permTestData must be passed in as well.']);
       end
    end
    
    % Check input data
    testDataSize = size(X);
    
    % Subset data 
    [X, nSpace, nTime, nTrials] = Utils.subsetTrainTestMatrices(X, ...
                                                tempInfo.spaceUse, ...
                                                tempInfo.timeUse, ...
                                                tempInfo.featureUse);

    % everything is 2D moving forward, regardless of staring dimensions
    
    if (iscell(M.classificationInfo))
        classifierInfo = M.classificationInfo{1};
    else
        classifierInfo = M.classificationInfo;
    end
    
    % SET RANDOM SEED
    % for data shuffling and permutation testing purposes
    % rng(classifierInfo.rngType);
    Utils.setUserSpecifiedRng(classifierInfo.rngType);
    

    % Predict Labels for Test Data
    disp('Predicting Test Data Labels...')
        
    %%%%% multiclass classification %%%%%
    
    % model info is stored one field deeper for optimization functions
    if(strcmp(M.functionName, 'trainMulti_opt') || ...
            strcmp(M.functionName, 'trainPairs_opt'))
       M.mdl= M.mdl.mdl;
    end
    
    % model info is stored one field deeper for crossValidateMulti_opt
    if(strcmp(M.functionName, 'crossValidateMulti_opt'))
       M.mdl= M.modelsConcat{1};
    end
    
    %initialize variables
    testLabels = ip.Results.actualLabels;        
    PCA = classifierInfo.PCA;
    P = struct();
    
    % When model comes from  either trainMulti() or trainMulti_opt()
    if (strcmp(M.functionName, 'trainMulti') || ...
            strcmp(M.functionName, 'trainMulti_opt'))
        
        % PCA
        if (PCA > 0) 
            [X, ~, ~] = Utils.centerAndScaleData(X, classifierInfo.colMeans, classifierInfo.colScales);
            testData = X*M.classificationInfo.PCA_V;
            testData = testData(:,1:M.classificationInfo.PCA_nPC);
            
        else
            testData = X;
        end
        
        [P.predY, decision_values] = Utils.modelPredict(testData, M.mdl, M.scale);
    
        % Get Accuracy and confusion matrix
        if ( ~isnan(ip.Results.actualLabels) )
            Y = ip.Results.actualLabels;
            P.accuracy = Utils.computeAccuracy(P.predY, Y); 
            P.CM = confusionmat(Y, P.predY);
        else
            P.accuracy = NaN; 
            P.CM = NaN;
        end

        predictionInfo = struct(...
                        'PCA', 1, ...
                        'PCA_V', M.classificationInfo.PCA_V, ...
                        'PCA_nPC', M.classificationInfo.PCA_nPC, ...
                        'spaceUse', M.classificationInfo.spaceUse, ...
                        'timeUse', M.classificationInfo.timeUse, ...
                        'featureUse', M.classificationInfo.featureUse, ...
                        'rngType', M.classificationInfo.rngType ,...
                        'decisionValues', decision_values);

        P.predictionInfo = predictionInfo;
        P.classificationInfo = M.classificationInfo;
        P.model = M.mdl;
        disp('Prediction Finished')        
            
        %PERMUTATION TEST (assigning)
        if (ip.Results.permutations > 0) && sum(~isnan(ip.Results.actualLabels))
            % return distribution of accuracies (Correct clasification percentage)
            
            disp('Conducting Permutation Test...');

            numTrials = length(trainLabels);
           
            accDist = zeros(ip.Results.permutations, 1);
            trainData = ip.Results.permTestData.X;
            trainLabels = ip.Results.permTestData.Y;
            
            if (strcmp(M.functionName, 'trainMulti'))
                for i = 1:ip.Results.permutations
                    disp(['Permutation ' num2str(i) ' of ' num2str(ip.Results.permutations)]);
                    pTrainLabels = trainLabels(randperm(numTrials));
                    [pMdl, ~] = Utils.fitModel(trainData, pTrainLabels, M.ip, M.ip.Results.gamma, M.ip.Results.C); 
                    predictedY = Utils.modelPredict(testData, pMdl, M.classificationInfo.ip);
                    %store accuracy
                    accDist(i) = Utils.computeAccuracy(testLabels , predictedY);
                end
                P.pVal = Utils.permTestPVal(P.accuracy, accDist);
            
            elseif (strcmp(M.functionName, 'trainMulti_opt'))
                numTrials = length(trainLabels);
                
                for i = 1:ip.Results.permutations
                    
                    % Train model
                    disp(['Permutation ' num2str(i) ' of ' num2str(ip.Results.permutations)]);
                    if (strcmp(M.ip.Results.optimization, 'singleFold'))
                        devData = ip.Results.permTestData.devData;
                        devLabels = ip.Results.permTestData.devLabels;
                        pTrainLabels = trainLabels(randperm(numTrials));
                        [pTrainData, pDevData, pTrainLabels, pDevLabels] ...
                            = permuteTrainDevData(trainData, devData, ...
                                                    pTrainLabels, devLabels);
                        [pGamma_opt, pC_opt] = Utils.trainDevGridSearch(pTrainData, pTrainLabels, ...
                            pDevData, pDevLabels, M.ip);
                        [pMdl, ~] = fitModel(X, Y, M.ip, pGamma_opt, pC_opt);
                        predictedY = Utils.modelPredict(testData, pMdl, M.classificationInfo.ip);
                        accDist(i) = Utils.computeAccuracy(testLabels , predictedY);
                        
                    else   
                    % nested CV optimization
                        pTrainLabels = trainLabels(randperm(numTrials), :);
                        [pGamma_opt, pC_opt] = Utils.nestedCvGridSearch(trainData, pTrainLabels, M.ip);
                        [pMdl, ~] = Utils.fitModel(trainData, pTrainLabels, M.ip, M.gamma_opt, M.C_opt);
                        predictedY = Utils.modelPredict(testData, pMdl, M.classificationInfo.ip);
                        accDist(i) = Utils.computeAccuracy(testLabels , predictedY);
                    end
                end
                P.pVal = Utils.permTestPVal(P.accuracy, accDist);
            end

        end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% Pairwise classification for LDA, RF, SVM (w/PCA) %%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ( strcmp(M.functionName, 'trainPairs') || ...
            (strcmp(M.functionName, 'trainPairs_opt') && (M.ip.results.PCA > 0)) ) 
      
        numClasses = M.classifierInfo{1}.numClasses;
        numDecBounds = length(M.mdl);
        predY = cell(1, numDecBounds);
        P.AM = NaN(numClasses, numClasses);
        Y = ip.Results.actualLabels;    


        classPairs = nchoosek(1:numClasses, 2);


        P.classificationInfo = struct();
        P.pairwiseInfo = struct();
        pairwiseCell = Utils.initPairwiseCellMat(numClasses);
        decMatchups = nchoosek(1:numClasses, 2);
        
        classifierInfo = struct(...
            'PCA', M.classificationInfo{1}.PCA, ...
            'classifier', M.classificationInfo{1}.classifier);
        P.classificationInfo = classifierInfo;
        
        % Initilize info struct
        for i = 1:numDecBounds
            
            class1 = classPairs(i, 1);
            class2 = classPairs(i, 2);
            
            currUse = ismember(Y, [class1 class2]);
            
            tempX = X(currUse, :);
            tempY = ip.Results.actualLabels(currUse);
            
            % PCA
            if (M.ip.Results.PCA > 0) 
                [tempX_PCA, ~, ~] = Utils.centerAndScaleData(tempX, M.classificationInfo{i}.colMeans, M.classificationInfo{i}.colScales);
               
                testData = tempX_PCA*M.classificationInfo{i}.PCA_V;
                testData = testData(:,1:M.classificationInfo{i}.PCA_nPC);
            else
                testData = tempX;
            end

            tempInfo = M.classificationInfo{i};

            predY{i} = Utils.modelPredict(testData, M.mdl{i}, M.scale{i});
            P.classificationInfo.classBoundary{i} = [num2str(class1) ' vs. ' num2str(class2)];
            
            tempStruct = struct();
           % Get Accuracy and confusion matrix
            if ( ~isnan(ip.Results.actualLabels) )
                thisCM = confusionmat(tempY, predY{i});
                P.AM(class1, class2) = sum(diag(thisCM))/sum(sum(thisCM));
                P.AM(class2, class1) = P.AM(class1, class2); 
            else
%                 P.accuracy{i} = NaN; 
%                 P.CM{i} = NaN;
                warning('NaNs detected in actualLabels parameter - output accuracy/confusion matrix may contain NaNs');
                thisCM = confusionmat(tempY, predY{i});
                P.AM(class1, class2) = sum(diag(thisCM))/sum(sum(thisCM));
                P.AM(class2, class1) = P.AM(class1, class2); 
            end
                
            tempStruct.classBoundary = [num2str(class1) ' vs. ' num2str(class2)];
            tempStruct.accuracy = sum(diag(thisCM))/sum(sum(thisCM));
            tempStruct.actualY = tempY;
            tempStruct.predY = predY';
            tempStruct.CM = thisCM;
                
            pairwiseCell{class1, class2} = tempStruct;
            pairwiseCell{class2, class1} = tempStruct;
         
        end
        
        % Permutation testing and calculate pVal
        if (ip.Results.permutations > 0) && sum(~isnan(ip.Results.actualLabels))
            
            disp('Conducting permutation testing...');
            accMatDist = nan(numClasses, numClasses, ip.Results.permutations);
            pValMat = nan(numClasses, numClasses);
            
            if (strcmp(M.functionName, 'trainMulti_opt') && M.ip.Results.PCA <= 0)
                
            	for i = 1:ip.Results.nFolds

                    disp(['Computing fold ' num2str(i) ' of ' num2str(ip.Results.nFolds) '...'])

                    trainX = cvDataObj.trainXall{i};
                    trainY = cvDataObj.trainYall{i};
                    testX = cvDataObj.testXall{i};
                    testY = cvDataObj.testYall{i};

                     % conduct grid search here
                     if (strcmp(M.ip.Results.optimization, 'nestedCV'))
                        [gamma_opt, C_opt] = Utils.nestedCvGridSearch(trainX, pTrainY, cvDataObj, ip);
                     elseif (strcmp(M.ip.Results.optimization, 'singleFold'))
                        devX = cvDataObj.devXall{1};
                        devY = cvDataObj.devYall{1};
                        trainDevY = [trainY; devY];
                        pTrainDevY = trainDevY(randperm(length(trainDevY)), :);
                        pTrainY = pTrainDevY(1:length(trainY));
                        pDevY = pTrainDevY(length(trainY)+1:end);

                        [gamma_opt, C_opt] = Utils.trainDevGridSearch(trainX, pTrainY, ...
                            devX, pDevY, ip);
                    end

                    [mdl, scale] = Utils.fitModel(trainX, trainY, ip, gamma_opt, C_opt);

                    [predictions, decision_values] = Utils.modelPredict(testX, mdl, scale);

                    labelsConcat = [labelsConcat testY];
                    predictionsConcat = [predictionsConcat predictions];
                    modelsConcat{i} = mdl; 

                    if strcmp(upper(ip.Results.classifier), 'SVM')
                        [pairwiseAccuracies, pairwiseMat3D, pairwiseCell] = ...
                            Utils.decValues2PairwiseAcc(pairwiseMat3D, testY, mdl.Label, decision_values, pairwiseCell);
                    end
                end
        
                %convert pairwiseMat3D to diagonal matrix
                C.pairwiseInfo = pairwiseCell;
                C.AM = pairwiseAccuracies;                
                
            else

                for j = 1:numDecBounds

                    trainX = ip.Results.permTestData{j}.trainXall{1};
                    trainY = ip.Results.permTestData{j}.trainYall{1};
                    class1 = classPairs(j, 1);
                    class2 = classPairs(j, 2);

                    for i = 1:ip.Results.permutations  

                        l = length(trainY);
                        pY = trainY(randperm(l), :);
                        currUse = ismember(Y, [class1 class2]);
            
                        tempX = X(currUse, :);
                        tempY = Y(currUse);
                        evalc(['pM = Classification.trainMulti(trainX, pY,'  ...
                            ' ''classifier'', M.classifier,' ...
                            ' ''PCA'', 0,''numTrees'', M.ip.Results.numTrees,' ...
                            ' ''minLeafSize'', M.ip.Results.minLeafSize, ' ...
                            ' ''PCA'', M.ip.Results.PCA);']);

                        evalc(['pC = obj.predict(pM, tempX, ''actualLabels'', tempY)']);
                        accMatDist(class1, class2, i) = pC.accuracy;
                        accMatDist(class2, class1, i) = pC.accuracy;

                    end

                    pValMat(class1, class2) = Utils.permTestPVal(P.AM(class1, class2), ...
                        squeeze(accMatDist(class1, class2, :)));
                    pValMat(class2, class1) = pValMat(class1, class2);
                end
            end
            P.pValMat = pValMat;
        end
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% Pairwise classification SVM w/ PCA off %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif ((strcmp(M.functionName, 'trainPairs_opt') && (M.ip.results.PCA <= 0)))
        
        numClasses = M.classificationInfo.numClasses;
        numDecBounds = nchoosek(numClasses, 2);
        pairwiseCell = Utils.initPairwiseCellMat(numClasses);
        pairwiseMat3D = zeros(2,2, numDecBounds);
        decMatchups = nchoosek(1:numClasses, 2);
        AM = NaN(numClasses, numClasses);
        
        [predictions decision_values] = Utils.modelPredict(X, M.mdl, M.scale);           
        
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


        
        predictionInfo = struct(...
                'PCA', 1, ...
                'PCA_V', M.classificationInfo.PCA_V, ...
                'PCA_nPC', M.classificationInfo.PCA_nPC, ...
                'spaceUse', M.classificationInfo.spaceUse, ...
                'timeUse', M.classificationInfo.timeUse, ...
                'featureUse', M.classificationInfo.featureUse, ...
                'rngType', M.ip.Results.rngType);
        
        pairwiseMat3D = zeros(2,2, numDecBounds);
        
        if (sum(contains( fieldnames( ip.Results) , 'actualLabels' )))
            [P.AM, ~, P.pairwiseInfo] = ...
            Utils.decValues2PairwiseAcc(pairwiseMat3D, ip.Results.actualLabels, M.mdl.Label, decision_values, pairwiseCell);
        end
        
        P.mdl = M.mdl;
        P.classificationInfo = struct(...
            'PCA', M.classificationInfo.PCA, ...
            'classifier', M.classificationInfo.classifier);
        
        %Permutation Testing
        trainLabels = ip.Results.permTestData.Y;
        if ip.Results.permutations > 0
            
            numClasses = length(unique(trainLabels));
            accMatDist = zeros(numClasses, numClasses, ip.Results.permutations);
            pValMat = NaN(numClasses, numClasses);
            
            classPairs = nchoosek(1:numClasses, 2);

            trainX = M.cvDataObj.trainXall{1};
            trainY = M.cvDataObj.trainYall{1};
            
            for i = 1:ip.Results.permutations

                l = length(trainY);
                pTrainY = trainY(randperm(l), :);
                 % conduct grid search here
                 if (strcmp(ip.Results.optimization, 'nestedCV'))
                    [gamma_opt, C_opt] = Utils.nestedCvGridSearch(trainX, pTrainY, cvDataObj, ip);
                 elseif (strcmp(ip.Results.optimization, 'singleFold'))
                    devX = cvDataObj.devXall{1};
                    devY = cvDataObj.devYall{1};
                    trainDevY = [trainY; devY];
                    pTrainDevY = trainDevY(randperm(length(trainDevY)), :);
                    pTrainY = pTrainDevY(1:length(trainY));
                    pDevY = pTrainDevY(length(trainY)+1:end);
                    [gamma_opt, C_opt] = Utils.trainDevGridSearch(trainX, pTrainY, ...
                        devX, pDevY, ip);
                 end
                [pMdl, scale] = fitModel(trainX, pTrainY, ip, gamma_opt, C_opt);

                if strcmp(upper(M.ip.Results.classifier), 'SVM')
                    [pairwiseAccuracies, pairwiseMat3D, pairwiseCell] = ...
                    Utils.decValues2PairwiseAcc(pairwiseMat3D, ip.Results.actualLabels, ...
                        pP.model.Label, decision_values, pairwiseCell);
                end
                accMatDist(:,:,i) = pairwiseAccuracies;
                
            end
            
            for k = 1:numDecBounds
                % class1 class2
                class1 = classPairs(k, 1);
                class2 = classPairs(k, 2);
                pValMat(class1, class2) = Utils.permTestPVal(P.AM(class1, class2), ...
                        accMatDist(class1, class2, :));
                pValMat(class2, class1)  = pValMat(class1, class2);
            end
            
            P.pValMat = pValMat;
                
        end

    end
    
    P.elapsedTime = toc(predict_time);

    disp('Prediction Finished')
    disp('classifyPredict() Finished!')

end
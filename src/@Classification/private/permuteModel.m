function accArr = permuteModel(funcName, X, Y, cvDataObj, nFolds, nPerms, ...
                                classifier, trainDevTestSplit, ip)
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
    % initialize return variable for different classification functions
    switch funcName
        case {'crossValidateMulti', 'crossValidateMulti_opt', 'trainMulti', 'trainMulti_opt'}
            accArr = NaN(nPerms, 1);
        case {'crossValidatePairs', 'crossValidatePairs_opt', 'trainPairs', 'trainPairs_opt'}
            numClasses = length(unique(Y));
            numDecBounds = nchoosek(numClasses ,2);
            accArr = nan(numClasses, numClasses, nPerms);
    end


    % initialize variables to store correct vs. incorrect
    correctPreds = 0;
    incorrectPreds = 0;
    [rr cc] = size(X);
    RSA = MatClassRSA;
    
    for i = 1:nPerms
        correctPreds = 0;
        incorrectPreds = 0;

        % there is only always only one fold in our case
        for j = 1:nFolds
                        
            disp(['calculating ' num2str((i-1)*nFolds + j) ' of '...
            num2str(nPerms*nFolds) ' permutations']);
            trainX = cvDataObj.trainXall{j};
            trainY = cvDataObj.trainYall{j};
            testX = cvDataObj.testXall{j};
            testY = cvDataObj.testYall{j};
            

            
            % Train model for permutation test
            switch funcName
                case {'crossValidateMulti', 'trainMulti'}
                    % permute training data
                    [r c] = size(trainX);
                    pTrainX = trainX(randperm(r), :);
                    
                    mdl =  fitModel(pTrainX, trainY, ip);
                case {'crossValidateMulti_opt', 'trainMulti_opt'}
                    devX = cvDataObj.trainXall{j};
                    devY = cvDataObj.trainYall{j};
                    
                    % scramble dev data and training data together
                    [r c] = size(trainX);
                    [rr cc] = size(devX);
                    trainDevX = [trainX; devX];
                    pTrainDevX = trainDevX(randperm(r+ rr), :);
                    pTrainX = pTrainDevX(1:r, :);
                    pDevX = pTrainDevX(r+1:r+rr, :);

                    % conduct grid search here
                    [gamma_opt, C_opt] = trainDevGridSearch(pTrainX, trainY, pDevX, devY, ...
                        ip.Results.gammaSpace, ip.Results.cSpace, ip.Results.kernel);
                    mdl =  fitModel(pTrainX, trainY, ip, gamma_opt, C_opt);
                case {'crossValidatePairs', 'trainPairs'}
                     % permute training data
                    [r c] = size(trainX);
                    pTrainX = trainX(randperm(r), :);
                    
                    % precompute index values for class1, class2
                    classPairs = nchoosek(1:numClasses, 2);
                    numPairs = length(classPairs);

                    % Iterate through all combintaions of labels
                    for k = 1:numPairs
                      
                        % class1 class2
                        class1 = classPairs(k, 1);
                        class2 = classPairs(k, 2);

                        % get indicies of class1 and class2 trials
                        trainInd = ismember(trainY, [class1 class2]);

                        % select trials/labels representing current pair of classes
                        trainX_tmp = pTrainX(trainInd, :);
                        trainY_tmp = trainY(trainInd, :);

                        [mdl, scale] = fitModel(trainX_tmp, trainY_tmp, ip, ip.Results.gamma, ip.Results.C);
                        modelsConcat{k} = mdl; 
  
                    end

                case {'crossValidatePairs_opt', 'trainPairs_opt'}
                    
                    devX = cvDataObj.trainXall{j};
                    devY = cvDataObj.trainYall{j};
                    
                    % scramble dev data and training data together
                    [r c] = size(trainX);
                    [rr cc] = size(devX);
                    trainDevX = [trainX; devX];
                    pTrainDevX = trainDevX(randperm(r+ rr), :);
                    pTrainX = pTrainDevX(1:r, :);
                    pDevX = pTrainDevX(r+1:r+rr, :);
                    
                    % precompute index values for class1, class2
                    classPairs = nchoosek(1:numClasses, 2);
                    numPairs = length(classPairs);

                    % Iterate through all combintaions of labels
                    for k = 1:numPairs
                      
                        % class1 class2
                        class1 = classPairs(k, 1);
                        class2 = classPairs(k, 2);

                        % get indicies of class1 and class2 trials
                        trainInd = ismember(trainY, [class1 class2]);
                        devInd = ismember(devY, [class1 class2]);

                        % select trials/labels representing current pair of classes
                        pTrainX_tmp = pTrainX(trainInd, :);
                        trainY_tmp = trainY(trainInd, :);
                        pDevX_tmp = pTrainX(trainInd, :);
                        devY_tmp = trainY(trainInd, :);

                        % conduct grid search here
                        [gamma_opt, C_opt] = trainDevGridSearch(pTrainX, trainY, pDevX, devY, ...
                            ip.Results.gammaSpace, ip.Results.cSpace, ip.Results.kernel);
                        [mdl, scale] = fitModel(pTrainX_tmp, trainY_tmp, ip, gamma_opt, C_opt);
                        modelsConcat{k} = mdl; 
  
                    end

                 
                    %{
                case 'trainMulti'
                    mdl =  fitModel(pTrainX, trainY, ip);
                case 'trainMulti_opt'
                    devX = cvDataObj.trainXall{j};
                    devY = cvDataObj.trainYall{j};
                    % conduct grid search here
                    [gamma_opt, C_opt] = trainDevGridSearch(trainX, trainY, devX, devY, ...
                        ip.Results.gammaSpace, ip.Results.cSpace, ip.Results.kernel);
                    mdl =  fitModel(pTrainX, trainY, ip, gamma_opt, C_opt);

                case 'trainPairs'
                    
                case 'trainPairs_opt'
                    %}
                    
                otherwise
            end

            % Predict labels of test set w/ model
            switch funcName
                case {'crossValidateMulti', 'crossValidateMulti_opt', 'trainMulti', 'trainMulti_opt'}
                    predictedY = modelPredict(testX, mdl, ip);
                    %store accuracy
                    for k = 1:length(predictedY)
                        if predictedY(k) == testY(k)
                            correctPreds = correctPreds + 1;
                        else
                            incorrectPreds = incorrectPreds + 1;
                        end
                    end
                    accArr(i) = correctPreds/(correctPreds + incorrectPreds);

                case {'crossValidatePairs', 'crossValidatePairs_opt', 'trainPairs', 'trainPairs_opt'}
                    
                    % initialize return variables
                    AM = NaN(numClasses, numClasses);
                    
                    % precompute index values for class1, class2
                    classPairs = nchoosek(1:numClasses, 2);
                    numPairs = length(classPairs);

                    for k = 1:numPairs
                      
                        class1 = classPairs(k, 1);
                        class2 = classPairs(k, 2);

                        % select trials/labels representing current pair of classes
                        testInd = ismember(testY, [class1 class2]);
                        testX_tmp = testX(testInd, :);
                        testY_tmp = testY(testInd, :);

                        predY = modelPredict(testX_tmp, modelsConcat{k}, scale);
                        
                        tempStruct = struct();
                        % Get Accuracy and confusion matrix
                        thisCM = confusionmat(testY_tmp, predY);
                        AM(class1, class2) = sum(diag(thisCM))/sum(sum(thisCM));
                        AM(class2, class1) = AM(class1, class2); 

                        pairwiseCell{class1, class2} = tempStruct;
                        pairwiseCell{class2, class1} = tempStruct;
                    end

                    accArr(:,:, i) = AM;
      
                otherwise
                    
            end


        end
    
        
    
end
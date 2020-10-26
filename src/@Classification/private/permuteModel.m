function accArr = permuteModel(funcName, X, Y, cvDataObj, nFolds, nPerms, ...
                                classifier, trainDevTestSplit, ip)
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
    % initialize return variable
    switch funcName
        case {'crossValidateMulti', 'crossValidateMulti_opt', 'trainMulti', 'trainMulti_opt'}
            accArr = NaN(nPerms, 1);
        case {'crossValidatePairs', 'crossValidatePairs_opt', 'trainPairs', 'trainPairs_opt'}
            accArr = cell(nPerms,1);
    end


    % initialize variables to store correct vs. incorrect
    correctPreds = 0;
    incorrectPreds = 0;
    [rr cc] = size(X);
    RSA = MatClassRSA;
    
    for i = 1:nPerms
        correctPreds = 0;
        incorrectPreds = 0;

        for j = 1:nFolds
                        
            disp(['calculating ' num2str((i-1)*nFolds + j) ' of '...
            num2str(nPerms*nFolds) ' fold-permutations']);
            trainX = cvDataObj.trainXall{j};
            trainY = cvDataObj.trainYall{j};
            testX = cvDataObj.testXall{j};
            testY = cvDataObj.testYall{j};
            
            % randomize
            [r c] = size(trainX);
            pTrainX = trainX(randperm(r), :);
            
            % Train model for permutation test
            switch funcName
                case 'crossValidateMulti'
                    mdl =  fitModel(pTrainX, trainY, ip);
                case 'crossValidateMulti_opt'
                    devX = cvDataObj.trainXall{j};
                    devY = cvDataObj.trainYall{j};
                    % conduct grid search here
                    [gamma_opt, C_opt] = trainDevGridSearch(trainX, trainY, devX, devY, ...
                        ip.Results.gammaSpace, ip.Results.cSpace, ip.Results.kernel);
                    mdl =  fitModel(pTrainX, trainY, ip, gamma_opt, C_opt);
                case 'crossValidatePairs'

                    numClasses = length(unique(Y));
                    numDecBounds = nchoosek(numClasses ,2);
                    pairwiseMat3D = zeros(2,2, numDecBounds);
                    % initialize the diagonal cell matrix of structs containing pairwise
                    % classification infomration
                    pairwiseCell = initPairwiseCellMat(numClasses);
                    C = struct();
                    modelsConcat = cell(ip.Results.nFolds, numDecBounds);
    
                    decision_values = NaN(length(Y), numDecBounds);
                    AM = NaN(numClasses, numClasses);

                    j = 0;
                    % Iterate through all combintaions of labels
                    for cat1 = 1:numClasses-1
                        for cat2 = (cat1+1):numClasses
                            j = j+1;
                            disp([num2str(cat1) ' vs ' num2str(cat2)]) 
                            currUse = ismember(Y, [cat1 cat2]);

                            tempX = X(currUse, :);
                            tempY = Y(currUse);
                            % Store the accuracy in the accMatrix
                            [~, tempM] = evalc([' RSA.Classification.trainMulti(tempX, tempY, ' ...
                                ' ''classifier'', ip.Results.classifier, ''PCA'', ip.Results.PCA, '...
                                ' ''kernel'', ip.Results.kernel,'...
                                ' ''gamma'', ip.Results.gamma, ' ...
                                ' ''C'', ip.Results.C, ' ... 
                                ' ''numTrees'', ip.Results.numTrees, ' ...
                                ' ''minLeafSize'', ip.Results.minLeafSize, '...
                                ' ''center'', ip.Results.center, ' ...
                                ' ''scale'', ip.Results.scale, ' ...
                                ' ''randomSeed'', ''default'' ) ' ]);
                            tempM.classifierInfo.numClasses = numClasses;
                            M.classifierInfo{j} =  tempM.classifierInfo;
                            M.mdl{j} = tempM.mdl;
                            M.scale{j} = tempM.scale;
                        end
                    end
                    C.pairwiseInfo = pairwiseCell;
                    C.AM = AM;
                case 'crossValidatePairs_opt'
                    
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
                    
                    P = struct();
%                     numClasses = tempInfo.numClasses;
%                     numDecBounds = length(M.mdl);
                    predY = cell(1, numDecBounds);
                    P.AM = NaN(numClasses, numClasses);
                    Y = testY;    

                    [firstClass, secondClass] = getNChoose2Ind(numClasses);
%                     P.classificationInfo = struct();
                    P.pairwiseInfo = struct();
                    pairwiseCell = initPairwiseCellMat(numClasses);
                    decMatchups = nchoosek(1:numClasses, 2);

%                     classifierInfo = struct(...
%                         'PCA', M.classifierInfo{1}.PCA, ...
%                         'classifier', M.classifierInfo{1}.classifier);
%                     P.classificationInfo = classifierInfo;

                    % Initilize info struct
                    for i = 1:numDecBounds
                        % If PCA was turned on for training, we will select principal
                        % compoenents for prediciton as well
                        class1 = firstClass(i);
                        class2 = secondClass(i);
                        currUse = ismember(Y, [class1 class2]);

                        tempX = X(currUse, :);
                        tempY = testY(currUse);

                        tempInfo = M.classifierInfo{i};
                        if (tempInfo.PCA > 0) 
                            [tempX, ~, ~] = centerAndScaleData(tempX, tempInfo.colMeans, tempInfo.colScales);
                            testData = tempX*tempInfo.PCA_V;
                            testData = testData(:,1:tempInfo.PCA_nPC);
                        else
                            testData = tempX;
                        end

                        predY{i} = modelPredict(testData, M.mdl{i}, M.scale{i});
                        P.classificationInfo.classBoundary{i} = [num2str(firstClass(i)) ' vs. ' num2str(secondClass(i))];

                        tempStruct = struct();
                        % Get Accuracy and confusion matrix
                        thisCM = confusionmat(tempY, predY{i});
                        P.AM(class1, class2) = sum(diag(thisCM))/sum(sum(thisCM));
                        P.AM(class2, class1) = P.AM(class1, class2); 

                        tempStruct.classBoundary = [num2str(class1) ' vs. ' num2str(class2)];
                        tempStruct.accuracy = sum(diag(thisCM))/sum(sum(thisCM));
                        tempStruct.actualY = tempY;
                        tempStruct.predY = predY';
                        tempStruct.CM = thisCM;

                        pairwiseCell{class1, class2} = tempStruct;
                        pairwiseCell{class2, class1} = tempStruct;
                    end
                    
                    P.pairwiseInfo = pairwiseCell;
                    P.modelsConcat = M.mdl;
                    
                    accArr{i} = P;
      
                otherwise
                    
            end


        end
    
        
    
end
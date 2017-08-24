function accArr = permuteLabels(Y, cvPartObj, nfolds, nPerms, classifier, classifyOptions, PCAinFold, PCA)

    % make sure nObs > 100, so we have at least the minimal amount of trials
    if (length(Y)) < 100
        error(['To use binomial CDF to computer P-value, number of ' ...
        'observatons must > 100.'])
    end

    % make sure N > nObs/10, to achieve minimal amount of nfolds viable 
    if nfolds >= length(Y)/10
        error(['To use binomial CDF to computer P-value, the size of each fold ' ...
            'should be greater than the number of observations/10. Make ' ...
            'sure number of nfolds is < 10'])
    end

    % initialize return variable and also intermediary storage variable
    accArr = NaN(nPerms, 1);
    %correct and all prediction # matrix
    corrMat = NaN(nPerms, nfolds);
    allMat = NaN(nPerms, nfolds);
    
    % initialize variables to store correct vs. incorrect
    correctPreds = 0;
    incorrectPreds = 0;
    
    %loop same # of times as cross validation
    for i = 1:nfolds
        %change CV fold and stuff
        trainX = cvPartObj.trainXall{i};
        trainY = cvPartObj.trainYall{i};
        testX = cvPartObj.trainXall{i};
        testY = cvPartObj.trainYall{i};
            
        
        %get correctly predicted labels
        mdl = fitModel(trainX, trainY, classifier, ...
        classifyOptions);
        predictedY = modelPredict(testX, mdl);
    
        for j = 1:nPerms
        
            %permute the test labels
            % (check if randperm is seeded every single time differently)
            % (yes, it is)
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
    
    %technically needs to change3d
    for j=1:nPerms
        accArr(j) = sum(corrMat(j,:))/sum(allMat(j,:));
    end
    

end
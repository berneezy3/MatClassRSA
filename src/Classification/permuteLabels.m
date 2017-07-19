function pVal = permuteLabels(X, Y, partObj, folds, nPerms, classifier, classifyOptions)

    % make sure nObs > 100, so we have at least the minimal amount of trials
    if (length(Y)) < 100
        error(['To use binomial CDF to computer P-value, number of ' ...
        'observatons must > 100.'])
    end

    % make sure N > nObs/10, to achieve minimal amount of folds viable 
    if folds >= length(Y)/10
        error(['To use binomial CDF to computer P-value, the size of each fold ' ...
            'should be greater than the number of observations/10. Make ' ...
            'sure number of folds is < 10'])
    end

    % initialize variables to store correct vs. incorrect
    correctPreds = 0;
    incorrectPreds = 0;
    
    %loop same # of times as cross validation
    for i = 1:folds
        %change CV fold and stuff
        trainX = bsxfun(@times, partObj.training{i}, X);
        trainX = trainX(any(trainX~=0,2),:);
        trainY = bsxfun(@times, partObj.training{i}', Y);
        trainY = trainY(trainY~=0);
        testX = bsxfun(@times, partObj.test{i}, X);
        testX = testX(any(testX~=0, 2),:);
        testY = bsxfun(@times, partObj.test{i}', Y);
        testY = testY(testY ~=0);
        
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
                if predictedY(k) == testY(k)
                    correctPreds = correctPreds + 1;
                else
                    incorrectPreds = incorrectPreds + 1;
                end
            end
        
        end
    end
    
    pVal = correctPreds/(correctPreds + incorrectPreds);

end
function pVal = permuteModel(X, Y, partObj, nFolds, nPerms, PCAinFold, classifier, classifyOptions)

    
    % initialize variables to store correct vs. incorrect
    correctPreds = 0;
    incorrectPreds = 0;
    
    %change CV fold and stuff
    trainX = bsxfun(@times, partObj.training{j}, X);
    trainX = trainX(any(trainX~=0,2),:);
    trainY = bsxfun(@times, partObj.training{j}', Y);
    trainY = trainY(trainY~=0);
    testX = bsxfun(@times, partObj.test{j}, X);
    testX = testX(any(testX~=0, 2),:);
    testY = bsxfun(@times, partObj.test{j}', Y);
    testY = testY(testY ~=0);
    
    %loop same # of times as cross validation
    for i = 1:nPerms

        for j = 1:nFolds
            
            % randomize
            [r c] = size(trainX)
            pTrainX = trainX(randperm(r), :);


            %get correctly predicted labels
            mdl = fitModel(pTrainX, trainY, classifier, ...
            classifyOptions);
            predictedY = modelPredict(testX, mdl);


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
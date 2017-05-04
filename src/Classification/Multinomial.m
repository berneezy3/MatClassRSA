function [predictions, accuracy, testFoldIndx] = Multinomial(X, Y)

    c = cvpartition(Y,'KFold',10);

    err = zeros(c.NumTestSets, 1);

    %if sum should be 5188 (AKA # of examples)
    %disp(sum(bitor(c.training(1), c.test(1))))

    %%
    predictAccuracyArr = zeros(10,1);
    predictions = NaN(size(Y));
    testFoldIndx = NaN(size(Y));
    
    for i = 1:c.NumTestSets
        disp(['in loop ' num2str(i)]);
        
        %train set
        trainInd = c.training(i);
        trainX = trainInd .* X;
        trainX = trainX(any(trainX, 2),:);
        trainY = trainInd .* Y;
        trainY = trainY(any(trainY, 2),:);

        %
        % Logistic Regression
        %
        B = mnrfit(trainX,trainY);
        
        %test set
        testInd = c.test(i);
        testX = testInd .* X;
        testX = testX(any(testX, 2),:);
        testY = testInd .* Y;
        testY = testY(any(testY, 2),:);

        %predictedLabels = predict(mdl,testX);
        predictedLabels = mnrval(B, testX);
        [sortedPredictions predictionIndex] = sort(predictedLabels,2,'descend');
        predictedLabels = predictionIndex(:, 1);
        disp('this is the label matrix');
        disp(predictedLabels);
        disp('here is the size of the predicted matrix');
        disp(size(predictedLabels));
        predictions(c.test(i)==1) = predictedLabels;
        correctPredictionsCount = sum(not(bitxor(predictedLabels, testY)));
        wrongPredictionsCount = size(testY) - correctPredictionsCount;
        predictAccuracyArr(i) = correctPredictionsCount/length(testY);

        %create corresponding predictions and correct vectors      
        testFoldIndx(c.test(i)==1) = i;

    end
    %%
    accuracy = mean(predictAccuracyArr);

end
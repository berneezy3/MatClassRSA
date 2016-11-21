function [predictions, accuracy, testFoldIndx] = Multinomial(X, Y)

    X = getPCs(X, .9);
    X = featureScale(X);

    c = cvpartition(Y,'KFold',10);

    err = zeros(c.NumTestSets, 1);

    %if sum should be 5188 (AKA # of examples)
    disp(sum(bitor(c.training(1), c.test(1))))

    %%
    predictAccuracyArr = zeros(10,1);
    predictions = NaN(size(Y));
    testFoldIndx = NaN(size(Y));
    
    for i = 1:1 %c.NumTestSets
        %train set
        trainInd = c.training(i);
        trainX = trainInd .* X;
        trainX = trainX(any(trainX, 2),:);
        trainY = trainInd .* Y;
        trainY = trainY(any(trainY, 2),:);

        %
        % LDA
        %
        
        %mdl = fitcdiscr(trainX, trainY);
        
        %
        % Elastic Net
        %        
        
        %mdl = glmnet(X, Y, 'multinomial');
        
        %
        % Random Forest
        %

        %mdl = TreeBagger(NumTrees,X,Y);
        
        %
        % Logistic Regression
        %
        
        mdl = mnrfit(X,Y)
        
        %test set
        testInd = c.test(i);
        testX = testInd .* X;
        testX = testX(any(testX, 2),:);
        testY = testInd .* Y;
        testY = testY(any(testY, 2),:);

        %predictedLabels = predict(mdl,testX);
        predictedLabels = glmnetPredict(mdl,testX, [], 'class');
        predictedLabels = predictedLabels(:,end);
        disp('this is the label matrix');
        disp(predictedLabels);
        disp('here is the size of the predicted matrix');
        disp(size(predictedLabels));
        predictions(c.test(i)==1) = predictedLabels;
        correctPredictionsCount = sum(not(bitxor(predictedLabels, testY)));
        wrongPredictionsCount = size(testY) - correctPredictionsCount;
        predictAccuracyArr(i) = correctPredictionsCount/length(testY);

        disp( correctPredictionsCount/length(testY) );

        %create corresponding predictions and correct vectors
        
        testFoldIndx(c.test(i)==1) = i;

    end
    %%
    accuracy = mean(predictAccuracyArr)

end
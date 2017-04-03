function [predictions, accuracy, testIndex] = RandomForest(X, Y, numTrees)

    predictAccuracyArr = zeros(10,1);
    predictedLabelsAll = NaN(size(Y));
    testIndex = NaN;

    %
    % Random Forest
    %

    [r c] = size(X);
    numFeatures = round(sqrt(c)*4);
    
    mdl = TreeBagger(numTrees, X, Y, 'OOBPrediction', 'on');
        
    predictedLabelsAll = oobPredict(mdl);
    predictions = str2num(cell2mat(predictedLabelsAll));
    accuracy = 1 - oobError(mdl, 'mode', 'ensemble')

end
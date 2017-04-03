function [predictions, accuracy] = ElasticNet(X, Y)

    predictAccuracyArr = zeros(10,1);
    predictedLabelsAll = NaN(size(Y));
    testIndex = NaN;
        
        
    %
    % Random Forest
    %

    mdl = glmnet(X, Y, 'multinomial');
    
    [r c] = size(X);
    numFeatures = round(sqrt(c)*2);
    
    %mdl = TreeBagger(numTrees, X, Y, 'OOBPrediction', 'on', 'NumPredictorsToSample', numFeatures);
    
    predictions = glmnetPredict(mdl, X);
    %predictions = str2num(cell2mat(predictedLabelsAll));
    accuracy = 1 - oobError(mdl, 'mode', 'ensemble')

end
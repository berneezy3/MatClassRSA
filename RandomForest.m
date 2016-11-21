function [predictions, accuracy, testFoldIndx] = RandomForest(X, Y, numTrees)

    predictAccuracyArr = zeros(10,1);
    predictedLabelsAll = NaN(size(Y));


        %
        % Random Forest
        %

        mdl = TreeBagger(numTrees, X, Y, 'OOBPrediction', 'on', 'OOBPredictorImportance', 'on', 'PredictorSelection', 'curvature');
        
    [predictedLabelsAll scores] = oobPredict(mdl);
    predictions = str2num(cell2mat(predictedLabelsAll));
    accuracy = 1 - oobError(mdl, 'mode', 'ensemble')

end
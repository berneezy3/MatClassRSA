function [predictions, accuracy] = predictLDA(X, Y, classifyOptionsStruct)

    structLength = length(fieldnames(classifyOptionsStruct));
    params = fieldnames(classifyOptionsStruct);
    values = fields(classifyOptionsStruct);
    discrimType = 'linear';
    expectedDiscrimTypes = {'linear', 'quadratic', 'diagLinear', ... 
        'diagQuadratic', 'pseudoLinear', 'pseudoLinear'}
    for i=1:structLength
        switch params(i)
            case 'DiscrimType' 
%                 switch values(i)
%                     case 'linear'
%                     case 'quadratic'
%                     case 'diagLinear'
%                     case 'diagQuadratic'
%                     case 'pseudoLinear'
%                     case 'pseudoLinear'
%                     otherwise
%                 end
                validatestring(params(i), expectedDiscrimTypes);
                discrimType = params(i);
            otherwise
                warning([params(i) 'not a real input parameter to LDA.'])
        end
    end
    
    mdl = fitcdiscr(X, Y, 'DiscrimType', discrimType);

    %test set
    testInd = c.test(i);
    testX = testInd .* X;
    testX = testX(any(testX, 2),:);
    testY = testInd .* Y;
    testY = testY(any(testY, 2),:);

    predictedLabels = predict(mdl,testX);
    predictedLabels = predictedLabels(:,end);
    predictedLabelsAll(c.test(i)==1) = predictedLabels;
    correctPredictionsCount = sum(not(bitxor(predictedLabels, testY)));
    wrongPredictionsCount = size(testY) - correctPredictionsCount;
    predictAccuracyArr(i) = correctPredictionsCount/length(testY);

    disp( correctPredictionsCount/length(testY) );

    %create corresponding predictions and correct vectors
    %predictedLabelsAll2 = [predictedLabelsAll; predictedLabels];
    correctLabelsAll = [correctLabelsAll; testY];

    testFoldIndx(c.test(i)==1) = i;

end
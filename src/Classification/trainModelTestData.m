 function [CM, accuracy, predY, pVal] = trainModelTestData(X, Y, ip)
 
    % Here we check if the input types are correct, not if the input 
%     addRequired(ip, 'X', @iscell)
%     addRequired(ip, 'Y', @iscell)
    
    if (~testCellInput(X,Y))
        error(['Mismatch detected within input.  Input should be in as follows: '...
            'X - {xtrain, xtest}, Y - {ytrain, ytest}'])
    end
   
    trainData = X{1};
    trainLabels = Y{1};
    testData = X{2};
    testLabels = Y{2};
    
    if (find(isnan(trainData(:))) |...
        find(isnan(trainLabels(:))) |...
        find(isnan(testData(:))) |...
        find(isnan(testLabels(:))) ) 
        error('MatClassRSA classifiers cannot handle missing values (NaNs) in the data at this time.')
    end

    
        
    % Convert to column vector if needed
    if ~iscolumn(trainLabels)
       warning('Transposing input labels vector to column.') 
       trainLabels = trainLabels(:);
    end
    if ~iscolumn(testLabels)
       warning('Transposing input labels vector to column.') 
       testLabels = testLabels(:);
    end

    % PCA
    if (ip.Results.PCA > 0)
        [trainData, V, nPC] = getPCs(trainData, ip.Results.PCA);
        testData = testData*V;
        testData = testData(:,1:nPC); 
    end
    
    % Train Model
    mdl = fitModel(trainData, trainLabels', ip);
    
    % Predict Labels for Test Data
    predY = modelPredict(testData, mdl);
    
    % Get Confusion Matrix
    CM = confusionmat(testLabels, predY);
    
    % Get Accuracy
    accuracy = computeAccuracy(predY, testLabels); 
    
    % Get p-Value
    %pVal = pbinom(Y, ip.Results.nFolds, accuracy);
    pVal = pbinomNoXVal( testLabels, accuracy, length(unique(trainLabels)));
    
 
 end
 
 
 function y = testCellInput(X, Y)
    [rx cx] = size(X);
    [ry cy] = size(Y);
    
    if (rx == 1 && cx == 2 && ry == 1 && cy == 2)
        xtrain = X{1};
        xtest = X{2};
        ytrain = Y{1};
        ytest = Y{2};
        
        if ~isvector(ytrain) || ~isvector(ytest)
            error('The labels matrices must have a dimension 1');
        end
        
        % Convert to column vector if needed
        if ~iscolumn(ytrain)
           warning('Transposing input labels vector to column.') 
           ytrain = ytrain(:);
        end
        if ~iscolumn(ytest)
           warning('Transposing input labels vector to column.') 
           ytest = ytest(:);
        end
        
        [xtrainR xtrainC] = size(xtrain);
        [xtestR xtestC] = size(xtest);
        [ytrainR ytrainC] = size(ytrain);
        [ytestR ytestC] = size(ytest);
        
        if (xtrainC == xtestC && ...
                xtrainR == ytrainR && ... 
                xtestR == ytestR && ...
                ytrainC == 1 && ...
                ytestC == 1)
            y = 1;
        else
            y = 0;
        end 
    else
        error('X and Y must both be cell arrays of size [1 2]');
    end
 end

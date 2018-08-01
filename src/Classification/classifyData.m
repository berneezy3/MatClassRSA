 function [CM, accuracy, predY, pVal, classifierInfo, varargout] = classifyData(X, Y, varargin)
 
 
    % Here we check if the input types are correct, not if the input 
    classifyOrCV = '';
    if iscell(X) == 1 && iscell(Y) == 1
        classifyOrCV = 'classify';
    elseif ismatrix(X) == 1 && ismatrix(Y) == 1
        classifyOrCV = 'CV';
    else
        
   
    [funcOutput mdl] = fitModel(trainX, trainY, ip)
    predictions = modelPredict(testX, mdl);
 
 
 
 end

function [predictions, accuracy, testIndex] = classifyEEGData(X, Y, classifier, varargin)

    classifier = char(classifier);
    
    tic
    addpath('glmnet_matlab/');
    addpath('libsvm-3.21/matlab');

    %%%
    %%% INPUT PARSING :)
    %%%
    
    p = inputParser;
    
    p.addRequired('X');
    p.addRequired('Y');
    
    %defaultClassifier = 'SVM';
    validClassifiers = {'LDA', 'SVM','RandomForest', 'ElasticNet', 'Multinomial'};
    checkClassifier = @(x) any(validatestring(x,validClassifiers));
    p.addRequired('classifier', checkClassifier);
    
    checkVarPC = @(x) any(x<=1 && x>0);
    p.addOptional('varPC', NaN,checkVarPC);
    
    checkNumPC = @(x) any(x>1);
    p.addOptional('numPCs', NaN,checkNumPC);

    p.KeepUnmatched = true;
    parse(p, X, Y, classifier, varargin{:});
    
    inputs = p.Results
    

    if ~isnan(inputs.numPCs) && ~isnan(inputs.varPC)
       warning('variance explained by PCs and number of PCs both set.  varPC will override numPCs');
       X = getPCs(X, inputs.varPC);
    elseif ~isnan(inputs.numPCs)
        X = getPCs(X, inputs.numPCs);
    elseif ~isnan(inputs.varPC)
        X = getPCs(X, inputs.varPC);
    end

    %X = getPCs(X, .9);
    disp(size(X));
    
    predictions = [];
    acc = NaN;
    testInd = [];
    
    switch classifier
        case 'SVM'
            disp('in svm')
            [predictions accuracy testIndex] = SVM(X, Y, 'rbf');
        case 'RandomForest'
            disp('in RF')
            [predictions accuracy testIndex] = RandomForest(X, Y, 350);
        case 'LDA'
            disp('in LDA')
            [predictions accuracy testIndex] = LDA(X, Y);
        case 'ElasticNet'
            disp('in ENET')
            [predictions accuracy testIndex] = ElasticNet(X, Y);
        case 'Multinomial'
            disp('in multinomial')
            [predictions accuracy testIndex] = Multinomial(X, Y);
        otherwise
            error('input valid kernel type')
    end
    
    confusionMatrix = confusionmat(Y, predictions);
    imagesc(confusionMatrix);
    toc
    
end

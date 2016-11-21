function [predictions accuracy testIndex] = classifyEEGData(X, Y, classifier, varargin)

    %%%
    %%% INPUT PARSING :)
    %%%
    
    p = inputParser;
    
    p.addRequired('X');
    p.addRequired('Y');
    
    %defaultClassifier = 'SVM';
    validClassifiers = {'SVM','RandomForest', 'ElasticNet', 'LDA'};
    checkClassifier = @(x) any(validatestring(x,validClassifiers));
    p.addRequired('classifier', checkClassifier);
    
    checkVarPC = @(x) any(x<=1 && X>0);
    p.addOptional('varPC',.9,checkVarPC);
    
    checkNumPC = @(x) any(X>1);
    p.addOptional('numPCs',250,checkNumPC);

    p.KeepUnmatched = true;
    parse(p, X, Y, classifier, varargin{:});
    
    inputs = p.Results
    
    
    if ~isempty(inputs.numPCs) && ~isempty(inputs.varPC)
       X = getPCs(X, inputs.varPC);
    elseif ~isempty(inputs.numPCs)
        X = getPCs(X, inputs.numPC);
    elseif ~isempty(inputs.varPCs)
        X = getPCs(X, inputs.numPC);
    end
    
    
    X = getPCs(X, .9);
    
    predictions = [];
    acc = NaN;
    testInd = [];
    
    switch classifier
        case 'SVM'
            disp('in svm')
            %[predictions accuracy testIndex] = SVM(X, Y, 'rbf');
        case 'RandomForest'
            disp('in RF')
            %[predictions accuracy testIndex] = RandomForest(X, Y, 10);
        case 'LDA'
            disp('in LDA')
            %[predictions accuracy testIndex] = LDA(X, Y);
        case 'ElasticNet'
            disp('in ENET')
            %[predictions accuracy testIndex] = ElasticNet(X, Y);
        case 'Multinomial'
            disp('in multinomial')
            %[predictions accuracy testIndex] = Multinomial(X, Y);
        otherwise
            error('input valid kernel type')
    end
    
    %confusionMatrix = confusionmat(Y, predictions);
    %imagesc(confusionMatrix);
    
end

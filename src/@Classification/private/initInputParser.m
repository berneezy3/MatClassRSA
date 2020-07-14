function y = initInputParser(functionName, ip)

    % Initialize the input parser
    ip = inputParser;
    ip.CaseSensitive = false;
    
    %Specify default values
    defaultPCA = .99;
    defaultPCAinFold = 0;
    defaultNFolds = 10;
    defaultClassifier = 'LDA';
    defaultPValueMethod = '';
    defaultPermutations = 1000;
    defaultTimeUse = [];
    defaultSpaceUse = [];
    defaultFeatureUse = [];
    defaultRandomSeed = 'shuffle';
    defaultKernel = 'linear';
%   defaultDiscrimType = 'linear';
    defaultNumTrees = 64;
    defaultMinLeafSize = 1;
    defaultPairwise = 0;
    defaultCenter = true;
    defaultScale = false;
    defaultCSpace = logspace((-5), 5, 5);
    defaultGammaSpace = logspace((-5), 5, 5);


    %Specify expected values
    expectedPCAinFold = [0,1];
    expectedClassifier = {'SVM', 'LDA', 'RF', 'svm', 'lda', 'rf'};
    expectedPValueMethod = {'permuteFullModel'};
    expectedRandomSeed = {'default', 'shuffle'};
    expectedKernels = {'linear', 'sigmoid', 'rbf', 'polynomial'};
    expectedGamma = {'default'};
    expectedPairwise = {0,1};
    expectedCenter = {0,1};
    expectedScale = {0,1};
    
    
    %Optional positional inputs
    if verLessThan('matlab', '8.2')
        addParamValue(ip, 'randomSeed', defaultRandomSeed,  @(x) isequal('default', x)...
            || isequal('shuffle', x) || (isnumeric(x) && x > 0));
        addParamValue(ip, 'PCA', defaultPCA);
        addParamValue(ip, 'PCAinFold', defaultPCAinFold);
        addParamValue(ip, 'center', defaultCenter, @(x) islogical(x) || (isnumeric(x) && isvetor(x)));
        addParamValue(ip, 'scale', defaultScale, @(x) islogical(x) || (isnumeric(x) && isvetor(x)));
        addParamValue(ip, 'nFolds', defaultNFolds);
        addParamValue(ip, 'classifier', defaultClassifier, ...
             @(x) any(validatestring(x, expectedClassifier)));
        addParamValue(ip, 'timeUse', defaultTimeUse, ...
            @(x) (assert(isvector(x))));
        addParamValue(ip, 'spaceUse', defaultSpaceUse, ...
            @(x) (assert(isvector(x))));
        addParamValue(ip, 'featureUse', defaultFeatureUse, ...
            @(x) (assert(isvector(x))));
        addParamValue(ip, 'kernel', @(x) any(validatestring(x, expectedKernels)));
        addParamValue(ip, 'numTrees', 128);
        addParamValue(ip, 'minLeafSize', 1);
    else
        addParameter(ip, 'randomSeed', defaultRandomSeed,  @(x) isequal('default', x)...
            || isequal('shuffle', x) || (isnumeric(x) && x > 0));
        addParameter(ip, 'PCA', defaultPCA);
        addParameter(ip, 'PCAinFold', defaultPCAinFold);
        addParameter(ip, 'center', defaultCenter);
        addParameter(ip, 'scale', defaultScale);
        addParameter(ip, 'nFolds', defaultNFolds);
        addParameter(ip, 'timeUse', defaultTimeUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'spaceUse', defaultSpaceUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'featureUse', defaultFeatureUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'kernel', 'rbf', @(x) any(validatestring(x, expectedKernels)));
        addParameter(ip, 'numTrees', 128);
        addParameter(ip, 'minLeafSize', 1);
        addParameter(ip, 'pairwise', 0);
    end
    
    switch functionName
       case 'trainMulti'
            addRequired(ip, 'X', @ismatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'SVM', 'LDA', 'RF'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'gamma', 'default', @(x) any([strcmp(x, 'default') isnumeric(x)]));
            addParameter(ip, 'C', 1);
       case 'predict'
       case 'trainPairs'
            addRequired(ip, 'X', @ismatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'SVM', 'LDA', 'RF'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'gamma', 'default', @(x) any([strcmp(x, 'default') isnumeric(x)]));
            addParameter(ip, 'C', 1);
       case 'crossValidateMulti'
            addRequired(ip, 'X', @ismatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'SVM', 'LDA', 'RF'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'gamma', 'default', @(x) any([strcmp(x, 'default') isnumeric(x)]));
            addParameter(ip, 'C', 1);
       case 'crossValidatePairs'
            addRequired(ip, 'X', @ismatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'SVM', 'LDA', 'RF'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'gamma', 'default', @(x) any([strcmp(x, 'default') isnumeric(x)]));
            addParameter(ip, 'C', 1);
       case 'crossValidateMulti_opt'
            addRequired(ip, 'X', @ismatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'SVM', 'svm'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'gammaSpace', defaultGammaSpace);
            addParameter(ip, 'cSpace', defaultCSpace);
       case 'crossValidatePairs_opt'
            addRequired(ip, 'X', @ismatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'SVM', 'LDA', 'RF'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'gammaSpace', defaultGammaSpace);
            addParameter(ip, 'cSpace', defaultCSpace);
       case 'trainPairs_opt'
            addRequired(ip, 'X', @ismatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'SVM', 'LDA', 'RF'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'gammaSpace', defaultGammaSpace);
            addParameter(ip, 'cSpace', defaultCSpace);
       case 'trainMulti_opt'
            addRequired(ip, 'X', @ismatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'SVM'};
            defaultClassifier = 'SVM';
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'gammaSpace', defaultGammaSpace);
            addParameter(ip, 'cSpace', defaultCSpace);
       otherwise
          error(['parseInputs() must be called from one of the following functions:' ...
          'trainMulti.m, predict.m, trainPairs.m,' ...
          'crossValidateMulti.m, crossValidatePairs.m,' ...
          'crossValidateMulti_opt.m, crossValidatePairs_opt.m,' ...
          'trainPairs_opt.m, trainMulti_opt.m']);
    end
    

    y=ip;

    
end
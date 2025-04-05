function y = initInputParser(functionName, ip, X, Y, varargin)
% y = initInputParser(functionName, ip, X, Y, varargin)
% ------------------------------------------------------------
% This function initializes the input parser for various functions. It
% fills in generalized parameters such as rng, PCA speficiations, center
% and scale parameters, data subsetting, and classification parameters. It
% also fills in additional parameters depending on which function it is
% being called from.
%
% INPUTS: 
% - functionName: Name of the function calling this function
% - ip: Already-initialized input parser
% - X: Data matrix
% - Y: Labels vector
%
% OUTPUT:
% - y: Updated input parser

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
    defaultKernel = 'rbf';
%   defaultDiscrimType = 'linear';
    defaultNumTrees = 64;
    defaultMinLeafSize = 1;
    defaultPairwise = 0;
    defaultCenter = true;
    defaultScale = false;
    defaultC = 'default'; % (default value of C is 1)
    defaultG = 'default'; % (default value of G is 1/num_features)
    defaultCSpace = logspace((-5), 5, 5);
    defaultGammaSpace = logspace((-5), 5, 5);
    defaultTrainDevTestSplit = [.9 .1];
    defaultTrainDevSplit = [.9 .1];
    defaultNestedCV = 0;
    defaultOptimization = 'singleFold';

    %Specify expected values
    expectedPCAinFold = {0, 1};
    expectedClassifier = {'SVM', 'LDA', 'RF', 'svm', 'lda', 'rf'};
    expectedPValueMethod = {'permuteFullModel'};
    expectedRandomSeed = {'default', 'shuffle'};
    expectedKernels = {'linear', 'sigmoid', 'rbf', 'polynomial'};
    expectedGamma = {'default'};
    expectedPairwise = {0,1};
    expectedCenter = {'on', 'off'};
    expectedScale = {'on', 'off'};
    onOrOff = {'on', 'off'};
    trueOrFalse = {true, false};
    expectedOptimization = {'singleFold', 'nestedCV'};

    
    validateNFolds = @(x) (isinteger(int8(x)) && x>1 );
    
    
    % Optional positional inputs
    % The following parameters are added to every classification function
    if verLessThan('matlab', '8.2')
        addParamValue(ip, 'rngType', defaultRandomSeed);
        addParamValue(ip, 'PCA', defaultPCA);
        addParamValue(ip, 'PCAinFold', defaultPCAinFold, ...
             @(x) isnumeric(x));
        addParamValue(ip, 'center', defaultCenter, ...
            @(x) validateattributes(x,{'logical'}, {'nonempty'}));
        addParamValue(ip, 'scale', defaultScale,  ...
            @(x) validateattributes(x,{'logical'}, {'nonempty'}));
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
        addParamValue(ip, 'permutations', 0);
    else
        addParameter(ip, 'rngType', defaultRandomSeed);
        addParameter(ip, 'PCA', defaultPCA);
        addParameter(ip, 'PCAinFold', defaultPCAinFold, ...
             @(x) isnumeric(x));
        addParameter(ip, 'center', defaultCenter, ...
             @(x) validateattributes(x,{'logical'}, {'nonempty'}));
        addParameter(ip, 'scale', defaultScale, ...
             @(x) validateattributes(x,{'logical'}, {'nonempty'}));
%         addParameter(ip, 'nFolds', defaultNFolds);
        addParameter(ip, 'timeUse', defaultTimeUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'spaceUse', defaultSpaceUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'featureUse', defaultFeatureUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'kernel', defaultKernel, @(x) any(validatestring(x, expectedKernels)));
        addParameter(ip, 'numTrees', 128);
        addParameter(ip, 'minLeafSize', 1);
        addParameter(ip, 'permutations', 0);
    end
    
    
    % The following parameters are individually added to each
    % classification function
    switch functionName
       case 'crossValidateMulti'
            addRequired(ip, 'X', @Utils.is2Dor3DMatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'LDA', 'RF', 'SVM'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'nFolds', defaultNFolds, validateNFolds);
            addParameter(ip, 'gamma', 'default', @(x) any([strcmp(x, 'default') isnumeric(x)]));
            addParameter(ip, 'C', 1);
       case {'crossValidatePairs', 'crossValidatePairs_fast', 'crossValidatePairs_slow'}
            addRequired(ip, 'X', @Utils.is2Dor3DMatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'LDA', 'RF', 'SVM'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'nFolds', defaultNFolds, validateNFolds);
            addParameter(ip, 'gamma', 'default', @(x) any([strcmp(x, 'default') isnumeric(x)]));
            addParameter(ip, 'C', 1);
       case 'crossValidateMulti_opt'
            addRequired(ip, 'X', @Utils.is2Dor3DMatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'SVM', 'svm'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'nFolds', defaultNFolds, validateNFolds);
            addParameter(ip, 'gammaSpace', defaultGammaSpace);
            addParameter(ip, 'cSpace', defaultCSpace);
            addParameter(ip, 'trainDevSplit', defaultTrainDevSplit) %, ...
                %@(x) abs(x(3) - 1/3) < .0001);
            addParameter(ip, 'optimization', defaultOptimization,...
                @(x) any(validatestring(x, expectedOptimization)));
                %@(x) (floor(x == x) && x > 0));
        case 'crossValidatePairs_opt'
            addRequired(ip, 'X', @Utils.is2Dor3DMatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'SVM'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'nFolds', defaultNFolds, validateNFolds);
            addParameter(ip, 'gammaSpace', defaultGammaSpace);
            addParameter(ip, 'cSpace', defaultCSpace);
            addParameter(ip, 'trainDevSplit', defaultTrainDevSplit);
            addParameter(ip, 'optimization', defaultOptimization,...
                @(x) any(validatestring(x, expectedOptimization)));
       case 'trainMulti'
            addRequired(ip, 'X', @Utils.is2Dor3DMatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'LDA', 'RF', 'SVM'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'gamma', 'default', @(x) any([strcmp(x, 'default') isnumeric(x)]));
            addParameter(ip, 'C', 1);
       case 'trainPairs'
            addRequired(ip, 'X', @Utils.is2Dor3DMatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'LDA', 'RF', 'SVM'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'gamma', 'default', @(x) any([strcmp(x, 'default') isnumeric(x)]));
            addParameter(ip, 'C', 1);
       case 'trainPairs_opt'
            addRequired(ip, 'X', @Utils.is2Dor3DMatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'SVM'};
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'gammaSpace', defaultGammaSpace);
            addParameter(ip, 'cSpace', defaultCSpace);
            addParameter(ip, 'nestedCV', defaultNestedCV);
       case 'trainMulti_opt'
            addRequired(ip, 'X', @Utils.is2Dor3DMatrix);
            addRequired(ip, 'Y', @isvector);
            expectedClassifier = {'SVM'};
            defaultClassifier = 'SVM';
            addParameter(ip, 'nFolds_opt', defaultNFolds, validateNFolds);
            addParameter(ip, 'classifier', defaultClassifier, ...
                @(x) any(validatestring(x, expectedClassifier)));
            addParameter(ip, 'gammaSpace', defaultGammaSpace);
            addParameter(ip, 'cSpace', defaultCSpace);
            addParameter(ip, 'trainDevSplit', defaultTrainDevSplit);
            addParameter(ip, 'optimization', defaultOptimization,...
                @(x) any(validatestring(x, expectedOptimization)));
       otherwise
          error(['parseInputs() must be called from one of the following functions:' ...
          'trainMulti.m, predict.m, trainPairs.m,' ...
          'crossValidateMulti.m, crossValidatePairs.m,' ...
          'crossValidateMulti_opt.m, crossValidatePairs_opt.m,' ...
          'trainPairs_opt.m, trainMulti_opt.m']);
    end

    parse(ip, X, Y, varargin{:});
    y=ip;
end
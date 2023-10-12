function [M, trainData] = trainMulti(obj, X, Y, varargin)
% -------------------------------------------------------------------------
% RSA = MatClassRSA;
% M = RSA.Classification.trainMulti(trainData, testData); 
% P = RSA.Classification.predict(M, X, Y)
% -------------------------------------------------------------------------
% Blair/Bernard - Feb. 22, 2017
%
% Given a data matrix X and labels vector Y, this function trains a
% classification model using the data, then outputs this model into a
% struct.  This struct can be passed into the classification function
% predict() to predict the labels of future trials.  
%
% INPUT ARGS (REQUIRED)
%   X - Data matrix.  Either a 2D (trial-by-feature) matrix or a 3D 
%       (space-by-time-by-trial) matrix. 
%   Y - Vector of trial labels. The length of Y must match the length of
%       the trial dimension of X. 
%
% INPUT ARGS (OPTIONAL NAME-VALUE PAIRS)
%   'timeUse' - If X is a 3D, space-by-time-by-trials matrix, then this
%       option will subset X along the time dimension.  The input
%       argument should be passed in as a vector of indices that indicate the 
%       time dimension indices that the user wants to subset.  This arugument 
%       will not do anything if input matrix X is a 2D, trials-by-feature matrix.
%   'spaceUse' - If X is a 3D, space-by-time-by-trials matrix, then this
%       option will subset X along the space dimension.  The input
%       argument should be passed in as a vector of indices that indicate the 
%       space dimension indices that the user wants to subset.  This arugument 
%       will not do anything if input matrix X is a 2D, trials-by-feature matrix.
%   'featureUse' - If X is a 2D, trials-by-features matrix, then this
%       option will subset X along the features dimension.  The input
%       argument should be passed in as a vector of indices that indicate the 
%       feature dimension indices that the user wants to subset.  This arugument 
%       will not do anything if input matrix X is a 3D,
%       space-by-time-by-trials matrix.
%   'rngType' - Random number generator specification. Here you can set the
%       the rng seed and the rng generator, in the form {'rngSeed','rngGen'}.
%       If rngType is not entered, or is empty, rng will be assigned as 
%       rngSeed: 'shuffle', rngGen: 'twister'. Where 'shuffle' generates a 
%       seed based on the current time.
%       --- Acceptable specifications for rngType ---
%           - Single-argument specification, sets only the rng seed
%               (e.g., 4, 0, 'shuffle'); in these cases, the rng generator  
%               will be set to 'twister'. If a number is entered, this number will 
%               be set as the seed. If 'shuffle' is entered, the seed will be 
%               based on the current time.
%           - Dual-argument specifications as either a 2-element cell 
%               array (e.g., {'shuffle', 'twister'}, {6, 'twister'}) or string array 
%               (e.g., ["shuffle", "philox"]). The first argument sets the
%               The first argument set the rng seed. The second argument
%               sets the generator to the specified rng generator type.
%           - rng struct as previously assigned by rngType = rng.
%   'PCA' - Set principal component analysis on data matrix X.  To retain 
%       components that explain a certain percentage of variance, enter a
%       decimal value [0, 1).  To retain a certain number of principal 
%       components, enter an integer greater or equal to 1. Default value 
%       is .99, which selects principal components that explain 99% of the 
%       variance.  Enter 0 to disable PCA. PCA is computed along the
%       feature dimension -- that is, along the column dimension of the
%       trial-by-feature matrix that is input to the classifier.  If the
%       output struct is passed into predict() to classify other data,
%       then the principal components from this function will be saved and
%       applied to the data passed into predict().
%       --options--
%       - decimal between [0, 1): Use most important features that
%           explain N/100 percent of the variance in input matrix X.
%       - integer greater than or equal to 1: Use N most important
%       - 0: Do not perform PCA.
%   'classifier' - Choose classifier for cross validation.  Supported
%       classifier include support vector machine (SVM), linear discriminant 
%       analysis (LDA) and random forest (RF).  For SVM, the user must 
%       manually specify hyperparameter “C” (linear, rbf kernels) and 
%       “gamma” (rbf kernel). Use the functions with the "_opt" subscript to 
%       optimize SVM hyperparameters.
%        --options--
%       'SVM'
%       'LDA' (default)
%       'RF' 
%   'kernel' - Specification for SVM's decision function.  This input will 
%       not do anything if a classifier other than SVM is selected.
%        --options--
%       'linear' (default)
%       'rbf' 
%   'gamma' - Hyperparamter of the rbf kernel for SVM classification.  If
%       SVM is selected as the classifier, and rbf is selected as the
%       kernel, then gamma must be manually set by the user.
%   'C' - Hyperparameter of both the rbf and linear kernel for SVM
%       classification.  If SVM is selected as the classifier, then C must 
%       be manually set by the user.
%   'numTrees' - Hyperparameter of the random forest classifier.  This
%       chooses the number of decision trees to grow.  Default is 128.  
%   'minLeafSize' - Hyperparameter of the random forest classifier.  Choose 
%       the minimum number of observations per tree leaf.  Default is 1.
%   'permutations' - this chooses the number of permutations to perform for
%       permutation testing. If this value is set to 0, then permutation
%       testing will be turned off.  If it is set to an integer n greater 
%       than 0, then classification will be performed over n permutation 
%       iterations. Default value is 0 (off).
%   'center' - This variable controls data centering, also known as 
%       mean centering.  Setting this to any non-zero value will set the
%       mean along the feature dimension to be 0.  Setting to 0 turns it 
%       off. If PCA is performed, data centering is required; if the user
%       selects a PCA calculation but 'center' is off, the function
%       will issue a warning and turn centering on.
%        --options--
%        false - centering turned off
%        true (default) - centering turned on 
%   'scale' - This variable controls data scaling, also known as data
%       normalization.  Setting this to a non-zero value to scales each 
%       feature to have unit variance prior to PCA.  Setting 
%       it to 0 turns off data scaling.  
%        --options--
%        false (default) - scaling turned off
%        true - scaling turned on 
%
% OUTPUT ARGS 
%   M - Classification output to be passed into predict().  
%       --subfields--
%       M.classifierInfo - additional parameters/info for classification
%       M.mdl - classification model which is used in predict to predict
%           the labels of new data
%       M.classifier - classifier selected for training
%       M.trainData - data used to train classification model
%       M.trainLabels - labels used to train classification model
%       M.functionName - the name of the current function in string format
%       M.permutationMdls - cell array containing all permutation models
%       M.cvDataObj - object containing data and labels after PCA
% This software is licensed under the 3-Clause BSD License (New BSD License), 
% as follows:
% -------------------------------------------------------------------------
% Copyright 2017 Bernard C. Wang, Anthony M. Norcia, and Blair Kaneshiro
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
% this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice, 
% this list of conditions and the following disclaimer in the documentation 
% and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
% contributors may be used to endorse or promote products derived from this 
% software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ?AS IS?
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO : FINISH DOCSTRING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    train_time = tic;

    %initialize output struct C
    M = struct;
    trainData = struct;
    
    % Initialize the input parser
    ip = inputParser;
    ip.CaseSensitive = false;
    display(ip.Results.rngType);
    st = dbstack;
    namestr = st.name;
    ip = initInputParser(namestr, ip, X, Y, varargin{:});
    
    % Parse Inputs
    parse(ip, X, Y, varargin{:});
    
    [r c] = size(X);
    
    display(ip.Results.rngType);
    % check input data 
    checkInputDataShape(X, Y);
    
    % If SVM is selected, then gamma and C parameters must be manually set
    verifySVMParameters(ip);
    
    % this function contains input checking functions
    [X, nSpace, nTime, nTrials] = subsetTrainTestMatrices(X, ...
                                                    ip.Results.spaceUse, ...
                                                    ip.Results.timeUse, ...
                                                    ip.Results.featureUse);
                     
    defaultShuffleData = 1;
    defaultRandomSeed = 'shuffle';
    defaultAverageTrials = -1;
    defaultAverageTrialsHandleRemainder = 'discard';

    % SET RANDOM SEED
    % for data shuffling and permutation testing purposes
    %rng(ip.Results.randomSeed);
    display(ip.Results.rngType);
    setUserSpecifiedRng(ip.Results.rngType);

    % Moving centering and scaling parameters out of ip, in case we need to
    % override the user's centering specification
    ipCenter = ip.Results.center; 
    ipScale = ip.Results.scale;
    if ((~ip.Results.center) && (ip.Results.PCA>0) ) 
        warning(['Data centering must be on if performing PCA. Overriding '...
        'user input and removing the mean from each data feature.']);
        ipCenter = true;
    end
    
    trainData = X;
    
    tdtSplit = processTrainDevTestSplit([1 0 0], X);
    partition = trainDevTestPart(X, 1, tdtSplit); 
    
    % PCA
    if (ip.Results.PCA > 0)
        disp('Conducting Principal Component Analysis...')
        [cvDataObj, V, nPC, colMeans, colScales] = cvData(X,Y, partition, ip, ipCenter, ipScale);
    else 
        disp('Principal Component Analysis turned off')
%         V = NaN;
%         nPC = NaN;
%         colMeans = NaN;
%         colScales = NaN;
        [cvDataObj, V, nPC, colMeans, colScales] = cvData(X,Y, partition, ip, ipCenter, ipScale, 1);
    end
    trainData = cvDataObj.trainXall{1};
    
    % Train Model
    disp('Training Model...')
    
    
    % create classifier info struct
    classifierInfo = struct();
    classifierInfo.PCA = ip.Results.PCA;
    classifierInfo.classifier = ip.Results.classifier;
    classifierInfo.spaceUse = ip.Results.spaceUse;
    classifierInfo.timeUse = ip.Results.timeUse;
    classifierInfo.featureUse = ip.Results.featureUse; %'shuffleData', ip.Results.shuffleData, ...
    classifierInfo.rngType = ip.Results.rngType;
    classifierInfo.PCA_V = V;
    classifierInfo.PCA_nPC = nPC;
    classifierInfo.numClasses = length(unique(Y));
    classifierInfo.colMeans = colMeans;
    classifierInfo.colScales = colScales;
    classifierInfo.ip = ip;
    
    switch classifierInfo.classifier
        case 'SVM'
            classifierInfo.kernel = ip.Results.kernel;
        case 'LDA'
        case 'RF'
            classifierInfo.numTrees = ip.Results.numTrees;
            classifierInfo.minLeafSize =  ip.Results.minLeafSize;
    end
    
    disp(['classifying with ' ip.Results.classifier] )

    [mdl, scale] = fitModel(trainData, Y(:), ip, ip.Results.gamma, ip.Results.C);
    
        
    % set return struct fields
    M.classifierInfo = classifierInfo;
    M.mdl = mdl;
    M.scale = scale;
    M.pairwise = 0;
    M.classifier = ip.Results.classifier;
    M.functionName = namestr;
    M.pairwise = 0;
    M.cvDataObj = cvDataObj;
    M.permutations = ip.Results.permutations;
    M.ip = ip;
    
    trainData = struct();
    trainData.X = cvDataObj.trainXall{1};
    trainData.Y = Y;
    
    M.elapsedTime = toc(train_time);

    disp('Training Finished...')
    disp('Returning Model')

    return;

end
 function [M, permTestData] = trainPairs_opt(X, Y, varargin)
% -------------------------------------------------------------------------
% RSA = MatClassRSA;
% M = RSA.Classification.trainPairs_opt(X, Y, varargin)
% P = RSA.Classification.predict(M, X, Y)
% -------------------------------------------------------------------------
%
% Given a data matrix X and labels vector Y, this function will split the
% data into pairs of classes, optimize the classifer hyperparameters, then 
% output the pairwise classification models in a struct.  This struct can 
% be passed into predict() to predict the labels of testing data w/ each 
% classifier  Optional name-value parameters can be passed in to specify 
% classification related options.  
%
% Currently, the only classifier compitable w/ this function is SVM.  
% Optimization is done via a grid serach over the values specified in the 
% gammaSpace and cSpace input parameters.
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
%   'nFolds' - Number of folds in cross validation.  Must be integer
%       greater than 1 and less than or equal to the number of trials. 
%       Default is 10.
%   'classifier' - Choose classifier for cross validation.  Currently, only
%        support vector machine (SVM) is supported for hyperparameter
%        optimization
%        --options--
%       'SVM' (default)
%       * hyperparameter optimization for other classifiers 
%         to be added in future updates
%   'kernel' - Specification for SVM's decision function.  This input will 
%       not do anything if a classifier other than SVM is selected.
%        --options--
%       'linear' 
%       'rbf' (default)
%   'optimizationFolds': This parameter controls whether optimization is
%       conducted via a full nFolds cross validation on the training data  
%       or optimizing on a single development fold.  Entering a non-zero  
%       value turns on nested cross validation, while entering zero uses a 
%       development fold for CV. 
%       --options--
%       'single' (default)
%       'full'
%   'gammaSpace' - Vector of 'gamma' values to search over during 
%       hyperparameter optimization.  Gamma is a hyperparameter of the rbf 
%       kernel for SVM classification.  Default is 5 logarithmically spaced
%       points between 10^-5 and 10^5
%   'cSpace' - Vector of 'C' values to search over during hyperparameter 
%       optimization.  'C' is a hyperparameter of both the rbf and linear 
%       kernel for SVM classification.  Default is 5 logarithmically spaced
%       points between 10^-5 and 10^5
%   'permutations' - this chooses the number of permutations to perform for
%       permutation testing. If this value is set to 0, then permutation
%       testing will be turned off.  If it is set to an integer n greater 
%       than 0, then classification will be performed over n permutation 
%       iterations. Default value is 0 (off).  
%       --implementation notes--
%       The permutation testing for this function is carried out by the 
%       predict() function, consistent with the steps described in the 
%       crossValidatePairs_opt() function. Please refer to the permutations 
%       section in the crossValidatePairs_opt() function documentation or 
%       the code docstring to learn more.
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
%       feature to have unit variance prior to PCA.  Setting it to 0 turns 
%       off data scaling.  
%        --options--
%        false (default) - scaling turned off
%        true - scaling turned on 
%
% OUTPUT ARGS 
%   M - Classification output to be passed into predict().  
%       --subfields--
%       M.classificationInfo - additional parameters/info for classification
%       M.mdl - classification model which is used in predict() to classify
%           labels of new data
%       M.classifier - classifier selected for training
%       M.functionName - the name of the current function in string format
%       M.cvDataObj - object containing data and labels after PCA
%       M.permutations - please see 'permutations' section in the input
%           arguments
%       M.ip - input parser object for this function
%       M.elapsedTime - time elapsed for train current model in seconds.
%           Could be used to gauge permutation testing duration.
%       M.maxAccuracy - Highest classification accuracy obtained 
%           during optimization (using gammaOpt and C_opt)
%       M.gammaOpt - optimal value for SVM hyperparameter gamma
%       M.C_opt - optimal value for SVM hyperparameter C
%       M.scale - please see section for 'scale' input argument.  
%  permTestData - Struct containing training data for use in permutation
%       testing, which is to be conducted in predict()
%
% MatClassRSA dependencies (all +Utils): initInputParser(),
%   convert2double(), subsetTrainTestMatrices(), initPairwiseCellMat()

% This software is released under the MIT License, as follows:
%
% Copyright (c) 2025 Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, 
% Feng Ruan, Anthony M. Norcia, and Blair Kaneshiro.
% 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to 
% permit persons to whom the Software is furnished to do so, subject to 
% the following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    %%%%% PARSE INPUT DATA %%%%%
    st = dbstack;
    namestr = st.name;
    ip = inputParser;
    ip = Utils.initInputParser(namestr, ip, X, Y, varargin{:});
    [r c] = size(X);
    parse(ip, X, Y, varargin{:});

            
    % Initilize info struct
    classifierInfo = struct('PCA', ip.Results.PCA, ...
                        'PCAinFold', ip.Results.PCAinFold, ...
                        'nFolds', 1, ...
                        'classifier', ip.Results.classifier);
    
   % check if data is double, convert to double if it isn't
   [X,Y] = Utils.convert2double(X,Y);
    
   %%%%% SUBSET DATA MATRICES %%%%%
   [X, nSpace, nTime, nTrials] = Utils.subsetTrainTestMatrices(X, ...
                                                ip.Results.spaceUse, ...
                                                ip.Results.timeUse, ...
                                                ip.Results.featureUse);

    % let r and c store size of 2D matrix
    [r c] = size(X);
    [r1 c1] = size(Y);
    
    if (r1 < c1)
        Y = Y';
    end
    
    %%%%% Whatever we started with, we now have a 2D trials-by-feature matrix
    % moving forward.
    
    
    % Split data into pairs representing each combination of labels  
    numClasses = length(unique(Y));
    numDecBounds = nchoosek(numClasses ,2);
    pairwiseMat3D = zeros(2,2, numDecBounds);
    % initialize the diagonal cell matrix of structs containing pairwise
    % classification infomration
    pairwiseCell = Utils.initPairwiseCellMat(numClasses);
    
    numClasses = length(unique(Y));
    numDecBounds = nchoosek(numClasses, 2);
    M = struct();

    % SVM w/ PCA
    if (strcmp( upper(ip.Results.classifier), 'SVM') && (ip.Results.PCA > 0))
    
        M.pairwise = 1;
        M.classifier = ip.Results.classifier;

        % since we are returning multiple classification, we initialize the 
        % return format to be cell array to hold multiple structs
        M.mdl = {};
        M.classifierInfo = {};
        M.scale = {};
    
        j = 0;
        for cat1 = 1:numClasses-1
            for cat2 = (cat1+1):numClasses
                j = j+1;
                disp([num2str(cat1) ' vs ' num2str(cat2)]) 
                currUse = ismember(Y, [cat1 cat2]);

                tempX = X(currUse, :);
                tempY = Y(currUse);
                tempStruct = struct();
                % Store the accuracy in the accMatrix
                [~, tempM] = evalc([' Classification.trainMulti_opt(tempX, tempY, ' ...
                    ' ''classifier'', ip.Results.classifier, ''PCA'', ip.Results.PCA, '...
                    ' ''kernel'', ip.Results.kernel,'...
                    ' ''gammaSpace'', ip.Results.gammaSpace, ' ...
                    ' ''cSpace'', ip.Results.cSpace, ' ... 
                    ' ''numTrees'', ip.Results.numTrees, ' ...
                    ' ''minLeafSize'', ip.Results.minLeafSize, '...
                    ' ''center'', ip.Results.center, ' ...
                    ' ''scale'', ip.Results.scale, ' ...
                    ' ''rngType'', ''default'' ) ' ]);
                tempM.classifierInfo.numClasses = numClasses;
                M.classifierInfo{j} =  tempM.classifierInfo;
                M.mdl{j} = tempM.mdl;
                M.scale{j} = tempM.scale;
            end
        end
    % END PAIRWISE LDA/RF
    % START SVM (skipping the pairwise split to decrease runtime)
    elseif  strcmp( upper(ip.Results.classifier), 'SVM') && (ip.Results.PCA <= 0)
        
        
%         [mdl, scale] = fitModel(X, Y, ip, ip.Results.gamma, ip.Results.C);

        [~, tempM] = evalc([' Classification.trainMulti_opt(X, Y, ' ...
            ' ''classifier'', ip.Results.classifier, ''PCA'', ip.Results.PCA, '...
            ' ''kernel'', ip.Results.kernel,'...
            ' ''gammaSpace'', ip.Results.gammaSpace, ' ...
            ' ''cSpace'', ip.Results.cSpace, ' ... 
            ' ''numTrees'', ip.Results.numTrees, ' ...
            ' ''minLeafSize'', ip.Results.minLeafSize, '...
            ' ''center'', ip.Results.center, ' ...
            ' ''scale'', ip.Results.scale, ' ...
            ' ''rngType'', ''default'' ) ' ]);
        
        
        M = tempM;
        %M.pairwise = 1;
        %M.classifier = ip.Results.classifier;
        
    end
    
    %permTestData = cvDataObj;
    
    disp('trainPairs_opt() Finished!')
    
 end

 
 
 function [M, permTestData] = trainPairs(X, Y, varargin)
% -------------------------------------------------------------------------
% M = Classification.trainPairs(X, Y, varargin)
% P = Classification.predict(M, X, Y)
% -------------------------------------------------------------------------
%
% The main function for cross-validating data.  
%
% INPUT ARGS (REQUIRED)
%   X - training data
%   Y - labels
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
%       'linear'
%       'rbf' (default)
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
%       iterations. Default value is 0 (off).  Note that only the training
%       of the permutation models will be conducted in this function.  The
%       actual permutation testing will take place if the output model from
%       this function is passed into predict().
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
%
% MatClassRSA dependencies (all +Utils): initInputParser(),
%   convert2double(), verifySVMParameters(), subsetTrainTestMatrices(),
%   initPairwiseCellMat()

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

    trainPairs_time = tic;
    st = dbstack;
    namestr = st.name;
    ip = inputParser;
    %Required inputs
    ip = Utils.initInputParser(namestr, ip, X, Y, varargin{:});
    parse(ip, X, Y, varargin{:});
            
    % Initilize info struct
    classifierInfo = struct(...
                        'PCA', ip.Results.PCA, ...
                        'PCAinFold', ip.Results.PCAinFold, ...
                        'classifier', ip.Results.classifier);

    % throw error on missing data
    if (find(isnan(X(:))))
        error('MatClassRSA classifiers cannot handle missing values (NaNs) in the data at this time.')
    end

    
   % check if data is double, convert to double if it isn't
   [X, Y] = Utils.convert2double(X, Y);
   
   % If SVM is selected, then gamma and C parameters must be manually set
   Utils.verifySVMParameters(ip);

   
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
    
    % Split data into pairs representing each combination of labels  
    allClasses = unique(Y);
    numClasses = length(allClasses);
    numDecBounds = nchoosek(numClasses ,2);
    classPairs = nchoosek(1:numClasses, 2);
    pairwiseMat3D = zeros(2,2, numDecBounds);
    
    classPairs = allClasses(classPairs(:,:));
    
    % initialize the diagonal cell matrix of structs containing pairwise
    % classification infomration
    pairwiseCell = Utils.initPairwiseCellMat(numClasses);
    
    numClasses = length(unique(Y));
    numDecBounds = nchoosek(numClasses, 2);
    M = struct();

    % PAIRWISE LDA/RF
    if (strcmp(upper(ip.Results.classifier), 'LDA') || ...
        strcmp(upper(ip.Results.classifier), 'RF') || ...
        strcmp(upper(ip.Results.classifier), 'SVM') && ip.Results.PCA >0)


        M.pairwise = 1;
        M.classifier = ip.Results.classifier;

        % since we are returning multiple classification, we initialize the 
        % return format to be cell array to hold multiple structs
        M.mdl = {};
        M.classifierInfo = {};
        M.classificationInfo = {};
        M.scale = {};
        M.trainData = X;
        M.trainLabels = Y;
        M.functionName = namestr;
        M.pairwise = 1;
        M.ip = ip;
        
        permTestData = cell(1, numDecBounds);
        cvDataObj = cell(1, numDecBounds);
        
        disp('training model for classes: ')

        % Iterate through all combintaions of labels
        for k = 1:numDecBounds
            
            % class1 class2
            class1 = classPairs(k, 1);
            class2 = classPairs(k, 2);

            disp([num2str(class1) ' vs ' num2str(class2)]); 
            currUse = ismember(Y, [class1 class2]);
            tempX = X(currUse, :);
            tempY = Y(currUse);
           

            % Store the accuracy in the accMatrix
            [~, tempM] = evalc([' Classification.trainMulti(tempX, tempY, ' ...
                ' ''classifier'', ip.Results.classifier, ''PCA'', ip.Results.PCA, '...
                ' ''kernel'', ip.Results.kernel,'...
                ' ''gamma'', ip.Results.gamma, ' ...
                ' ''C'', ip.Results.C, ' ... 
                ' ''numTrees'', ip.Results.numTrees, ' ...
                ' ''minLeafSize'', ip.Results.minLeafSize, '...
                ' ''center'', ip.Results.center, ' ...
                ' ''scale'', ip.Results.scale, ' ...
                ' ''rngType'', ''default'' ) ' ]);
            tempM.classifierInfo.numClasses = numClasses;
            M.cvDataObj = cvDataObj;
            M.classifierInfo{k} =  tempM.classifierInfo;
            M.classificationInfo{k} = tempM.classificationInfo;
            M.mdl{k} = tempM.mdl;
            M.scale{k} = tempM.scale;
            permTestData{k} = tempM.cvDataObj;
        end

    end

    disp('trainPairs() finished');
              
    M.elapsedTime = toc(trainPairs_time);

    
 end

 
 
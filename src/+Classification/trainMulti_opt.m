function [M, permTestData] = trainMulti_opt(X, Y, varargin)
% -------------------------------------------------------------------------
% [M, permTestData] = Classification.trainMulti_opt(trainData, testData); 
% P = Classification.predict(M, X, Y)
% -------------------------------------------------------------------------
% Blair/Bernard - Feb. 22, 2017
%
% Given a data matrix X and labels vector Y, this function will split the
% data into pairs of classes, optimize the classifer hyperparameters, then 
% conduct cross validation.  Then, an output struct will be passed out
% containing the classification accuracies, confusion matrices, ano other 
% info for each pair of labels.  Optional name-value parameters can be 
% passed in to specify classification related options.  
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
%   'nFolds_opt' - Number of folds in cross validation.  Must be integer
%       greater than 2 and less than or equal to the number of trials. 
%       Default is 10.
%   'classifier' - Choose classifier for cross validation.  Currently, only
%        support vector machine (SVM) is supported for hyperparameter
%        optimization.
%        --options--
%       'SVM' (default)
%       * hyperparameter optimization for other classifiers 
%         to be added in future updates
%   'kernel' - Specification for SVM's decision function.  This input will 
%       not do anything if a classifier other than SVM is selected.
%        --options--
%       'linear' 
%       'rbf' (default)
%   'optimization': This parameter controls whether optimization is
%       conducted using a full nFolds cross validation on the training data  
%       or using a single development fold.  
%       --options--
%       'singleFold' (default)
%       'nestedCV'
%   'trainDevSplit': This parameter is a 2 element vector which controls 
%       how each each fold further split into a training and development 
%       data.  For each fold, a (1/nFolds) fraction of the data becomes the 
%       test data, and a (1 - 1/nFolds) fraction of the data is further 
%       split into training and development data.  The elements must be 
%       decimals which sum to 1.  
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
%       feature to have unit variance prior to PCA.  Setting it to 0 turns 
%       off data scaling.  
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

     % initialize parallel worker pool
    try
        matlabpool;
        closePool=1;
    catch
        try 
            parpool;
            closePool=0;
        catch
            % do nothing if no parpool functions exist
        end
    end

    if(~Utils.is2Dor3DMatrix(X))
        % check that X and Y have same number of trials
        assert(size(X,1) == length(Y), "X and Y vectors must have same number of trials");
    elseif(Utils.is2Dor3DMatrix(X))
        % check that X and Y have same number of trials
        assert(size(X,3) == length(Y), "X and Y vectors must have same number of trials");
    end
    
    % Initialize the input parser
    st = dbstack;
    namestr = st.name;
    ip = inputParser;
    ip = Utils.initInputParser(namestr, ip, X, Y, varargin{:});
    disp(ip.Results.gammaSpace);
    
    %Required inputs
    [r c] = size(X);
    
    %Optional name-value pairs
    %NOTE: Should use addParameter for R2013b and later.
    if (find(isnan(X(:))))
        error('MatClassRSA classifiers cannot handle missing values (NaNs) in the data at this time.')
    end


    % Parse
    parse(ip, X, Y, varargin{:});
    
   % check if data is double, convert to double if it isn't
   if ~isa(X, 'double')
       warning('X data matrix not in double format.  Converting X values to double.')
       disp('Converting X matrix to double')
       X = double(X); 
   end
   if ~isa(Y, 'double')
       warning('Y label vector not in double format.  Converting Y labels to double.')
       Y = double(Y);
   end
   
   % subset based on spaceUse, timeUse, featureUse
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
    
    
    % SET RANDOM SEED
    % for Random forest purposes

    Utils.setUserSpecifiedRng(ip.Results.rngType);

    % PCA 
    % Split Data into fold (w/ or w/o PCA)
    if (ip.Results.PCA>0)
        disp('Conducting Principal Component Analysis');
    else
        disp('Skipping Principal Component Analysis');
    end
    % Moving centering and scaling parameters out of ip, in case we need to
    % override the user's centering specification
    ipCenter = ip.Results.center; 
    ipScale = ip.Results.scale;
    
    if ((~ip.Results.center) && (ip.Results.PCA>0) ) 
        warning(['Data centering must be on if performing PCA. Overriding '...
        'user input and removing the mean from each data feature.']);
        ipCenter = true;
    end
    if ( strcmp(ip.Results.optimization, 'nestedCV'))
        trainDevTestSplit = [1-1/ip.Results.nFolds_opt 0 1/ip.Results.nFolds_opt];
    elseif (strcmp(ip.Results.optimization, 'singleFold'))
        trainDevTestSplit = [1-1/ip.Results.nFolds_opt 0 1/ip.Results.nFolds_opt];
    end
    
    partition = Utils.trainDevTestPart(X, ip.Results.nFolds_opt, trainDevTestSplit);
    [cvDataObj,V,nPC, colMeans, colScales] = Utils.cvData(X,Y, partition, ip, ipCenter, ipScale);
    
    % restore rng to original
    Utils.setUserSpecifiedRng(ip.Results.rngType);
    
    % CROSS VALIDATION
    disp('Cross Validating')
    
    % Just partition, as shuffling (or not) was handled in previous step
    if ip.Results.nFolds_opt == 1
        % Special case of fitting model with no test set (argh)
        error('nFolds must be a integer value greater than 1');
    end
    

    % if nFolds < 0 | ceil(nFolds) ~= floor(nFolds) | nFolds > nTrials
    %   error, nFolds must be an integer between 2 and nTrials to perform CV
    assert(ip.Results.nFolds_opt > 0 & ...
        ceil(ip.Results.nFolds_opt) == floor(ip.Results.nFolds_opt) & ...
        ip.Results.nFolds_opt <= nTrials, ...
        'nFolds must be an integer between 1 and nTrials to perform CV' );
        
        predictionsConcat = [];
        labelsConcat = [];
        modelsConcat = {1, ip.Results.nFolds_opt};
       
    numClasses = length(unique(Y));
    numDecBounds = nchoosek(numClasses ,2);
  
    
    % Single optimization fold vs. full optimization folds
    % Train/Dev/Test Split
    
    disp('Conducting CV w/ train/dev/test split');
    numClasses = length(unique(Y));
    CM_tmp = zeros(numClasses, numClasses, ip.Results.nFolds_opt);
    C.gamma_opt = zeros(1, ip.Results.nFolds_opt);
    C.C_opt = zeros(1, ip.Results.nFolds_opt);
    
    for i = 1:ip.Results.nFolds_opt

        disp(['Processing fold ' num2str(i) ' of ' num2str(ip.Results.nFolds_opt) '...'])

        trainX = cvDataObj.trainXall{i};
        trainY = cvDataObj.trainYall{i};
        testX = cvDataObj.testXall{i};
        testY = cvDataObj.testYall{i};

        % conduct grid search here
        if ( ~strcmp(ip.Results.classifier, 'LDA'))
            if ( strcmp(ip.Results.optimization, 'singleFold') || ...
                ip.Results.nFolds_opt == 2 )
                devX = cvDataObj.devXall{i};
                devY= cvDataObj.devYall{i};
                [gamma_opt, C_opt] = Utils.trainDevGridSearch(trainX, trainY, ...
                    devX, devY, ip);
            elseif ( strcmp(ip.Results.optimization, 'nestedCV'))
                [gamma_opt, C_opt] = Utils.nestedCvGridSearch(trainX, trainY, ip, cvDataObj);
            end
            
            C.gamma_opt(i) = gamma_opt;
            C.C_opt(i) = C_opt;
            
            mdl = Classification.trainMulti(trainX, trainY, 'classifier', ip.Results.classifier, ...
                'kernel', ip.Results.kernel, 'gamma', gamma_opt, 'C', C_opt, 'PCA', 0);
        else
            mdl = Classification.trainMulti(trainX, trainY, 'classifier', ip.Results.classifier, ...
                'PCA', 0);
        end 
    end
    
    % if permutation testing is turned on
    numTrials = length(trainY);
    permutationMdls = cell(1, ip.Results.permutations);
    
    for i = 1:ip.Results.permutations
        % Train model
        if (strcmp(ip.Results.optimization, 'singleFold'))
            [ptrainX, pDevData, pTrainLabels, pDevLabels] ...
                = permuteTrainDevData(trainX, devX, trainY, devY);
            [pGamma_opt, pC_opt] = Utils.trainDevGridSearch(ptrainX, pTrainLabels, ...
                pDevData, pDevLabels, ip);
            [pMdl, ~] = Utils.fitModel(X, Y, ip, pGamma_opt, pC_opt);
        else
        % nested CV optimization
            pTrainLabels = trainY(randperm(numTrials), :);
            [pGamma_opt, pC_opt] = Utils.nestedCvGridSearch(trainX, pTrainLabels, ip);
            [pMdl, ~] = Utils.fitModel(trainX, pTrainLabels, ip, gamma_opt, C_opt);
        end
        permutationMdls{i} = pMdl;
        
    end
    
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
           
            classifierInfo.gamma = ip.Results.gammaSpace;
            classifierInfo.C = ip.Results.cSpace;
        case 'LDA'
        case 'RF'
            classifierInfo.numTrees = ip.Results.numTrees;
            classifierInfo.minLeafSize =  ip.Results.minLeafSize;
    end
    
    M.classificationInfo = classifierInfo;
    M.mdl = mdl;
    M.classifier = ip.Results.classifier;
    M.trainData = trainX;
    M.trainLabels = trainY;
    M.functionName = namestr;
    if (exist('cvDataObj'))
        M.cvDataObj = cvDataObj;
    end
    M.gamma_opt = gamma_opt;
    M.C_opt = C_opt;
    M.pairwise = 0;
    M.scale = ip.Results.scale;
    M.permutations = ip.Results.permutations;
    M.permutationMdls = permutationMdls;
    M.ip = ip;
    

    permTestData = struct();
    permTestData.X = trainX;
    permTestData.Y = trainY;
    
    if (~strcmp(ip.Results.optimization, 'nestedCV'))
        permTestData.devData = devX;
        permTestData.devLabels= devY;
    end

    M.elapsedTime = toc(train_time);
    
    
    disp('Training Finished...')
    disp('Returning Model')
    return;

end
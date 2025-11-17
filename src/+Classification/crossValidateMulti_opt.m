 function C = crossValidateMulti_opt(X, Y, varargin)
% -------------------------------------------------------------------------
% C = Classification.crossValidateMulti_opt(X, Y, varargin)
% -------------------------------------------------------------------------
%
% Given a data matrix X and labels vector Y, this function will first 
% conduct hyperparameter optimization, then conduct multiclass cross 
% validation with an optimized classifier, and finally output a struct 
% containing the classification accuracy, confusion matrix, and other 
% related information.  Other optional name-value parameters can be passed in to specify classification related options. 
%
% Currently, the only classifier compatible w/ this function is SVM.  
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
%   'timeUse' - If X is a 3D, space-by-time-by-trial matrix, then this
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
%       trial-by-feature matrix that is input to the classifier.
%       --options--
%       - decimal between [0, 1): Use most important features that
%           explain N/100 percent of the variance in input matrix X.
%       - integer greater than or equal to 1: Use N most important
%       - 0: Do not perform PCA.
%   'PCAinFold' - This controls whether or not PCA is conducted in each
%       fold duration cross validation, or if PCA is conducted once on the 
%       entire dataset prior to partitioning data for cross validation.
%       --options--
%       true (default): Conduct PCA within each fold.
%       false: One PCA for entire training data matrix X.
%   'nFolds' - Number of folds in cross validation.  Must be integer
%       greater than 2 and less than or equal to the number of trials. 
%       Default is 10.  This parameter is only used if the 'nestedCV'
%       option is set for 'optimization' parameter.   
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
%       how each fold further split into a training and development 
%       data.  For each fold, a (1/nFolds) fraction of the data becomes the 
%       test data, and a (1 - 1/nFolds) fraction of the data is further 
%       split into training and development data.  The elements must be 
%       decimals which sum to 1. What is the default? Is it also (1/nFolds) and (1-1/nFolds)? 
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
%   For more info on SVM hyperparameters, see Hsu, Chang and Lin's 2003
%   paper, "A Practical Guide to Support Vector Classification"
%   For more info on hyperparamters for random forest, see Matlab
%   documentaion for the treeBagger() class: 
%       https://www.mathworks.com/help/stats/treebagger.html
%
%
% OUTPUT ARGS 
%   C - output object containing all cross validation related
%   information, including classification accuracy, confusion matrix,  
%   prediction results etc.  
%   --subfields--
%   CM - Confusion matrix that summarizes the performance of the
%       classification, in which rows represent actual labels and columns
%       represent predicted labels.  Element i,j represents the number of 
%       observations belonging to clC_tt_multiass i that the classifier labeled as
%       belonging to class j.
%   C - SVM hyperparameter optimized using grid search
%   gamma - SVM hyperparameter optimized using grid search
%   accuracy - classification accuracy
%   predY - vector of predicted labels. Ordering of vector elements
%       corresponds to the order of elements in input labels vector Y.
%   modelsConcat - Struct containing the nFold models used during cross
%       validation.
%   elapsedTime - runtime in seconds
%   pVal - the p-value calculated using the permutation testing results.
%       This is set to NaN if permutation testing is turned off. 
%   permAccs - Permutation testing accuracies.  This field will be NaN if 
%       permuatation testing is not specfied.  
%   classificationInfo - This struct contains the specifications used
%       during classification, including 'PCA', 'PCAinFold', 'nFolds', 
%       'classifier' and 'dataPartitionObj'
%   dataPartitionObj - This struct contains the train/test data partitions 
%       for cross validation (and a dev data partition if hyperparameter 
%       optimization is specified).
%
% MatClassRSA dependencies (all +Utils): initInputParser(), 
%   subsetTrainTestMatrices(), setUserSpecifiedRng(), trainDevTestPart(),
%   cvData(), trainDevGridSearch(), nestedCvGridSearch(), computeAccuracy()

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

    cvMultiOpt_time = tic;
    
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
    
    % Initialize the input parser
    st = dbstack;
    namestr = st.name;
    ip = inputParser;
    ip = Utils.initInputParser(namestr, ip, X, Y, varargin{:});
    
    disp(ip.Results.trainDevSplit);
   
    
    %Required inputs
    [r c] = size(X);
    
    %Optional name-value pairs
    %NOTE: Should use addParameter for R2013b and later.
    if (find(isnan(X(:))))
        error('MatClassRSA classifiers cannot handle missing values (NaNs) in the data at this time.')
    end


    % Parse
    parse(ip, X, Y, varargin{:});
 
            
    % Initilize info struct
    classificationInfo = struct(...
                        'PCA', ip.Results.PCA, ...
                        'PCAinFold', ip.Results.PCAinFold, ...
                        'nFolds', ip.Results.nFolds, ...
                        'classifier', ip.Results.classifier);
    
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

    
    
    partition = Utils.trainDevTestPart(X, ip.Results.nFolds, ip.Results.trainDevSplit);
    [cvDataObj,V,nPCs] = Utils.cvData(X,Y, partition, ip, ipCenter, ipScale);
    
    % restore rng to original
    rng(ip.Results.rngType);
    
    % CROSS VALIDATION
    disp('Cross Validating')
    
    % Just partition, as shuffling (or not) was handled in previous step
    if ip.Results.nFolds == 1
        % Special case of fitting model with no test set (argh)
        error('nFolds must be a integer value greater than 1');
    end
    

    % if nFolds < 0 | ceil(nFolds) ~= floor(nFolds) | nFolds > nTrials
    %   error, nFolds must be an integer between 2 and nTrials to perform CV
    assert(ip.Results.nFolds > 0 & ...
        ceil(ip.Results.nFolds) == floor(ip.Results.nFolds) & ...
        ip.Results.nFolds <= nTrials, ...
        'nFolds must be an integer between 1 and nTrials to perform CV' );
        
        predictionsConcat = [];
        labelsConcat = [];
        modelsConcat = {1, ip.Results.nFolds};
       
    numClasses = length(unique(Y));
    numDecBounds = nchoosek(numClasses ,2);

    CM = NaN;
    
    % Single optimization fold vs. full optimization folds
    % Train/Dev/Test Split
    
    disp('Conducting CV w/ train/dev/test split');
    numClasses = length(unique(Y));
    CM_tmp = zeros(numClasses, numClasses, ip.Results.nFolds);
    C.gamma_opt = zeros(1, ip.Results.nFolds);
    C.C_opt = zeros(1, ip.Results.nFolds);
    
    for i = 1:ip.Results.nFolds

        disp(['Processing fold ' num2str(i) ' of ' num2str(ip.Results.nFolds) '...'])

        trainX = cvDataObj.trainXall{i};
        trainY = cvDataObj.trainYall{i};
        testX = cvDataObj.testXall{i};
        testY = cvDataObj.testYall{i};

        % conduct grid search here
        if ( ~strcmp(ip.Results.classifier, 'LDA'))
            if ( strcmp(ip.Results.optimization, 'singleFold') || ...
                ip.Results.nFolds == 2 )
                devX = cvDataObj.devXall{i};
                devY= cvDataObj.devYall{i};
                
                % check that there is a dev partition
                assert(~isempty(devX), 'devX must not be empty.');
                assert(~isempty(devY), 'devY must not be empty.');
                
                [gamma_opt, C_opt] = Utils.trainDevGridSearch(trainX, trainY, ...
                    devX, devY, ip);
            elseif ( strcmp(ip.Results.optimization, 'nestedCV'))
                [gamma_opt, C_opt] = Utils.nestedCvGridSearch(trainX, trainY, ip, cvDataObj);
            end
            
            C.gamma_opt(i) = gamma_opt;
            C.C_opt(i) = C_opt;
            
            M = Classification.trainMulti(trainX, trainY, 'classifier', ip.Results.classifier, ...
                'gamma', gamma_opt, 'C', C_opt, 'PCA', 0);
        else
            M = Classification.trainMulti(trainX, trainY, 'classifier', ip.Results.classifier,  ...
                'PCA', 0);
        end
        
        P = Classification.predict(M, testX, 'actualLabels',testY);

        labelsConcat = [labelsConcat testY'];
        predictionsConcat = [predictionsConcat P.predY];
        modelsConcat{i} = M.mdl;
        

    end

    C.CM = confusionmat(labelsConcat, predictionsConcat);
    
    %PERMUTATION TEST (assigning)
    tic    
    if (ip.Results.permutations > 0)
        
        % create variable to store permutation testing accuracies
        accArr = NaN(ip.Results.permutations, 1);
        permutationTestInfo = struct();
        
        % store hyperparameter distributions
        gammaDist = zeros(1, ip.Results.permutations);
        cDist = zeros(1, ip.Results.permutations);
        
        if ( strcmp(ip.Results.optimization, 'singleFold') || ...
             ip.Results.nFolds == 2)
            permTestTestX = cvDataObj.testXall{1};
            permTestTestY = cvDataObj.testYall{1};
            
            disp('Conducting permutation tests');
            for (i = 1:ip.Results.permutations)
                
                disp(['  ' num2str(i) ' of ' num2str(ip.Results.permutations)]);

                % permuate training/dev data
                permTestTrainX = cvDataObj.trainXall{1};
                trainY = cvDataObj.trainYall{1};
                permTestDevX = cvDataObj.devXall{1};
                devY = cvDataObj.devYall{1};
                
                trainDevY = [trainY; devY];
                permTestTrainDevY = trainDevY(randperm(length(trainDevY)), :);

                permTestTrainY = permTestTrainDevY(1:length(trainY));
                permTestDevY = permTestTrainDevY(length(trainY)+1:end);
                
                % conduct grid search here
                [gamma_opt_perm, C_opt_perm] = Utils.trainDevGridSearch(permTestTrainX, permTestTrainY, ...
                    permTestDevX, permTestDevY, ip);
                
                gammaDist(i) = gamma_opt_perm;
                cDist(i) = C_opt_perm;
                
                % Train permutation model and predict test data
                evalc(['permTestM = Classification.trainMulti(' ...
                    ' permTestTrainX, permTestTrainY, '...
                    ' ''classifier'', ip.Results.classifier, ' ...
                    ' ''PCA'', 0, ''scale'', false, ' ...
                    ' ''rngType'', ip.Results.rngType, ' ...
                    ' ''gamma'', gamma_opt_perm, ''C'', C_opt_perm, ' ...
                    ' ''kernel'', ip.Results.kernel, ' ...
                    ' ''minLeafSize'', ip.Results.minLeafSize )' ]);

                evalc(['permTestOutput = Classification.predict(permTestM, '...
                    'permTestTestX, ''actualLabels'', permTestTestY);' ]);
                accArr(i) = permTestOutput.accuracy;
            end
            
            
        elseif ( strcmp(ip.Results.optimization, 'nestedCV') )
            permTestTestX = cvDataObj.testXall{1};
            permTestTestY = cvDataObj.testYall{1};
            disp('Conducting permutation tests');
        	for i = 1:ip.Results.permutations
                disp(['  ' num2str(i) ' of ' num2str(ip.Results.permutations)]);
                % permute training/dev data
                permTestTrainX = cvDataObj.trainXall{1};
                trainY = cvDataObj.trainYall{1};
                permTestTrainY = trainY(randperm(length(trainY)), :);
                permCvDataObj = cvDataObj;
                permCvDataObj.trainYall{1} = permTestTrainY;
                
                % conduct grid search here
                [gamma_opt_perm, C_opt_perm] = Utils.nestedCvGridSearch(...
                     X, Y, ip, cvDataObj);

                gammaDist(i) = gamma_opt_perm;
                cDist(i) = C_opt_perm;
                 
                % Train permutation model and predict test data
                evalc(['permTestM = Classification.trainMulti(' ...
                    ' permTestTrainX, permTestTrainY, '...
                    ' ''classifier'', ip.Results.classifier, ' ...
                    ' ''PCA'', 0, ''scale'', false, ' ...
                    ' ''rngType'', ip.Results.rngType, ' ...
                    ' ''gamma'', gamma_opt_perm, ''C'', C_opt_perm, ' ...
                    ' ''kernel'', ip.Results.kernel, ' ...
                    ' ''minLeafSize'', ip.Results.minLeafSize )' ]);

                evalc(['permTestOutput = Classification.predict(permTestM, '...
                    '  permTestTestX, ''actualLabels'', permTestTestY);' ]);
                accArr(i) = permTestOutput.accuracy;
            end
        end
        C.permAccs = accArr;
        C.permGammas = gammaDist;
        C.permCs = cDist;
    else
        C.pVal = NaN;
        C.permAccs = NaN;
    end
    
    C.accuracy = Utils.computeAccuracy(labelsConcat, predictionsConcat); 
    C.modelsConcat = modelsConcat;
    C.predY = predictionsConcat;
    C.classificationInfo = classificationInfo;
    if ip.Results.permutations > 0
        C.pVal = permTestPVal(C.accuracy, accArr);
    end
    
    % close parallel workers
    if exist('closePool', 'var')
        if closePool
            matlabpool close;
        else
            delete(gcp('nocreate'));
        end
    end
    
    C.elapsedTime = toc(cvMultiOpt_time);
    disp('crossValidateMulti_opt() Finished!')
    disp(['Elapsed time: ' num2str(C.elapsedTime) ' seconds'])
    
 end
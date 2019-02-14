 function [C, varargout] = crossValidateEEG(X, Y, varargin)
% -------------------------------------------------------------------------
% [CM, accuracy, classifierInfo] = crossValidateEEG(X, Y, shuffleData)
% -------------------------------------------------------------------------
% Blair/Bernard - Feb. 22, 2017
%
% The main function for sorting user inputs and calling classifier.
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
%   'randomSeed' - This option determines whether the randomization is to produce
%       varying or unvarying results each different execution.
%        --options--
%       'shuffle' (default)
%       'default' (replicate results)
%   'shuffleData' - determine whether to shuffle the order of trials within 
%       training data matrix X (order of labels in the labels vector Y will be
%       shuffled in the same order)
%       --options--
%       1 - shuffle (default)
%       0 - do not shuffle
%   'averageTrials' - how to compute averaging of trials in X to increase accuracy
%       --options--
%       (negative value) - don't average
%       (postitive int) - number of integers to average over
%   'averageTrialsHandleRemainder' - Handle remainder trials (if any) from 
%       trial averaging 
%       --options--
%
%
%   'PCA' - Conduct Principal Component analysis on data matrix X. Default is to
%       keep components that explan 90% of the variance. To retrieve
%       components that explain a certain variance, enter the variance as a
%       decimal between 1 and 0.  To retrieve a certain number of most
%       significant features, enter an integer greater or equal to 1.
%       --options--
%       (decimal between 0 and 1, N) - Use most important features that
%           explain N * 100% of the variance in input matrix X.
%       (integer greater than or equal to 1, N) - Use N most important
%       features of input matrix X.
%   'PCAinFold' - whether or not to conduct PCA in each fold.
%       --options--
%       1 (default) - conduct PCA within each fold.
%       0 - one PCA for entire training data matrix X.
%   'nFolds' - number of folds in cross validation.  Must be integer
%       greater than 1 and less than number of trials. Default is 10.
%   'classify' - choose classifier. 
%        --options--
%       'SVM' (default)
%       'LDA' 
%       'RF' 
%   pValueMethod - Choose the method to compute p-value.  
%       --options--
%       'binomcdf' (default)
%           computes a binomial cdf at each of the values in x using number 
%           of permutations sepcified in 'permutations'in N and probability 
%           of success for each trial in p
%       'permuteTestLabels' 
%           with the 'permuteTestLabels' option, we perform k -fold cross 
%           validation only once. In each fold, the classification model is   
%           trained on the intact data and labels, but predictions are made
%           on test observations whose labels have been shuffled. The prediction   
%           is repeated N times, with the test labels re-randomized for each   
%           attempt. The 'permuteTestLabels' option is the second fastest method,   
%           since it requires training the k models only once, but a total of
%           k * N  prediction operations are performed. So that there are enough
%           test labels to randomize in each fold, here we also recommend having   
%           at least 100 observations total, and no more than 10 cross-validation folds.
%       'permuteFullModel'
%           With the ?permuteFullModel? option, we perform the entire 10-fold 
%           cross validation N times. For each of the N permutation iterations, 
%           the entire labels vector (training and test observations) is shuffled, 
%           and in each fold, the classifier model is both trained and tested using 
%           the shuffled labels. As the full classification procedure is performed 
%           N times, the ?permuteFullModel? option is the slowest, but is suitable 
%           to use with any classifier configuration, including settings with 
%           unbalanced classes, few observations, and up to N-fold cross validation.
%   'permutations' - Choose number of permutations to perform.  Default
%           1000.  This option will only work if 'permuteFullModel' or 
%           'permuteTestLabels' is chosen.
%   'kernel' - Choose the kernel for decision function for SVM.  This input will do
%       nothing if a classifier other than SVM is selected.
%        --options--
%       'linear' 
%       'polynomial' 
%       'rbf' (default)
%       'sigmoid' 
%   'numTrees' - Choose the number of decision trees to grow.  Default is
%   128.
%   'minLeafSize' - Choose the inimum number of observations per tree leaf.
%   Default is 1,
%   'verbose' - Include the distribution of accuracies from the
%   permutations test and also a concatednated struct of all the models
%
% OUTPUT ARGS 
%   CM - Confusion matrix that summarizes the performance of the
%       classification, in which rows represent actual labels and columns
%       represent predicted labels.  Element i,j represents the number of 
%       observations belonging to class i that the classifier labeled as
%       belonging to class j.
%   accuracy - Classification accuracy
%   predY - predicted label vector
%   pVal - p-value of the classification
%       classifierInfo - A struct summarizing the options selected for the
%       classification.
%   accDist (verbose output) - The distribution of N accuracies
%       calculated from the permutation test in vector form.  This argument will be 
%       NaN is 'binomcdf' is passed into parameter 'pValueMethod', or else,
%       it will return the accuracy vector.
%   modelsConcat (verbose output) - Struct containing the N models used during cross
%   validation.
%

% TODO:
%   Check when the folds = 1, what we should do 

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

    tic
    
    % Initialize the input parser
    ip = inputParser;
    ip.CaseSensitive = false;

    % ADD SPACEUSE TIMEUSE AND FEATUREUSE, DEAFULT SHOULD B EMPTY MATRIX
    
    %Specify default values
    defaultShuffleData = 1;
    defaultAverageTrials = -1;
    defaultAverageTrialsHandleRemainder = 'discard';
    defaultPCA = .9;
    defaultPCAinFold = 1;
    defaultNFolds = 10;
    defaultClassify = 'SVM';
    defaultPValueMethod = '';
    defaultPermutations = 1000;
    defaultTimeUse = [];
    defaultSpaceUse = [];
    defaultFeatureUse = [];
    defaultVerbose = 0;
    defaultRandomSeed = 'shuffle';
    defaultKernel = 'rbf';
%   defaultDiscrimType = 'linear';
    defaultNumTrees = 64;
    defaultMinLeafSize = 1;


    %Specify expected values
    expectedShuffleData = [0, 1];
    expectedAverageTrialsHandleRemainder = {'discard','newGroup', 'append', 'distribute'};
    expectedPCAinFold = [0,1];
    expectedClassify = {'SVM', 'LDA', 'RF'};
%     expectedPValueMethod = {'binomcdf', 'permuteTestLabels', 'permuteFullModel'};
    expectedPValueMethod = {'permuteFullModel'};
    expectedVerbose = {0,1};
    expectedRandomSeed = {'default', 'shuffle'};
    expectedKernel = {'linear', 'sigmoid', 'rbf', 'polynomial'};
    
    
    %Required inputs
    addRequired(ip, 'X', @is2Dor3DMatrixOrCell)
    addRequired(ip, 'Y', @isVectorOrCell)
    [r c] = size(X);

    %Optional positional inputs
    %addOptional(ip, 'distpower', defaultDistpower, @isnumeric);
    if verLessThan('matlab', '8.2')
        addParamValue(ip, 'shuffleData', defaultShuffleData, ...
            @(x) (x==1 || x==0));
        addParamValue(ip, 'averageTrials', defaultAverageTrials, ...
            @(x) assert(rem(x,1) == 0 ));
        addParamValue(ip, 'averageTrialsHandleRemainder', ...
            defaultAverageTrialsHandleRemainder, ...
            @(x) any(validatestring(x, expectedAverageTrialsHandleRemainder)));
        addParamValue(ip, 'PCA', defaultPCA);
        addParamValue(ip, 'PCAinFold', defaultPCAinFold);
        addParamValue(ip, 'nFolds', defaultNFolds);
        addParamValue(ip, 'classify', defaultClassify, ...
             @(x) any(validatestring(x, expectedClassify)));

        addParamValue(ip, 'pValueMethod', defaultPValueMethod, ...
            @(x) any(validatestring(x, expectedPValueMethod)));
        % must be a positive integer
        addParamValue(ip, 'permutations', defaultPermutations, ...
            @(x) (x>0 && rem(x,1) == 0));
        addParamValue(ip, 'timeUse', defaultTimeUse, ...
            @(x) (assert(isvector(x))));
        addParamValue(ip, 'spaceUse', defaultSpaceUse, ...
            @(x) (assert(isvector(x))));
        addParamValue(ip, 'featureUse', defaultFeatureUse, ...
            @(x) (assert(isvector(x))));
        addParamValue(ip, 'featureUse', defaultFeatureUse, ...
            @(x) (assert(isvector(x))));
        addParamValue(ip, 'verbose', defaultVerbose, ...
            @(x) assert(x==1 | x==0, 'verbose should be either 0 or 1'));
        addParamValue(ip, 'randomSeed', defaultRandomSeed,  @(x) isequal('default', x)...
            || isequal('shuffle', x) || (isnumeric(x) && x > 0));
        addParamValue(ip, 'kernel', @(x) any(validatestring(x, expectedKernels)));
        addParamValue(ip, 'numTrees', 128);
        addParamValue(ip, 'minLeafSize', 1);
    else
        addParameter(ip, 'shuffleData', defaultShuffleData, ...
            @(x)  (x==1 || x==0));
        addParameter(ip, 'averageTrials', defaultAverageTrials, ...
            @(x) assert(rem(x,1) == 0 ));
        addParameter(ip, 'averageTrialsHandleRemainder', ...
            defaultAverageTrialsHandleRemainder, ...
            @(x) any(validatestring(x, expectedAverageTrialsHandleRemainder)));
        addParameter(ip, 'PCA', defaultPCA);
        addParameter(ip, 'PCAinFold', defaultPCAinFold);
        addParameter(ip, 'nFolds', defaultNFolds);
        addParameter(ip, 'classify', defaultClassify, ...
             @(x) any(validatestring(x, expectedClassify)));

        addParameter(ip,'pValueMethod', defaultPValueMethod, ...
             @(x) any(validatestring(x, expectedPValueMethod)));
        % must be a positive integer
        addParameter(ip, 'permutations', defaultPermutations, ...
            @(x) (x>0 && rem(x,1) == 0));
        addParameter(ip, 'timeUse', defaultTimeUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'spaceUse', defaultSpaceUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'featureUse', defaultFeatureUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'verbose', defaultVerbose, ...
            @(x) assert(x==1 | x==0, 'verbose should be either 0 or 1'));
        addParameter(ip, 'randomSeed', defaultRandomSeed,  @(x) isequal('default', x)...
            || isequal('shuffle', x) || (isnumeric(x) && x > 0));
        addParameter(ip, 'kernel', 'rbf', @(x) any(validatestring(x, expectedKernels)));
        addParameter(ip, 'numTrees', 128);
        addParameter(ip, 'minLeafSize', 1);
    end
    
    %Optional name-value pairs
    %NOTE: Should use addParameter for R2013b and later.
    
%     if (find(isnan(X(:))))
%         error('MatClassRSA classifiers cannot handle missing values (NaNs) in the data at this time.')
%     end
% 

    % Parse
    try 
        parse(ip, X, Y, varargin{:});
    catch ME
        disp(getReport(ME,'extended'));
    end
    
    classifyFlag = 0;
    CVflag = 0;
    
    % check input data 
    if iscell(X) && iscell(Y)
        classifyFlag = 1;
    % check 1) X is either 2 by 1 or 3 by 1 matrix  2) Y is regular vector
    % and 3) both X and Y are not cell arrays
    elseif (ndims(X) == 3 || ismatrix(X)) && isvector(Y) == 1 ...
            && ~iscell(X) && ~iscell(Y)
        CVflag = 1;
    else
        error('X and Y must either both be cell arrays or both be matrices')
    end
    

    
        
    % Initilize info struct
    classifierInfo = struct('shuffleData', ip.Results.shuffleData, ...
                        'averageTrials', ip.Results.averageTrials, ...
                        'averageTrialsHandleRemainder', ip.Results.averageTrialsHandleRemainder, ...
                        'PCA', ip.Results.PCA, ...
                        'PCAinFold', ip.Results.PCAinFold, ...
                        'nFolds', ip.Results.nFolds, ...
                        'classify', ip.Results.classify, ...
                        'pValueMethod', ip.Results.pValueMethod, ...
                        'permutations', ip.Results.permutations);
    
    % If user wants to train model and classify on test matrices we must 
    % test and subset data separately
    if (classifyFlag)
        disp('Train model and classify test set')
        %[accuracy, predY, pVal] = trainModelTestData(X, Y, ip);
        [accuracy, predY, pVal] = trainModelTestData(X{1}, Y, ip);

        CM = NaN;
        classifierInfo.shuffleData = 'N/A';
        classifierInfo.averageTrials = 'N/A';
        classifierInfo.averageTrialsHandleRemainder = 'N/A';
        classifierInfo.nFolds = 'N/A';
        classifierInfo.pValueMethod = NaN;
        classifierInfo.permutations = NaN;
        
        return;
    % If user wants to cross validate on entire dataset, we subet
    % data into folds
    elseif (CVflag)
       % check if data is double, convert to double if it isn't
       if ~isa(X, 'double')
           warning('X data matrix not in double format.  Converting X values to double.')
           disp('Converting X matrix to double')
           X = double(X); 
       end
       if ~isa(Y, 'Converting Y matrix to double')
           warning('Y label vector not in double format.  Converting Y labels to double.')
           Y = double(Y);
       end
        [X Y, nSpace, nTime, nTrials] = subsetTrainTestMatrices(X,Y, ip);
    end
    
    
    % let r and c store size of 2D matrix
    [r c] = size(X);
    
    %%%%% Whatever we started with, we now have a 2D trials-by-feature matrix
    % moving forward.

    % SET RANDOM SEED
    % for data shuffling and permutation testing purposes
    rng(ip.Results.randomSeed);
    
    % DATA SHUFFLING (doing)
    % Default 1
    if (ip.Results.shuffleData)
        disp('Shuffling Trials');
        [X, Y, shuffledInd] = shuffleData(X, Y);
    else
        classifierInfo.shuffleData = 'off';
        Y = Y';maybe
    end

    % TRIAL AVERAGING (doing)
     if(ip.Results.averageTrials >= 1)
        disp('Averaging Trials');
        [X, Y] = averageTrials(X, Y, ip.Results.averageTrials, ...
            'handleRemainder' ,ip.Results.averageTrialsHandleRemainder);
        classifierInfo.averageTrials = 'on';
        [r c] = size(X);
     end
     
    % PCA 
    % Split Data into fold (w/ or w/o PCA)
    disp('Conducting Principal Component Analysis');
    partition = cvpart(r, ip.Results.nFolds);
    tic
    cvDataObj = cvData(X,Y, partition, ip.Results.PCA, ip.Results.PCAinFold);
    toc
    
    
    %PERMUTATION TEST (assigning)
    [r c] = size(X);
    tic
    switch ip.Results.pValueMethod
         case 'binomcdf'
             % case is handled at the end, when the accuracy of the
             % classifier is calculated
             accDist = NaN;
%         case 'permuteTestLabels'
%             accDist = permuteTestLabels(Y, cvDataObj, ip);
        case 'permuteFullModel'
            accDist = permuteFullModel(Y, cvDataObj, ip);
        otherwise
            % permute Test Labels case
            accDist = NaN;
    end
    toc
    
    % CROSS VALIDATION
    disp('Cross Validating')
    
    % Just partition, as shuffling (or not) was handled in previous step
    % if nFolds == 1
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

    for i = 1:ip.Results.nFolds
        
        disp(['Fold ' num2str(i) ' of ' num2str(ip.Results.nFolds)])
        
        trainX = cvDataObj.trainXall{i};
        trainY = cvDataObj.trainYall{i};
        testX = cvDataObj.testXall{i};
        testY = cvDataObj.testYall{i};

        mdl = fitModel(trainX, trainY, ip);
        
        predictions = modelPredict(testX, mdl);
        
        labelsConcat = [labelsConcat testY];
        predictionsConcat = [predictionsConcat predictions];
        modelsConcat{i} = mdl; 
        
        
        %predictcedY(partition.test(i)) = predictions;
    end
    CM = confusionmat(labelsConcat, predictionsConcat);
    accuracy = computeAccuracy(labelsConcat, predictionsConcat); 
    
    
    % unshuffle predictions vector to return to user IF shuffle is on
    if (ip.Results.shuffleData == 1)
        predY = NaN(1, r);
        for i = 1:r
            predY(shuffledInd(i)) = predictionsConcat(i);
        end
    else
        predY = predictionsConcat;
    end
    
    switch ip.Results.pValueMethod
         case 'binomcdf'
            pVal = pbinom(Y, ip.Results.nFolds, accuracy);
%         case 'permuteTestLabels'
%             pVal = permTestPVal(accuracy, accDist);
        case 'permuteFullModel'
            pVal = permTestPVal(accuracy, accDist);
        otherwise
            pVal = '';
            
    end
    
    if ip.Results.verbose
        varargout{1} = accDist;
        varargout{2} = modelsConcat;
        C.accDist = accDist;
        C.modelsConcat = modelsConcat;
    end
    
    C.CM = CM;
    C.accuracy = accuracy;
    C.predY = predY;
    C.pVal = pVal;
    C.classifierInfo = classifierInfo;
    toc
    
 end

 
 function y = is2Dor3DMatrixOrCell(x)
        % check if input is a cell with two matrices, each of the same width
        if iscell(x)
            if isequal(size(x), [1 2])
                [r1 w1] = size(x{1});
                [r2 w2] = size(x{2});
                if w1 == w2
                    y = 1;
                else
                    y = 0;
                end
            end
        % check input is a 2D matrix
        elseif ismatrix(x)
            y = 1;
        % checck if input is a 3D matrix
        elseif isequal(size(size(x)), [1 3])
            y = 1;
        else
            y = 0;
        end
 end
 
 function y = isVectorOrCell(x)
    if iscell(x)
        y = 1;
    elseif isvector(x)
        y = 1;
    else
        y = 0;
    end
 end
    
 function C = crossValidateMulti(obj, X, Y, varargin)
% -------------------------------------------------------------------------
% RSA = MatClassRSA;
% C = RSA.classify.crossValidateMulti(X, Y, varargin)
% -------------------------------------------------------------------------
% Blair/Bernard - Feb. 22, 2017
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
%   'randomSeed' - random seed for reproducibility. If not entered, rng
%       will be assigned as ('shuffle', 'twister').
%       --- Acceptable specifications for rand_seed ---
%       - Single acceptable rng specification input (e.g., 1,
%           'default', 'shuffle'); in these cases, the generator will
%           be set to 'twister'.
%       - Dual-argument specifications as either a 2-element cell
%           array (e.g., {'shuffle', 'twister'}) or string array
%       (   e.g., ["shuffle", "twister"].
%       - rng struct as assigned by rand_seed = rng.
%   'PCA' - Conduct Principal Component analysis on data matrix X. Default is to
%       keep components that explan 99% of the variance. To retrieve
%       components that explain a certain variance, enter the variance as a
%       decimal between 1 and 0.  To retrieve a certain number of most
%       significant features, enter an integer greater or equal to 1.
%       --options--
%       (decimal between 0 and 1, N) - Use most important features that
%           explain N * 100% of the variance in input matrix X.
%       (integer greater than or equal to 1, N) - Use N most important
%       0 - PCA turned off
%       features of input matrix X.
%   'PCAinFold' - whether or not to conduct PCA in each fold.
%       --options--
%       1 (default) - conduct PCA within each fold.
%       0 - one PCA for entire training data matrix X.
%   'nFolds' - number of folds in cross validation.  Must be integer
%       greater than 1 and less than number of trials. Default is 10.
%   'classifier' - choose classifier. 
%        --options--
%       'SVM' 
%       'LDA' (default)
%       'RF' 
%   'kernel' - Choose the kernel for decision function for SVM.  This input will do
%       nothing if a classifier other than SVM is selected.
%        --options--
%       'linear' (default)
%       'polynomial' 
%       'rbf' 
%       'sigmoid' 
%   'gamma' - 
%   'C' - 
%   'numTrees' - Choose the number of decision trees to grow.  Default is
%   128.
%   'minLeafSize' - Choose the minimum number of observations per tree leaf.
%   Default is 1,
%   'permutations' - Choose number of permutations to perform. Default value 
%   is 0, where permutation testing is turned off.  
%   'center' - Specification for centering columns of the data.  If empty or 
%   not specified, will default to true.
%   'scale' - Specification for scaling columns of the data. If
%   empty or not specified, will default to true.
%
%
% OUTPUT ARGS 
%   C - output object containing all cross validation related
%   information, including confucion matrix, accuracy, prediction results
%   etc.  The structure of C will differ depending on the value of the 
%   input value 'pairwise', which is set to 0 by default.  if 'pairwise' 
%   is set to 1, then C will be a cell matrix of structs, symmetrical along 
%   the diagonal.  If pairwise is 0, then C is a struct containing values:
%   
%   CM - Confusion matrix that summarizes the performance of the
%       classification, in which rows represent actual labels and columns
%       represent predicted labels.  Element i,j represents the number of 
%       observations belonging to class i that the classifier labeled as
%       belonging to class j.
%   accuracy - Classification accuracy
%   predY - predicted label vector
%   modelsConcat - Struct containing the N models used during cross
%   validation.

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
    
    st = dbstack;
    namestr = st.name;
    ip = inputParser;
    ip = initInputParser(namestr, ip);
    %Required inputs
    [r c] = size(X);
    
    %Optional name-value pairs
    %NOTE: Should use addParameter for R2013b and later.
    if (find(isnan(X(:))))
        error('MatClassRSA classifiers cannot handle missing values (NaNs) in the data at this time.')
    end

    % Parse Inputs
    parse(ip, X, Y, varargin{:});
    
    % If SVM is selected, then gamma and C parameters must be manually set
    verifySVMParameters(ip);
   
   % check if data is double, convert to double if it isn't
    [X, Y] = convert2double(X,Y);
   
   [X, nSpace, nTime, nTrials] = subsetTrainTestMatrices(X, ...
                                                ip.Results.spaceUse, ...
                                                ip.Results.timeUse, ...
                                                ip.Results.featureUse);

    
    % let r and c store size of 2D matrix
    [r c] = size(X);
    [r1 c1] = size(Y);
    
    if (r1 < c1)
        Y = Y'
    end
    
    
    %%%%% Whatever we started with, we now have a 2D trials-by-feature matrix
    % moving forward.
    
    
    % SET RANDOM SEED
    % for Random forest purposes
    %rng(ip.Results.randomSeed);
    setUserSpecifiedRng(ip.Results.randomSeed);

    % Split Data into fold (w/ or w/o PCA)
    if (ip.Results.PCA>0 && ip.Results.PCA>0)
        disp(['Conducting Principal Component Analysis']);
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
    % partition data for cross validation 
    trainTestSplit = [1-1/ip.Results.nFolds 1/ip.Results.nFolds];
    partition = trainDevTestPart(X, ip.Results.nFolds, trainTestSplit); 
    cvDataObj = cvData(X,Y, partition, ip, ipCenter, ipScale);
    

    %PERMUTATION TEST (assigning)
    tic    
    if ip.Results.permutations > 0
        % return distribution of accuracies (Correct clasification percentage)
        accDist = permuteModel(namestr, X, Y, cvDataObj, 1, ip.Results.permutations , ...
                    ip.Results.classifier, trainTestSplit, ip);
    else
        accDist = NaN;
    end
    toc

    % CROSS VALIDATION
    disp('Cross Validating')
    
    % Must have at least two folds for CV
    if ip.Results.nFolds == 1
        % Special case of fitting model with no test set (argh)
        error('nFolds must be a integer value greater than 1');
    end

    %  nFolds must be an integer between 2 and nTrials to perform CV
    assert(ip.Results.nFolds > 0 & ...
        ceil(ip.Results.nFolds) == floor(ip.Results.nFolds) & ...
        ip.Results.nFolds <= nTrials, ...
        'nFolds must be an integer between 1 and nTrials to perform CV' );
        
    % init CV parameters
    predictionsConcat = [];
    labelsConcat = [];
    modelsConcat = {1, ip.Results.nFolds};       
    numClasses = length(unique(Y));
    numDecBounds = nchoosek(numClasses ,2);
    pairwiseMat3D = zeros(2,2, numDecBounds);
    % diagonal cell matrix of structs containing pairwise classification infomration
    % 
    pairwiseCell = initPairwiseCellMat(numClasses);
    CM = NaN;
   

    tic
    for i = 1:ip.Results.nFolds

        disp(['Computing fold ' num2str(i) ' of ' num2str(ip.Results.nFolds) '...'])

        trainX = cvDataObj.trainXall{i};
        trainY = cvDataObj.trainYall{i};
        testX = cvDataObj.testXall{i};
        testY = cvDataObj.testYall{i};

        [mdl, scale] = fitModel(trainX, trainY, ip, ip.Results.gamma, ip.Results.C);

        [predictions decision_values] = modelPredict(testX, mdl, scale);

        labelsConcat = [labelsConcat testY'];
        predictionsConcat = [predictionsConcat predictions];
        modelsConcat{i} = mdl; 

        C.CM = confusionmat(labelsConcat, predictionsConcat);
        C.accuracy = computeAccuracy(labelsConcat, predictionsConcat); 

    end
    toc

    % Initilize info struct for return
    classificationInfo = struct(...
                        'PCA', ip.Results.PCA, ...
                        'PCAinFold', ip.Results.PCAinFold, ...
                        'nFolds', ip.Results.nFolds, ...
                        'classifier', ip.Results.classifier, ...
                        'dataPartitionObj', cvDataObj);

    C.classificationInfo = classificationInfo;
    C.modelsConcat = modelsConcat;
    C.predY = predictionsConcat;
    C.dataPartitionObj = cvDataObj;
    C.elapsedTime = toc;
    C.pVal = permTestPVal(C.accuracy, accDist);
    disp('classifyCrossValidate() Finished!')
    disp(['Elapsed time: ' num2str(C.elapsedTime)])

    
 end
    
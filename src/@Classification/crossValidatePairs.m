 function C = crossValidatePairs(obj, X, Y, varargin)
% -------------------------------------------------------------------------
% C = crossValidatePairs(X, Y, varargin)
% -------------------------------------------------------------------------
% Blair/Bernard - Jun. 21, 2020
%
% Given a data matrix X and labels vector Y, this function will conduct 
% pairwise cross validation, then output a struct containing the 
% classification accuracies, confusion matrices, ano other info for each 
% pair of labels.  Optional name-value parameters can be passed in to specify classification 
% related options.  
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
%   'randomSeed' - random seed for reproducibility. If not entered, rng
%       will be assigned as ('shuffle', 'twister').
%       --- Acceptable specifications for rand_seed ---
%       - Single acceptable rng specification input (e.g., 1,
%           'default', 'shuffle'); in these cases, the generator will
%           be set to 'twister'.
%       - Dual-argument specifications as either a 2-element cell
%           array (e.g., {'shuffle', 'twister'}) or string array
%           (e.g., ["shuffle", "twister"].
% - rng struct as assigned by rand_seed = rng.
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
%       analysis (LDA) and random forest (RF) 
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
%        'off' - centering turned off
%        'on' (default) - centering turned on 
%   'scale' - This variable controls data scaling, also known as data
%       normalization.  Setting this to a non-zero value to scales each 
%       feature to have unit variance prior to PCA.  Setting 
%       it to 0 turns off data scaling.  
%        --options--
%        'off' (default) - scaling turned off
%        'on' - centering turned on 
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

    % Initialize the input parser
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

    % Parse
    try 
        parse(ip, X, Y, varargin{:});
    catch ME
        disp(getReport(ME,'extended'));
    end
            
    % Initilize info struct
    classifierInfo = struct(...
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
   if ~isa(Y, 'Converting Y matrix to double')
       warning('Y label vector not in double format.  Converting Y labels to double.')
       Y = double(Y);
   end
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

    % Permutation Testing
    if ip.Results.permutations > 0
        % return distribution of accuracies (Correct clasification percentage)
        accDist = permuteModel(namestr, X, Y, cvDataObj, 1, ip.Results.permutations , ...
                    ip.Results.classifier, trainTestSplit, ip);
    end
    
    % CROSS VALIDATION
    disp('Cross Validating')
        
    predictionsConcat = [];
    labelsConcat = [];
       
    numClasses = length(unique(Y));
    numDecBounds = nchoosek(numClasses ,2);
    classPairs = nchoosek(1:numClasses, 2);
    pairwiseMat3D = zeros(2,2, numDecBounds);
    % initialize the diagonal cell matrix of structs containing pairwise
    % classification infomration
    pairwiseCell = initPairwiseCellMat(numClasses);
    C = struct();
    modelsConcat = cell(ip.Results.nFolds, numDecBounds);
    
    % Moving centering and scaling parameters out of ip, in case we need to
    % override the user's centering specification
    ipCenter = ip.Results.center; 
    ipScale = ip.Results.scale;

    CM = NaN;
    RSA = MatClassRSA;
   
    % PAIRWISE LDA/RF/SVM(w/ PCA)
    if (strcmp(upper(ip.Results.classifier), 'LDA') || ...
        strcmp(upper(ip.Results.classifier), 'RF') || ...
        strcmp(upper(ip.Results.classifier), 'SVM') && ip.Results.PCA > 0)
    
        % Data Partitioning, PCA, Centering and Sclaing
        % Split Data into fold (w/ or w/o PCA)
        if (ip.Results.PCA>0 && ip.Results.PCA>0)
            disp('Conducting Principal Component Analysis');
        else
            disp('Skipping Principal Component Analysis');
        end

        if ((~ip.Results.center) && (ip.Results.PCA>0) ) 
            warning(['Data centering must be on if performing PCA. Overriding '...
            'user input and removing the mean from each data feature.']);
            ipCenter = true;
        end

        AM = NaN(numClasses, numClasses);
        predictionsCell = cell(numClasses);
        actualLabelsCell = cell(numClasses);
        
        % Iterate through all pairs of classes
        for k = 1:numDecBounds
            
            % class1 class2
            class1 = classPairs(k, 1);
            class2 = classPairs(k, 2);
            
            % store indices of the trials of the current class pair of
            % interest
            currIndx = ismember(Y, [class1 class2]);
            currX = X(currIndx, :);
            currY = Y(currIndx);

%             % select trials/labels representing current pair of classes
%             trainX_tmp = trainX(trainInd, :);
%             testX_tmp = testX(testInd, :);
%             trainY_tmp = trainY(trainInd, :);
%             testY_tmp = testY(testInd, :);

            % partition data for cross validation 
            trainTestSplit = [1-1/ip.Results.nFolds 1/ip.Results.nFolds];
            partition = trainDevTestPart(currX, ip.Results.nFolds, trainTestSplit); 
            cvDataObj = cvData(currX, currY, partition, ip, ipCenter, ipScale);

            disp(['Cross Validating classes ' num2str(class1) ' and ' num2str(class2)]);

            for i = 1:ip.Results.nFolds

                trainX = cvDataObj.trainXall{i};
                trainY = cvDataObj.trainYall{i};
                testX = cvDataObj.testXall{i};
                testY = cvDataObj.testYall{i};

                [mdl, scale] = fitModel(trainX, trainY, ip, ip.Results.gamma, ip.Results.C);

                [predictions decision_values] = modelPredict(testX, mdl, scale);

                actualLabelsCell{class1, class2} = [actualLabelsCell{class1, class2} testY'];
                predictionsCell{class1, class2} = [predictionsCell{class1, class2} predictions];
                
                modelsConcat{i} = mdl; 
                
            end

        end
        
        for class1 = 1:numClasses-1
            for class2 = (class1+1):numClasses
                actualLabels = actualLabelsCell{class1, class2};
                predictions = predictionsCell{class1, class2};
                AM(class1, class2) = computeAccuracy(actualLabels, predictions);
                AM(class2, class1) = computeAccuracy(actualLabels, predictions);
            end
        end

        C.pairwiseInfo = pairwiseCell;
        C.AM = AM;
    % END PAIRWISE LDA/RF
    % SVM (no PCA, faster computation to rebutt reviewer comment on redundant pairwise partitioning)
    elseif  strcmp( upper(ip.Results.classifier), 'SVM') && (ip.Results.PCA <= 0)
             
        % partition data for cross validation 
        trainTestSplit = [1-1/ip.Results.nFolds 1/ip.Results.nFolds];
        partition = trainDevTestPart(X, ip.Results.nFolds, trainTestSplit); 
        cvDataObj = cvData(X,Y, partition, ip, ipCenter, ipScale);
        
        for i = 1:ip.Results.nFolds

            disp(['Computing fold ' num2str(i) ' of ' num2str(ip.Results.nFolds) '...'])

            trainX = cvDataObj.trainXall{i};
            trainY = cvDataObj.trainYall{i};
            testX = cvDataObj.testXall{i};
            testY = cvDataObj.testYall{i};

            [mdl, scale] = fitModel(trainX, trainY, ip, ip.Results.gamma, ip.Results.C);

            [predictions decision_values] = modelPredict(testX, mdl, scale);

            labelsConcat = [labelsConcat testY];
            predictionsConcat = [predictionsConcat predictions];
            modelsConcat{i} = mdl; 


            if strcmp(upper(ip.Results.classifier), 'SVM')
                [pairwiseAccuracies, pairwiseMat3D, pairwiseCell] = ...
                    decValues2PairwiseAcc(pairwiseMat3D, testY, mdl.Label, decision_values, pairwiseCell);
            end
            
        end
        
        %convert pairwiseMat3D to diagonal matrix
        C.pairwiseInfo = pairwiseCell;
        C.AM = pairwiseAccuracies;
    end
    % END  of Cross Validation
    
    % Permutation testing
    if ip.Results.permutations > 0
        for i = 1:ip.Results.permutations
            [r c] = size(X);
            pX = X(randperm(r), :);
            permC = trainPairs(pX, Y, 'classifier', ip.Results.classifier, ...
                'nFolds', ip.Results.nFolds, 'C', ip.Results.C, 'gamma', ip.Results.gamma,...
                'kernel', ip.Results.kernel, 'numTrees', ip.Results.numTrees, ...
                'minLeafSize', ip.Results.minLeafSize);
            
        end
        % return distribution of accuracies (Correct clasification percentage)
        accDist = permuteModel(namestr, X, Y, cvDataObj, 1, ip.Results.permutations , ...
                    ip.Results.classifier, trainTestSplit, ip);
    end
    
    C.modelsConcat = modelsConcat;
    C.classificationInfo = classifierInfo;
    % calculate pVal return matrix for all pairs. 
    if ip.Results.permutations > 0
        C.pVal = nan(numClasses, numClasses);
        for class1 = 1:numClasses-1
            for class2 = (class1+1):numClasses
                thisAccDist = accDist(class1, class2, :);
                C.pVal(class1, class2) = permTestPVal(C.AM(class1, class2), thisAccDist);
                C.pVal(class2, class1) = C.pVal(class1, class2);
            end
        end
    end
   
    disp('crossValidatePairs() Finished!')
    
 end
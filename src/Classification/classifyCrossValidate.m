 function C = classifyCrossValidate(X, Y, varargin)
% -------------------------------------------------------------------------
% C = classifyCrossValidate(X, Y, varargin)
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
%       keep components that explan 90% of the variance. To retrieve
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
%       'SVM' (default)
%       'LDA' 
%       'RF' 
%   'kernel' - Choose the kernel for decision function for SVM.  This input will do
%       nothing if a classifier other than SVM is selected.
%        --options--
%       'linear' 
%       'polynomial' 
%       'rbf' (default)
%       'sigmoid' 
%   'gamma' - 
%   'C' - 
%   'numTrees' - Choose the number of decision trees to grow.  Default is
%   128.
%   'minLeafSize' - Choose the minimum number of observations per tree leaf.
%   Default is 1,
%   'permutations' - Choose number of permutations to perform. Default value 
%   is 0, where permutation testing is turned off.  
%
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

    % Initialize the input parser
    ip = inputParser;
    ip.CaseSensitive = true;

    % ADD SPACEUSE TIMEUSE AND FEATUREUSE, DEAFULT SHOULD B EMPTY MATRIX
    
    %Specify default values
    defaultShuffleData = 1;
    defaultAverageTrials = -1;
    defaultAverageTrialsHandleRemainder = 'discard';
    defaultPCA = .99;
    defaultPCAinFold = 1;
    defaultNFolds = 10;
    defaultClassifier = 'SVM';
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


    %Specify expected values
    expectedShuffleData = [0, 1];
    expectedAverageTrialsHandleRemainder = {'discard','newGroup', 'append', 'distribute'};
    expectedPCAinFold = [0,1];
    expectedClassifier = {'SVM', 'LDA', 'RF', 'SVM2', 'svm', 'lda', 'rf'};
%     expectedPValueMethod = {'binomcdf', 'permuteTestLabels', 'permuteFullModel'};
    expectedPValueMethod = {'permuteFullModel'};
    expectedRandomSeed = {'default', 'shuffle'};
    expectedKernels = {'linear', 'sigmoid', 'rbf', 'polynomial'};
    expectedGamma = {'default'};
    expectedPairwise = {0,1};
    expectedCenter = {0,1};
    expectedScale = {0,1};
    
    %Required inputs
    addRequired(ip, 'X', @is2Dor3DMatrixOrCell)
    addRequired(ip, 'Y', @isVectorOrCell)
    [r c] = size(X);

    %Optional positional inputs
    %addOptional(ip, 'distpower', defaultDistpower, @isnumeric);
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
        addParamValue(ip, 'gamma', 'default',  @(x) any([strcmp(x, 'default') isnumeric(x)]));
        addParamValue(ip, 'C', 1);
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
        addParameter(ip, 'classifier', defaultClassifier, ...
             @(x) any(validatestring(x, expectedClassifier)));
        addParameter(ip, 'timeUse', defaultTimeUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'spaceUse', defaultSpaceUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'featureUse', defaultFeatureUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'kernel', 'rbf', @(x) any(validatestring(x, expectedKernels)));
        addParameter(ip, 'gamma', 'default', @(x) any([strcmp(x, 'default') isnumeric(x)]));
        addParameter(ip, 'C', 1);
        addParameter(ip, 'numTrees', 128);
        addParameter(ip, 'minLeafSize', 1);
        addParameter(ip, 'pairwise', 0);
    end
    
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

    % PCA 
    % Split Data into fold (w/ or w/o PCA)
    if (ip.Results.PCA>0 && ip.Results.PCA>0)
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
    partition = cvpart(r, ip.Results.nFolds);
    tic 
    cvDataObj = cvData(X,Y, partition, ip, ipCenter, ipScale);
    toc
    
    
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
    pairwiseMat3D = zeros(2,2, numDecBounds);
    % initialize the diagonal cell matrix of structs containing pairwise
    % classification infomration
    pairwiseCell = initPairwiseCellMat(numClasses);

    
    CM = NaN;
   
    % PAIRWISE LDA/RF
    if (ip.Results.pairwise == 1) && ...
        (strcmp(upper(ip.Results.classifier), 'LDA') || ...
        strcmp(upper(ip.Results.classifier), 'RF'))
    
        decision_values = NaN(length(Y), numDecBounds);
        AM = NaN(numClasses, numClasses);
    
        for cat1 = 1:numClasses-1
            for cat2 = (cat1+1):numClasses
                disp([num2str(cat1) ' vs ' num2str(cat2)]) 
                currUse = ismember(Y, [cat1 cat2]);
      
                tempX = X(currUse, :);
                tempY = Y(currUse);
                tempStruct = struct();
                % Store the accuracy in the accMatrix
                [~, tempC] = evalc([' classifyCrossValidate(tempX, tempY, ' ...
                    ' ''classifier'', ip.Results.classifier, ''randomSeed'',' ...
                    ' ''default'', ''PCAinFold'', ip.Results.PCAinFold, '...
                    ' ''nFolds'', ip.Results.PCAinFold) ' ]);
                tempStruct.CM = tempC.CM;
                
                tempStruct.classBoundary = [num2str(cat1) ' vs. ' num2str(cat2)];
                tempStruct.accuracy = sum(diag(tempStruct.CM))/sum(sum(tempStruct.CM));
                tempStruct.dataPoints = find(currUse);
                tempStruct.actualY = tempY;
                tempStruct.predY = tempC.predY;
                
                
                %tempStruct.decision
                AM(cat1, cat2) = tempStruct.accuracy;
                AM(cat2, cat1) = tempStruct.accuracy;
                %pairwiseCell{cat1, cat2} = tempStruct;
                %pairwiseCell{cat2, cat1} = tempStruct;
                
                decInd = classTuple2Nchoose2Ind([cat1 cat2], numClasses);
                if (tempC.predY)
                    
                end
                
            end
        end
        

        C.pairwiseInfo = pairwiseCell;
        C.AM = AM;
        disp('classifyCrossValidate() Finished!')
        return
    % END PAIRWISE LDA/RF
    % START PAIRWISE SVM 
    elseif  (ip.Results.pairwise) && ... 
            strcmp( upper(ip.Results.classifier), 'SVM')
        
        for i = 1:ip.Results.nFolds

            disp(['Computing fold ' num2str(i) ' of ' num2str(ip.Results.nFolds) '...'])

            trainX = cvDataObj.trainXall{i};
            trainY = cvDataObj.trainYall{i};
            testX = cvDataObj.testXall{i};
            testY = cvDataObj.testYall{i};

            [mdl, scale] = fitModel(trainX, trainY, ip);

            [predictions decision_values] = modelPredict(testX, mdl, scale);

            labelsConcat = [labelsConcat testY];
            predictionsConcat = [predictionsConcat predictions];
            modelsConcat{i} = mdl; 

            if (ip.Results.pairwise) 
                if strcmp(upper(ip.Results.classifier), 'SVM')
                    [pairwiseAccuracies, pairwiseMat3D, pairwiseCell] = ...
                        decValues2PairwiseAcc(pairwiseMat3D, testY, mdl.Label, decision_values, pairwiseCell);
                end
            end
        end
        
        %convert pairwiseMat3D to diagonal matrix
        
        C.pairwiseInfo = pairwiseCell;
        C.AM = pairwiseAccuracies;
        disp('classifyCrossValidate() Finished!')
        return;
       
    % END PAIRWISE SVM
    else % NORMAL SVM/LDA/RF
        tic
        for i = 1:ip.Results.nFolds

            disp(['Computing fold ' num2str(i) ' of ' num2str(ip.Results.nFolds) '...'])

            trainX = cvDataObj.trainXall{i};
            trainY = cvDataObj.trainYall{i};
            testX = cvDataObj.testXall{i};
            testY = cvDataObj.testYall{i};

            [mdl, scale] = fitModel(trainX, trainY, ip);

            [predictions decision_values] = modelPredict(testX, mdl, scale);

            labelsConcat = [labelsConcat testY'];
            predictionsConcat = [predictionsConcat predictions];
            modelsConcat{i} = mdl; 

            C.CM = confusionmat(labelsConcat, predictionsConcat);
            C.accuracy = computeAccuracy(labelsConcat, predictionsConcat); 
            
        end
        toc
        % END NORMAL SVM/LDA/RF
        
    end

%{
    % unshuffle predictions vector to return to user IF shuffle is on
    predY = NaN;
    if (ip.Results.shuffleData == 1)
        predY = NaN(1, r);
        for i = 1:r
            predY(shuffledInd(i)) = predictionsConcat(i);
        end
    else
        predY = predictionsConcat;
    end
%}

%     pVal = permTestPVal(C.accuracy, accDist);


    C.modelsConcat = modelsConcat;
    C.predY = predictionsConcat;
    C.classifierInfo = classifierInfo;
    disp('classifyCrossValidate() Finished!')
    
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
    
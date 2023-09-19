function C = crossValidatePairs_opt(obj, X, Y, varargin)
% -------------------------------------------------------------------------
% RSA = MatClassRSA
% C = RSA.Classification.crossValidatePairs_opt(X, Y, varargin)
% -------------------------------------------------------------------------
% Bernard - Jun. 23, 2020
%
% Given a data matrix X and labels vector Y, this function will split the 
% into pairs of classes, optimize the classifer hyperparameters, then 
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
%       true (default): Conduct PCA within each CV fold.
%       false: One PCA for entire training data matrix X.
%   'nFolds' - Number of folds in cross validation.  Must be integer
%       greater than 1 and less than or equal to the number of trials. 
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
%   permAccMat - Permutation testing accuracies.  This field will be NaN if 
%       permuatation testing is not specfied.  The first two dimensions
%       represent pairwise classes, while the third dimension represent 
%       permutation.
%   classificationInfo - This struct contains the specifications used
%       during classification, including 'PCA', 'PCAinFold', 'nFolds', 
%       'classifier' and 'dataPartitionObj'
%   dataPartitionObj - This struct contains the train/test data partitions 
%       for cross validation (and a dev data partition if hyperparameter 
%       optimization is specified).

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

    cvPairsOpt_time = tic;

    %%%%% PARSE INPUT DATA %%%%%
    st = dbstack;
    namestr = st.name;
    ip = inputParser;
    ip = initInputParser(namestr, ip, X, Y);
    
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
   
   %%%%% SUBSET DATA MATRICES %%%%%
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
    
    
    %%%%% SET RANDOM SEED %%%%%
    % for Random forest purposes
    %rng(ip.Results.rngType);
    setUserSpecifiedRng(ip.Results.rngType);

    
    %%%%% PCA, CENTERING, SCALING and CV DATA PARTITIONING %%%%% 
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
        warning(['Data centering must be turned on if performing PCA. Overriding '...
        'user input and removing the mean from each data feature.']);
        ipCenter = true;
    end
    
    if (ip.Results.PCA > 0 || strcmp(ip.Results.optimization, 'nestedCV'))
        disp('No development set needed, setting trainDevSplit to [1 0]');
    	trainDevSplit = [1 0];
    else
        trainDevSplit = ip.Results.trainDevSplit;
    end
    
    partition = trainDevTestPart(X, ip.Results.nFolds, trainDevSplit);
    cvDataObj = cvData(X,Y, partition, ip, ipCenter, ipScale);
    
    
    %%%%% CROSS VALIDATION %%%%%
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
    % classification information
    pairwiseCell = initPairwiseCellMat(numClasses);
    C = struct();
    modelsConcat = cell(ip.Results.nFolds, numDecBounds);
    
    CM = NaN;
   
    % PAIRWISE SVM w/ PCA
    if (strcmp(upper(ip.Results.classifier), 'SVM') && ip.Results.PCA >0)
    
        decision_values = NaN(length(Y), numDecBounds);
        AM = NaN(numClasses, numClasses);
    
        % partition data into pairs
        for class1 = 1:numClasses-1
            for class2 = (class1+1):numClasses
                disp([num2str(class1) ' vs ' num2str(class2)]) 
                useTrials = ismember(Y, [class1 class2]);
      
                tempX = X(useTrials, :);
                tempY = Y(useTrials);
                tempStruct = struct();
                % Store the accuracy in the accMatrix
                [~, tempC] = evalc([' obj.crossValidateMulti_opt(' ...
                        '   tempX, tempY, ' ...
                        ' ''classifier'', ip.Results.classifier, ' ...
                        ' ''rngType'', ''default'', ' ...
                        ' ''PCAinFold'', ip.Results.PCAinFold, '...
                        ' ''optimization'', ip.Results.optimization, ' ...
                        ' ''nFolds'', ip.Results.nFolds, ' ...
                        ' ''center'', ip.Results.center, ' ...
                        ' ''scale'', ip.Results.scale, ' ...
                        ' ''cSpace'', ip.Results.cSpace, ' ...
                        ' ''gammaSpace'', ip.Results.gammaSpace, ' ...
                        ' ''trainDevSplit'', ip.Results.trainDevSplit)' ]);
                tempStruct.CM = tempC.CM;
                
                tempStruct.classBoundary = [num2str(class1) ' vs. ' num2str(class2)];
                tempStruct.accuracy = tempC.accuracy;
%                 tempStruct.dataPoints = find(useTrials);
                tempStruct.actualY = tempY;
                tempStruct.predY = tempC.predY;
                
                %tempStruct.decision
                AM(class1, class2) = tempStruct.accuracy;
                AM(class2, class1) = tempStruct.accuracy;
                modelsConcat(:, classTuple2Nchoose2Ind([class1, class2], 6)) = ...
                    tempC.modelsConcat';
                pairwiseCell{class1, class2} = tempStruct;
                pairwiseCell{class2, class1} = tempStruct;
                
                decInd = classTuple2Nchoose2Ind([class1 class2], numClasses);
                
            end
        end

        C.pairwiseInfo = pairwiseCell;
        C.AM = AM;
        C.modelsConcat = modelsConcat;
        C.classificationInfo = tempStruct;
        
        disp('classifyCrossValidate_opt() Finished!')
        
        %Permutation Testing
        if ( ip.Results.permutations>0 ) 
            permAccMat = nan(numClasses, numClasses, ip.Results.permutations);
            pValMat = nan(numClasses, numClasses);
            classPairs = nchoosek(1:numClasses, 2);

            disp('Conducting permutation testing...');
            for k = 1:numDecBounds
                class1 = classPairs(k, 1);
                class2 = classPairs(k, 2);
                disp([num2str(class1) ' vs ' num2str(class2)]) 

                for i = 1:ip.Results.permutations
                
                    useTrials = ismember(Y, [class1 class2]);

                    tempX = X(useTrials, :);
                    tempY = Y(useTrials);
                    pTempY = Y(randperm(length(Y)), :); % permuate Y labels
                    [~, tempC] = evalc([' obj.crossValidateMulti_opt(' ...
                        ' tempX, pTempY, ' ...
                        ' ''classifier'', ip.Results.classifier, ' ...
                        ' ''rngType'', ''default'', ' ...
                        ' ''PCAinFold'', ip.Results.PCAinFold, '...
                        ' ''optimization'', ip.Results.optimization, ' ...
                        ' ''nFolds'', ip.Results.nFolds, ' ...
                        ' ''center'', ip.Results.center, ' ...
                        ' ''scale'', ip.Results.scale, ' ...
                        ' ''cSpace'', ip.Results.cSpace, ' ...
                        ' ''gammaSpace'', ip.Results.gammaSpace, ' ...
                        ' ''trainDevSplit'', ip.Results.trainDevSplit)' ]);
                    permAccMat(class1, class2, i) = tempC.accuracy;
                    permAccMat(class2, class1, i) = tempC.accuracy;

                end
                pValMat(class1, class2) = permTestPVal(AM(class1, class2), ...
                    squeeze(permAccMat(class1, class2, :)));
                pValMat(class2, class1) = pValMat(class1, class2);
            end
            C.pValMat = pValMat;
        end        
        
    % END PAIRWISE SVM w/ PCA
    % START PAIRWISE SVM w/o PCA
    elseif  strcmp( upper(ip.Results.classifier), 'SVM') && (ip.Results.PCA <= 0)
        
        for i = 1:ip.Results.nFolds

            disp(['Computing fold ' num2str(i) ' of ' num2str(ip.Results.nFolds) '...'])

            trainX = cvDataObj.trainXall{i};
            trainY = cvDataObj.trainYall{i};
            testX = cvDataObj.testXall{i};
            testY = cvDataObj.testYall{i};
%             
%              % conduct grid search here
%              if (strcmp(ip.Results.optimization, 'nestedCV'))
%                 [gamma_opt, C_opt] = nestedCvGridSearch(cvDataObj, ip);
%              elseif (strcmp(ip.Results.optimization, 'singleFold'))
%                 devX = cvDataObj.devXall{i};
%                 devY = cvDataObj.devYall{i};
%                 [gamma_opt, C_opt] = trainDevGridSearch(trainX, trainY, ...
%                     devX, devY, ip);
%              end
% 
%             [mdl, scale] = fitModel(trainX, trainY, ip, gamma_opt, C_opt);
% 
%             [predictions decision_values] = modelPredict(testX, mdl, scale);
% 
%             labelsConcat = [labelsConcat testY];
%             predictionsConcat = [predictionsConcat predictions];
%             modelsConcat{i} = mdl; 
% 
%             if strcmp(upper(ip.Results.classifier), 'SVM')
%                 [pairwiseAccuracies, pairwiseMat3D, pairwiseCell] = ...
%                     decValues2PairwiseAcc(pairwiseMat3D, testY, mdl.Label, decision_values, pairwiseCell);
%             end
%             
            [~, tempC] = evalc([' obj.crossValidateMulti_opt(' ...
                        ' trainX, pTempY, ' ...
                        ' ''classifier'', ip.Results.classifier, ' ...
                        ' ''rngType'', ''default'', ' ...
                        ' ''PCAinFold'', ip.Results.PCAinFold, '...
                        ' ''optimization'', ip.Results.optimization, ' ...
                        ' ''nFolds'', ip.Results.nFolds, ' ...
                        ' ''center'', ip.Results.center, ' ...
                        ' ''scale'', ip.Results.scale, ' ...
                        ' ''cSpace'', ip.Results.cSpace, ' ...
                        ' ''gammaSpace'', ip.Results.gammaSpace, ' ...
                        ' ''trainDevSplit'', ip.Results.trainDevSplit)' ]);
        end
        
        %convert pairwiseMat3D to diagonal matrix
        C.pairwiseInfo = pairwiseCell;
        C.AM = pairwiseAccuracies;
        
        %Permutation Testing
        if ip.Results.permutations > 0
            
            numClasses = length(unique(Y));
            permAccMat = zeros(numClasses, numClasses, ip.Results.permutations);
            pValMat = nan(numClasses, numClasses);
            classPairs = nchoosek(1:numClasses, 2);

            trainX = cvDataObj.trainXall{1};
            trainY = cvDataObj.trainYall{1};
            testX = cvDataObj.testXall{1};
            testY = cvDataObj.testYall{1};
            
            for i = 1:ip.Results.permutations

                l = length(trainY);
                pTrainY = trainY(randperm(l), :);
                 % conduct grid search here
                 if (strcmp(ip.Results.optimization, 'nestedCV'))
                    [gamma_opt, C_opt] = nestedCvGridSearch(trainX, pTrainY, cvDataObj, ip);
                 elseif (strcmp(ip.Results.optimization, 'singleFold'))
                    devX = cvDataObj.devXall{1};
                    devY = cvDataObj.devYall{1};
                    trainDevY = [trainY; devY];
                    pTrainDevY = trainDevY(randperm(length(trainDevY)), :);
                    pTrainY = pTrainDevY(1:length(trainY));
                    pDevY = pTrainDevY(length(trainY)+1:end);

                    [gamma_opt, C_opt] = trainDevGridSearch(trainX, pTrainY, ...
                        devX, pDevY, ip);
                 end
                [pMdl, scale] = fitModel(trainX, pTrainY, ip, gamma_opt, C_opt);

                [predictions decision_values] = modelPredict(testX, pMdl, scale);

                if strcmp(upper(ip.Results.classifier), 'SVM')
                    [pairwiseAccuracies, pairwiseMat3D, pairwiseCell] = ...
                        decValues2PairwiseAcc(pairwiseMat3D, testY, pMdl.Label, decision_values, pairwiseCell);
                end
                permAccMat(:,:,i) = pairwiseAccuracies;
                
            end
            
            for k = 1:numDecBounds
            
                % class1 class2
                class1 = classPairs(k, 1);
                class2 = classPairs(k, 2);
                pValMat(class1, class2) = permTestPVal(C.AM(class1, class2), ...
                        permAccMat(class1, class2, :));
                pValMat(class2, class1)  = pValMat(class1, class2);
                
            end
                
        end

        C.pValMat = pValMat;
        C.permAccMat = permAccMat;
        
    end
    
    C.modelsConcat = modelsConcat;
%     C.predY = predictionsConcat;
    C.classificationInfo = classifierInfo;
    C.elapsedTime = toc(cvPairsOpt_time);
    
    disp(['Elapsed time: ' num2str(C.elapsedTime) 'seconds'])
    disp('crossValidatePairs_opt() Finished!')
    
 end
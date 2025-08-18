 function C = crossValidatePairs(X, Y, varargin)
% -------------------------------------------------------------------------
% C = Classification.crossValidatePairs(X, Y, varargin)
% -------------------------------------------------------------------------
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
%   'PCAinFold' - This controls whether or not PCA is conducted in each
%       fold duration cross validation, or if PCA is conducted once on the 
%       entire dataset prior to partitioning data for cross validation.
%       --options--
%       true (default): Conduct PCA within each CV fold.
%       false: One PCA for entire training data matrix X.
%   'nFolds' - Number of folds in cross validation.  Must be integer
%       greater than 1 and less than or equal to the number of trials. 
%       Default is 10.
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
%   C -  A struct with the following subfields:
%       pairwiseInfo - a cell matrix of structs, symmetrical along the
%                      diagonal. Each struct contains the following
%                      subfields, for each class boundary:
%              CM - Confusion matrix that summarizes the performance of the
%                   classification, in which rows represent actual labels and columns
%                   represent predicted labels.  Element i,j represents the number of 
%                   observations belonging to class i that the classifier labeled as
%                   belonging to class j.
%              classBoundary - (i.e.) class 1 vs class 4
%              accuracy - classification accuracy for the given class
%                         boundary
%              actualLabels - actual class labels
%              predictions - prediced class labels by the trained model
%       AM - Accuracy matrix where each off-diagonal element shows the accuracy 
%           for distinguishing one class from another,
%           with a NaN diagonal, comparing a class with itself
%       pValMat - If permutation testing is specified, a matrix containing
%               the computed percentile value of the found value among the
%               permutation test values.
%       elapsedTime - Time to finish function call.
%       modelsConcat - Struct containing the N models used during cross
%                      validation.
%       permAccMat - Permutation testing accuracies.  This field will be NaN if 
%               permuatation testing is not specfied.  The first two dimensions
%               represent pairwise classes, while the third dimension represent 
%               permutation. 
%       classificationInfo - This struct contains the specifications used
%               during classification, including 'PCA', 'PCAinFold', 'nFolds', 
%               'classifier' and 'dataPartitionObj'
%       dataPartitionObj - This struct contains the train/test data partitions 
%               for cross validation (and a dev data partition if hyperparameter 
%               optimization is specified).
%       avgAccuracy - Average classifcation accuracy across all class
%               boundaries
%
% % MatClassRSA dependencies (all +Utils): initInputParser(),
%   subsetTrainTestMatrices(), setUserSpecifiedRng(), 
%   initPairwiseCellMat(), trainDevTestPart(), cvData(),  
%   fitModel(), modelPredict(), computeAccuracy(), permTestPVal(),
%   pValMat()

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

    cvPairs_time = tic;

    % Initialize the input parser
    st = dbstack;
    namestr = st.name;
    ip = inputParser;
    ip = Utils.initInputParser(namestr, ip, X, Y, varargin{:});
    
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
    %rng(ip.Results.rngType);
    Utils.setUserSpecifiedRng(ip.Results.rngType);

    % CROSS VALIDATION
    disp('Cross Validating')
        
    predictionsConcat = [];
    labelsConcat = [];
       
    allClasses = unique(Y);
    allClassesIndx = 1:length(allClasses);
    numClasses = length(allClasses);
    numDecBounds = nchoosek(numClasses ,2);
    classPairs = nchoosek(1:numClasses, 2);
    classPairsIndx = allClassesIndx(classPairs(:,:));

    
    classPairs = allClasses(classPairs(:,:));
    
    pairwiseMat3D = zeros(2,2, numDecBounds);
    % initialize the diagonal cell matrix of structs containing pairwise
    % classification infomration
    pairwiseCell = Utils.initPairwiseCellMat(numClasses);
    C = struct();
    modelsConcat = cell(ip.Results.nFolds, numDecBounds);
    
    % Moving centering and scaling parameters out of ip, in case we need to
    % override the user's centering specification
    ipCenter = ip.Results.center; 
    ipScale = ip.Results.scale;

    CM = NaN;
    
    %%%%% Data Partitioning, PCA, Centering and Scaling %%%%%
    if (ip.Results.PCA > 0 && ip.Results.PCAinFold <= 0)
        disp('Principal component analysis turned on, to be conducted outside of cross validation folds');
    elseif (ip.Results.PCA > 0 && ip.Results.PCAinFold > 0)
        disp('Principal component analysis turned on, to be conducted inside of cross validation folds');
    else
        disp('Prinical component analysis turned off');
    end
    
    
   
    % PAIRWISE LDA/RF
    if (strcmp(upper(ip.Results.classifier), 'LDA') || ...
        strcmp(upper(ip.Results.classifier), 'RF') || ...
        strcmp(upper(ip.Results.classifier), 'SVM') && ip.Results.PCA > 0)
   

        if ((~ip.Results.center) && (ip.Results.PCA>0) ) 
            warning(['Data centering must be on if performing PCA. Overriding '...
            'user input and removing the mean from each data feature.']);
            ipCenter = true;
        end

        AM = NaN(numClasses, numClasses);
        predictionsCell = cell(numClasses);
        actualLabelsCell = cell(numClasses);
        cvDataObj = cell(numDecBounds); % there will be numDecBounds of PCAs
        
        % Iterate through all pairs of classes
        for k = 1:numDecBounds
            
            % class1 class2
            class1 = classPairs(k, 1);
            class2 = classPairs(k, 2);
            class1Indx = classPairsIndx(k, 1);
            class2Indx = classPairsIndx(k, 2);
            
            % store indices of the trials of the current class pair of
            % interest
            currIndx = ismember(Y, [class1 class2]);
            currX = X(currIndx, :);
            currY = Y(currIndx);

            % partition data for cross validation 
            trainTestSplit = [1-1/ip.Results.nFolds 0 1/ip.Results.nFolds];
            partition = Utils.trainDevTestPart(currX, ip.Results.nFolds, trainTestSplit);
            
            % This line handles PCA either in or out of folds
            cvDataObj{k} = Utils.cvData(currX, currY, partition, ip, ipCenter, ipScale);

            disp(['Conducting cross validation on classes ' num2str(class1) ' and ' num2str(class2)]);

            for i = 1:ip.Results.nFolds
                                
                % do PCA in folds
                trainX = cvDataObj{k}.trainXall{i};
                trainY = cvDataObj{k}.trainYall{i};
                testX = cvDataObj{k}.testXall{i};
                testY = cvDataObj{k}.testYall{i};

                [mdl, scale] = Utils.fitModel(trainX, trainY, ip, ip.Results.gamma, ip.Results.C);

                [predictions decision_values] = Utils.modelPredict(testX, mdl, scale);

                actualLabelsCell{class1Indx, class2Indx} = [actualLabelsCell{class1Indx, class2Indx} testY'];
                predictionsCell{class1Indx, class2Indx} = [predictionsCell{class1Indx, class2Indx} predictions];
                
                modelsConcat{i} = mdl; 
                
            end

        end
        
        numUnique = nchoosek(numClasses, 2);
        Acc = zeros(numUnique, 1);
        index = 1;
        
        for class1 = 1:numClasses-1
            for class2 = (class1+1):numClasses
                actualLabels = actualLabelsCell{class1, class2};
                predictions = predictionsCell{class1, class2};
                Accuracy = Utils.computeAccuracy(actualLabels, predictions);
                
                Acc(index) = Accuracy;
                index = index + 1;
                
                AM(class1, class2) = Accuracy;
                AM(class2, class1) = Accuracy;
                pairwiseCell{class1, class2}.CM = confusionmat(actualLabels, predictions);
                pairwiseCell{class2, class1}.CM = pairwiseCell{class1, class2}.CM;
                pairwiseCell{class1, class2}.actualLabels = actualLabels;
                pairwiseCell{class1, class2}.predictions = predictions;
                pairwiseCell{class2, class1}.actualLabels = actualLabels;
                pairwiseCell{class2, class1}.predictions = predictions;
                pairwiseCell{class2, class1}.accuracy = Accuracy;
                pairwiseCell{class1, class2}.accuracy = Accuracy;
            end
        end

        C.pairwiseInfo = pairwiseCell;
        C.AM = AM;
        
 
        avgAccuracy = mean(Acc);
        C.avgAccuracy = avgAccuracy;
        
        % Permutation testing
        numClasses = length(unique(Y));
        permAccMat = nan(numClasses, numClasses, ip.Results.permutations);
        pValMat = nan(numClasses, numClasses);
        if ip.Results.permutations > 0
        
            for k = 1:numDecBounds
                                                    
                trainX = cvDataObj{k}.trainXall{1};
                trainY = cvDataObj{k}.trainYall{1};
                testX = cvDataObj{k}.testXall{1};
                testY = cvDataObj{k}.testYall{1};
                
                % class1 class2
                class1 = classPairs(k, 1);
                class2 = classPairs(k, 2);
                class1Indx = classPairsIndx(k, 1);
                class2Indx = classPairsIndx(k, 2);

                for i = 1:ip.Results.permutations
                
                    l = length(trainY);
                    pY = trainY(randperm(l), :);
                    evalc(['pM = Classification.trainMulti(trainX, pY,'  ...
                        ' ''classifier'', ip.Results.classifier,' ...
                        ' ''PCA'', 0,' ...
                        ' ''C'', ip.Results.C, ''gamma'', ip.Results.gamma,' ...
                        ' ''kernel'', ip.Results.kernel, ''numTrees'', ip.Results.numTrees,' ...
                        ' ''minLeafSize'', ip.Results.minLeafSize);']);

                    evalc(['pC = Classification.predict(pM, testX, ''actualLabels'',testY)']);
                    permAccMat(class1Indx, class2Indx, i) = pC.accuracy;
                    permAccMat(class2Indx, class1Indx, i) = pC.accuracy;

                end
                
                pValMat(class1Indx, class2Indx) = Utils.permTestPVal(AM(class1Indx, class2Indx), ...
                    squeeze(permAccMat(class1Indx, class2Indx, :)));
                pValMat(class2Indx, class1Indx) = Utils.pValMat(class1Indx, class2Indx);
                
            end
        end
        C.pValMat = pValMat;
        C.permAccMat = permAccMat;
    end
    
    classifierInfo = struct(...
                        'PCA', ip.Results.PCA, ...
                        'PCAinFold', ip.Results.PCAinFold, ...
                        'nFolds', ip.Results.nFolds, ...
                        'dataPartitionObj', cvDataObj, ...
                        'classifier', ip.Results.classifier);
                    
    C.classificationInfo = classifierInfo(1);
    
	C.modelsConcat = modelsConcat;
   
    C.elapsedTime = toc(cvPairs_time);
   
    disp(['Elapsed time: ' num2str(C.elapsedTime) 'seconds'])
    disp('crossValidatePairs() Finished!')
    
 end

function C = crossValidateMulti(X, Y, varargin)
% -------------------------------------------------------------------------
% RSA = MatClassRSA;
% C = RSA.Classification.crossValidateMulti(X, Y, varargin)
% -------------------------------------------------------------------------
%
% Given a data matrix X and labels vector Y, this function will conduct 
% multiclass cross validation, then output a struct containing the 
% classification accuracy, confusion matrix, and other related information.  
% Optional name-value parameters can be passed in to specify classification 
% related options.  
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
%       argument should be passed in as a vector of indices that indicate 
%       the time dimension indices that the user wants to subset.  This 
%       arugument will not do anything if input matrix X is a 2D, 
%       trial-by-feature matrix.
%   'spaceUse' - If X is a 3D, space-by-time-by-trial matrix, then this
%       option will subset X along the space dimension.  The input
%       argument should be passed in as a vector of indices that indicate 
%       the space dimension indices that the user wants to subset.  This 
%       argument will not do anything if input matrix X is a 2D, 
%       trial-by-feature matrix.
%   'featureUse' - If X is a 2D, trial-by-feature matrix, then this
%       option will subset X along the features dimension.  The input
%       argument should be passed in as a vector of indices that indicate 
%       the feature dimension indices that the user wants to subset.  This 
%       arugument will not do anything if input matrix X is a 3D,
%       space-by-time-by-trial matrix.
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
%       true : Conduct PCA within each fold.
%       false (default): One PCA for entire training data matrix X.
%   'nFolds' - Number of folds in cross validation.  Must be integer
%       greater than 1 and less than or equal to the number of trials. 
%       Default is 10.
%   'classifier' - Choose classifier for cross validation.  Supported
%       classifier include support vector machine (SVM), linear discriminant 
%       analysis (LDA) and random forest (RF).  For SVM, the user must 
%       manually specify hyperparameter “C” (linear, rbf kernels) and 
%       “gamma” (rbf kernel). Use the crossValidateMulti_opt function to
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
%   'permutations' - This chooses the number of permutations to perform for
%       permutation testing. If this value is set to 0, then permutation
%       testing will be turned off.  If it is set to an integer n greater 
%       than 0, then classification will be performed over n permutation 
%       iterations. Default value is 0 (off). 
%       -- implementation notes --
%       This function repeats the following steps for each permutation:
%           - select the first fold of training, test data (permutation 
%               testing will run only on this fold)
%           - permute the training labels
%           - train classifier on training data (with permuted labels)
%           - use the classifier to predict test data labels
%           - store the classification accuracy of this permutation
%   'center' - This variable controls data centering, also known as 
%       mean centering.  Setting this to 'true' will set the
%       mean along the feature dimension to be 0.  Setting to 'false' turns it 
%       off. If PCA is performed, data centering is required; if the user
%       selects a PCA calculation but 'center' is off, the function
%       will issue a warning and turn centering on.
%        --options--
%        false - centering turned off
%        true (default) - centering turned on 
%   'scale' - This variable controls data scaling, also known as data
%       normalization.  Setting this to a true scales each 
%       feature to have unit variance prior to PCA.  Setting 
%       it to 'false' turns off data scaling.  
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
%   information, including classification accuracy, confucion matrix,  
%   prediction results etc.
%   --subfields--
%   CM - Confusion matrix that summarizes the performance of the
%       classification, in which rows represent actual labels and columns
%       represent predicted labels.  Element i,j represents the number of 
%       observations belonging to class i that the classifier labeled as
%       belonging to class j.
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
%   checkInputDataShape(), verifySVMParameters(),
%   subsetTrainTestMatrices(), setUserSpecifiedRng(),
%   processTrainDevTestSPilt(), trainDevTestPart(), cvData(), fitModel()

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

    cvMulti_time = tic;
    
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

    % Parse Inputs
    parse(ip, X, Y, varargin{:});
    
    % If SVM is selected, then gamma and C parameters must be manually set
    Utils.verifySVMParameters(ip);
   
   % check if data is double, convert to double if it isn't
   [X, Y] = Utils.convert2double(X,Y);
   
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
    if (strcmp(ip.Results.center, 'off') && (ip.Results.PCA>0) ) 
        warning(['Data centering must be on if performing PCA. Overriding '...
        'user input and removing the mean from each data feature.']);
        ipCenter = 'on';
    end
    % partition data for cross validation 
    trainTestSplit = [1-1/ip.Results.nFolds 0 1/ip.Results.nFolds];
    partition = Utils.trainDevTestPart(X, ip.Results.nFolds, trainTestSplit); 
    [cvDataObj,V,nPCs] = Utils.cvData(X,Y, partition, ip, ipCenter, ipScale);

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
    CM = NaN;
   

    tic
    for i = 1:ip.Results.nFolds

        disp(['Computing fold ' num2str(i) ' of ' num2str(ip.Results.nFolds) '...'])

        trainX = cvDataObj.trainXall{i};
        trainY = cvDataObj.trainYall{i};
        testX = cvDataObj.testXall{i};
        testY = cvDataObj.testYall{i};

        [mdl, scale] = Utils.fitModel(trainX, trainY, ip, ip.Results.gamma, ip.Results.C);

        [predictions decision_values] = Utils.modelPredict(testX, mdl, scale);

        labelsConcat = [labelsConcat testY'];
        predictionsConcat = [predictionsConcat predictions];
        modelsConcat{i} = mdl;  

    end
    toc

    C.CM = confusionmat(labelsConcat, predictionsConcat); 
    C.accuracy = Utils.computeAccuracy(labelsConcat, predictionsConcat);
    % Initilize info struct for return
    classificationInfo = struct(...
                        'PCA', ip.Results.PCA, ...
                        'PCAinFold', ip.Results.PCAinFold, ...
                        'nFolds', ip.Results.nFolds, ...
                        'classifier', ip.Results.classifier, ...
                        'nPCs', nPCs, ...
                        'dataPartitionObj', cvDataObj ...
                        );

    C.classificationInfo = classificationInfo;
    C.modelsConcat = modelsConcat;
    C.predY = predictionsConcat;
    
    
    
    %PERMUTATION TEST (assigning)
    tic    
    if ip.Results.permutations > 0
        
        disp('Conducting permutation tests');

        % create variable to store permutation testing accuracies
        accArr = NaN(ip.Results.permutations, 1);
        
        for i = 1:ip.Results.permutations
            disp(['  ' num2str(i) ' of ' num2str(ip.Results.permutations)]);

            
            % get data from single fold for permutation testing
            permTestTrainX = cvDataObj.trainXall{1};
            permTestTrainY = cvDataObj.trainYall{1};
            permTestTestX = cvDataObj.testXall{1};
            permTestTestY = cvDataObj.testYall{1};

            % permute training labels
            permTestTrainY = permTestTrainY(randperm(length(permTestTrainY)), :);
            
            % Train permutation model and predict test data
            evalc(['permTestM = Classification.trainMulti(' ...
                ' permTestTrainX, permTestTrainY, '...
                ' ''classifier'', ip.Results.classifier, ' ...
                ' ''PCA'', 0, ''scale'', false, ' ...
                ' ''rngType'', ip.Results.rngType, ' ...
                ' ''gamma'', ip.Results.gamma, ''C'', ip.Results.C, ' ...
                ' ''kernel'', ip.Results.kernel, ' ...
                ' ''minLeafSize'', ip.Results.minLeafSize, ' ...
                ' ''numTrees'', ip.Results.numTrees)' ]);

            evalc(['permTestOutput = Classification.predict(permTestM, '...
                'permTestTestX, ''actualLabels'', permTestTestY);' ]);
            accArr(i) = permTestOutput.accuracy;
        end
        C.pVal = Utils.permTestPVal(C.accuracy, accArr);
        C.permAccs = accArr;
    else
        C.pVal = NaN;
        C.permAccs = NaN;
    end
    
    C.elapsedTime = toc(cvMulti_time);
    disp('crossValidateMulti() Finished!')
    disp(['Elapsed time: ' num2str(C.elapsedTime) ' seconds'])

    
 end
    
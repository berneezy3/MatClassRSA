 function M = trainPairs(obj, X, Y, varargin)
% -------------------------------------------------------------------------
% RSA = MatClassRSA;
% M = RSA.classify.trainPairs(X, Y, varargin)
% P = RSA.classify.predict(M, X, Y)
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

    st = dbstack;
    namestr = st.name;
    ip = inputParser;
    %Required inputs
    ip = initInputParser(namestr, ip);
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
   [X, Y] = convert2double(X, Y);
   
   % If SVM is selected, then gamma and C parameters must be manually set
   verifySVMParameters(ip);

   
   [X, nSpace, nTime, nTrials] = subsetTrainTestMatrices(X, ...
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
    numClasses = length(unique(Y));
    numDecBounds = nchoosek(numClasses ,2);
    classPairs = nchoosek(1:numClasses, 2);
    pairwiseMat3D = zeros(2,2, numDecBounds);
    % initialize the diagonal cell matrix of structs containing pairwise
    % classification infomration
    pairwiseCell = initPairwiseCellMat(numClasses);
    
    numClasses = length(unique(Y));
    numDecBounds = nchoosek(numClasses, 2);
    M = struct();
    RSA = MatClassRSA;

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
        M.scale = {};
        M.trainData = X;
        M.trainLabels = Y;
        M.functionName = namestr;
        M.pairwise = 1;
        M.ip = ip;
        
        disp('training model for classes: ')

        % Iterate through all combintaions of labels
        for k = 1:numDecBounds
            
            % class1 class2
            class1 = classPairs(k, 1);
            class2 = classPairs(k, 2);

            disp([num2str(class1) ' vs ' num2str(class2)]); 
            currUse = ismember(Y, [class1 class2]);

            tempX = X(currUse, :);
%             tempX_PCA = getPCs(tempX, ip.Results.PCA);
            tempY = Y(currUse);
            
            % partition data for cross validation 
            partition = trainDevTestPart(tempX, 1, [1 0]); 
            cvDataObj = cvData(tempX, tempY, partition, ip, ...
                ip.Results.center, ip.Results.scale, 1);
            tempX_PCA = cvDataObj.trainXall{1};

            % Store the accuracy in the accMatrix
            [~, tempM] = evalc([' RSA.Classification.trainMulti(tempX_PCA, tempY, ' ...
                ' ''classifier'', ip.Results.classifier, ''PCA'', 0, '...
                ' ''kernel'', ip.Results.kernel,'...
                ' ''gamma'', ip.Results.gamma, ' ...
                ' ''C'', ip.Results.C, ' ... 
                ' ''numTrees'', ip.Results.numTrees, ' ...
                ' ''minLeafSize'', ip.Results.minLeafSize, '...
                ' ''center'', ip.Results.center, ' ...
                ' ''scale'', ip.Results.scale, ' ...
                ' ''randomSeed'', ''default'' ) ' ]);
            tempM.classifierInfo.numClasses = numClasses;
            
            M.cvDataObj{k} = cvDataObj;
            M.classifierInfo{k} =  tempM.classifierInfo;
            M.mdl{k} = tempM.mdl;
            M.scale{k} = tempM.scale;
        end
    % END PAIRWISE LDA/RF
    % START SVM skipping the pairwise split to decrease runtime
    elseif  strcmp( upper(ip.Results.classifier), 'SVM') && (ip.Results.PCA <= 0)
        
         X_PCA = getPCs(X, ip.Results.PCA);
        
        [mdl, scale] = fitModel(X, Y, ip, ip.Results.gamma, ip.Results.C);

        [~, tempM] = evalc([' RSA.Classification.trainMulti(X_PCA, Y, ' ...
            ' ''classifier'', ip.Results.classifier, ''PCA'', ip.Results.PCA, '...
            ' ''kernel'', ip.Results.kernel,'...
            ' ''gamma'', ip.Results.gamma, ' ...
            ' ''C'', ip.Results.C, ' ... 
            ' ''numTrees'', ip.Results.numTrees, ' ...
            ' ''minLeafSize'', ip.Results.minLeafSize, '...
            ' ''center'', ip.Results.center, ' ...
            ' ''scale'', ip.Results.scale, ' ...
            ' ''randomSeed'', ''default'' ) ' ]);
        
        tempM.classifierInfo.pairwise = 1;
        M = tempM;
        
        M.pairwise = 1;
        M.classifier = ip.Results.classifier;

    end
 end

 
 
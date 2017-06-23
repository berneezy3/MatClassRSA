function [CM, accuracy, classifierInfo] = classifyEEG(X, Y, varargin)
% [CM, accuracy, classifierInfo] = classifyEEG(X, Y, shuffleData)
% -------------------------------------------------------------
% Blair/Bernard - Feb. 22, 2017
%
% The main function for sorting user inputs and calling classifier.
%
% INPUT ARGS (REQUIRED)
%   X - training data
%   Y - labels
%
% INPUT ARGS (OPTIONAL NAME-VALUE PAIRS)
%   normalize - method to normalize rows of X, 
%       --options--
%       'diagonal'
%       'sum'
%       'none'
%   shuffleData - 1 to shuffle trainig data along with labels (default), or
%       --options--
%       1 - shuffle
%       0 - do not shuffle
%   averageTrials - how to compute averaging of trials in X to increase accuracy
%       --options--
%       (negative value) - don't average
%       (postitive int) - number of integers to average over
%   permutationTest - TODO
%       --options--
%       TODO
%   PCA - Principle Component analysis on data matrix X. Default is to
%       keep components that explan 90% of the variance. To retrieve
%       components that explain a certain variance, enter the variance as a
%       decimal <1 and >0.  To retrieve a certain number of most
%       significant features, enter an integer >1.
%   PCAinFold - whether or not to conduct PCA in each fold
%       --options--
%       1 (default) - PCA within each fold
%       0 - one PCA for entire training data matrix X
%   nFolds - number of folds in cross validation.  Must be integer
%       greater than 1
%   classify - parameter to select classifier. 
%        --options--
%       'SVM' (default)
%       'LDA' 
%       'RandomForest'
%   classifyOptionStruct - Option vector specific to each classifier.  
%       --options--
%       TODO
% TODO:
%   Check when the folds = 1, what we should do 

    % Initilize info struct
    classifierInfo = struct('Normalize', '', 'shuffleData', 'on', 'averageTrials', '', ...
        'permutationTest', '', 'PCA', '', 'PCAinFold', '', 'nFolds', '', 'classifier', '');

    % Initialize the input parser
    ip = inputParser;
    ip.CaseSensitive = false;

    %Specify default values
    defaultNormalize = 'diagonal';
    defaultShuffleData = 1;
    defaultAverageTrials = 10;
    defaultAverageTrialsHandleRemainder = 'discard';
    defaultPermutationTest = 0;
    defaultPCA = -1;
    defaultPCAinFold = 1;
    defaultNFolds = 10;
    defaultClassify = 'SVM';
    defaultClassifyOptionsStruct = struct([]);


    %Specify expected values
    expectedNormalize = {'diagonal', 'sum', 'none'};
    expectedShuffleData = [0, 1];
    expectedAverageTrialsHandleRemainder = {'discard','newGroup', 'append', 'distribute'};
    expectedPermutationTest = 0;
    expectedPCAinFold = [0,1];
    expectedClassify = {'SVM', 'LDA', 'RandomForest'};

    %Required inputs
    addRequired(ip, 'X', @ismatrix)
    addRequired(ip, 'Y', @isvector)
    [r c] = size(X);

    %Optional positional inputs
    %addOptional(ip, 'distpower', defaultDistpower, @isnumeric);
    if verLessThan('matlab', '8.2')
        addParamValue(ip, 'normalize', defaultNormalize,...
            @(x) any(validatestring(x, expectedNormalize)));
        addParamValue(ip, 'shuffleData', defaultShuffleData, ...
            @(x) any(validatestring(x, expectedShuffleData)));
        addParamValue(ip, 'averageTrials', defaultAverageTrials, ...
            @(x) assert(rem(x,1) == 0 ));
        addParamValue(ip, 'permutationTest', defaultPermutationTest, ...
             @(x) any(validatestring(x, expectedPermutationTest)));
        addParamValue(ip, 'PCA', defaultPCA, ...
            @(x) assert(rem(x,1) == 0 ));
        addParamValue(ip, 'PCAinFold', defaultPCAinFold);
        addParamValue(ip, 'nFolds', defaultNFolds);
        addParamValue(ip, 'classify', defaultClassify, ...
             @(x) any(validatestring(x, expectedClassify)));
        addParamValue(ip, 'classifyOptionsStruct', defaultClassifyOptionsStruct, ...
            @(x) assert(isStruct(defaultClassifyOptionsStruct)));
    else
        addParameter(ip, 'normalize', defaultNormalize,...
            @(x) any(validatestring(x, expectedNormalize)));
        addParameter(ip, 'shuffleData', defaultShuffleData, ...
            @(x) any(validatestring(x, expectedShuffleData)));
        addParameter(ip, 'averageTrials', defaultAverageTrials, ...
            @(x) assert(rem(x,1) == 0 ));
        addParameter(ip, 'averageTrialsHandleRemainder', ...
            defaultAverageTrialsHandleRemainder, ...
            @(x) assert(validatestring(x, expectedAverageTrialsHandleRemainder)));
        addParameter(ip, 'permutationTest', defaultPermutationTest, ...
             @(x) any(validatestring(x, expectedPermutationTest)));
        addParameter(ip, 'PCA', defaultPCA, ...
            @(x) assert(rem(x,1) == 0 ));
        addParameter(ip, 'PCAinFold', defaultPCAinFold);
        addParameter(ip, 'nFolds', defaultNFolds);
        addParameter(ip, 'classify', defaultClassify, ...
             @(x) any(validatestring(x, expectedClassify)));
        addParameter(ip, 'classifyOptionsStruct', defaultClassifyOptionsStruct, ...
            @(x) assert(isStruct(defaultClassifyOptionsStruct)));
    end

    %Optional name-value pairs
    %NOTE: Should use addParameter for R2013b and later.


    % Parse
    parse(ip, X, Y, varargin{:});

    % X3 = randi(12, [5 3 10]);
    % X2 = randi(12, [10 15]);
    % Y = randi(20, [10 1])';
    % X = X3;
    featureUse = []; spaceUse = []; timeUse = [];

    %%%%% INPUT DATA CHECKING (doing)
    %%% Check the input data matrix X
    if ndims(X) == 3
        [nSpace, nTime, nTrials] = size(X);
        disp(['Input data matrix size: ' num2str(nSpace) ' space x ' ...
            num2str(nTime) ' time x ' num2str(nTrials) ' trials'])
    elseif ndims(X) == 2
        [nTrials, nFeature] = size(X);
        warning(['2D input data matrix. Assuming '...
            num2str(nTrials) ' trials x ' num2str(nFeature) ' features.'])
    else
        error('Input data matrix should be 3D or 2D matrix.')
    end
    %%% Check the input labels vector Y
    if ~isvector(Y)
        error('Input labels vector must be a vector.')
    elseif length(Y) ~= nTrials
        error(['Length of input labels vector must correspond '...
            'to number of trials (' num2str(nTrials) ').'])
    end
    % Convert to column vector if needed
    if ~iscolumn(Y)
       warning('Transposing input labels vector to column.') 
       Y = Y(:);
    end

    %%%%% INPUT DATA SUBSETTING (doing)
    % Default chanUse, timeUse, featureUse = [ ]
    %%% 3D input matrix
    X_subset = X; % This will be the next output; currently 3D or 2D
    if ndims(X) == 3
        % Message about ignoring 'featureUse' input
       if ~isempty(featureUse)
           warning('Ignoring ''featureUse'' for 3D input data matrix.')
           warning('Use ''spaceUse'' and ''timeUse'' for 3D input data matrix.')
       end

       % If the user did specify a spatial or temporal subset...
       if ~isempty(spaceUse) || ~isempty(timeUse)
           % Confirm that spaceUse and timeUse are vectors
           if (~isempty(spaceUse) && ~isvector(spaceUse)) ||...
                   (~isempty(timeUse) && ~isvector(timeUse))
               error('Enter a vector to specify spatial and/or temporal subsets.')
           end

           % Confirm that spaceUse and timeUse fit dimensions of data matrix
           if ~isempty(spaceUse) && ~all(ismember(spaceUse, 1:nSpace))
               error('''spaceUse'' input is not contained in the input data matrix.')
           elseif ~isempty(timeUse) && ~all(ismember(timeUse, 1:nTime))
               error('''timeUse'' input is not contained in the input data matrix.')
           end

           % Do the subsetting
           if ~isempty(spaceUse)
               X_subset = X_subset(spaceUse, :, :);
           end
           if ~isempty(timeUse)
               X_subset = X_subset(:, timeUse, :);
           end

           % Update nSpace and nTime
           nSpace = size(X_subset, 1);
           nTime = size(X_subset, 2);
       end
       % Reshape the X_subset matrix
       %X_subset = cube2toRows(X_subset); % NOW IT'S 2D

    %%% 2D input matrix
    elseif ndims(X) == 2
        % Messages about ignoring 'spaceUse' and/or 'timeUse' inputs
        if ~isempty(spaceUse) || ~isempty(timeUse)
           if ~isempty(spaceUse)
               warning('Ignoring ''spaceUse'' for 2D input data matrix.')
           end
           if ~isempty(timeUse)
               warning('Ignoring ''timeUse'' for 2D input data matrix.')
           end
           warning('Use ''featureUse'' for 2D input data matrix.')
        end

        % If the user specified a featureUse subset...
        if ~isempty(featureUse)
            % Confirm it's a vector
            if ~isvector(featureUse)
               error('Enter a vector to specify feature subsets.') 
            end

           % Confirm that featureUse is contained in the data matrix
           if ~all(ismember(featureUse, 1:nFeature))
              error('''featureUse'' input is not contained in the input data matrix.') 
           end

           % Do the subsetting
           X_subset = X_subset(:, featureUse);  % WAS ALREADY 2D

           % Update nFeature
           nFeature = size(X_subset, 2);
        end  
    end
    X = X_subset;

    %%%%% Whatever we started with, we now have a 2D trials-by-feature matrix
    % moving forward.

    % DATA SHUFFLING (doing)
    % Default 1
    if (ip.Results.shuffleData)
        [X, Y] = shuffleData(X, Y);
    else
        classifierInfo.shuffleData = 'off';
    end


    % TRIAL AVERAGING (doing)
     if(ip.Results.averageTrials >= 1)
        [X, Y] = averageTrials(X, Y, ip.Results.averageTrials, ...
            'handleRemainder' ,ip.Results.averageTrialsHandleRemainder);
        averageTrialsInfo = 'on';
        classifierInfo.averageTrials = 'on';
     else
         warning('variable "defaultAverageTrialsHandleRemainder" not used')
     end


    % PERMUTATION TEST (assigning)
    % Default 0
    % If doPermTest
    %   (details are TODO)
    %   Get integer number of permutation iterations

    % PCA PARAMS (assigning)
    if (ip.Results.PCAinFold == 0)
        if (ip.Results.PCA >0)
            X = getPCs(X, ip.Results.PCA);
        end
    end

    % CROSS VALIDATION (assigning)
    % Default 10
    [r c] = size(X);

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
        ip.Results.nFolds < nTrials, ...
        'nFolds must be an integer between 2 and nTrials to perform CV' );
 
        % TODO: This needs to be regular cvpartition object
        partition = cvpartition(r, 'Kfold', ip.Results.nFolds);
        trainX = [];
        trainY = [];
        testX = [];
        testY = [];
        predictionsConcat = [];
        labelsConcat = [];

    for i = 1:partition.NumTestSets

        trainX = partition.training(i) .* X;
        trainX = trainX(any(trainX, 2),:);
        trainY = partition.training(i)' .* Y;
        trainY = trainY(trainY ~=0);
        testX = partition.test(i) .* X;
        testX = testX(any(testX, 2),:);
        testY = partition.test(i)' .* Y;
        testY = testY(testY ~=0);
        predictedY = NaN(1, length(testY));

        if (ip.Results.PCAinFold == 1)
            if (ip.Results.PCA >0)
                [trainX, V] = getPCs(trainX, ip.Results.PCA);
                testX = testX.*V;
            end
        end

        mdl = fitModel(trainX, trainY, ip.Results.classify, ...
            ip.Results.classifyOptionsStruct);

        predictions = modelPredict(testX, mdl);
        labelsConcat = [labelsConcat testY];
        predictionsConcat = [predictionsConcat predictions];
        %predictcedY(partition.test(i)) = predictions;
    end
    CM = confusionmat(labelsConcat, predictionsConcat);
    accuracy = computeAccuracy(labelsConcat, predictionsConcat); 
    
end
    
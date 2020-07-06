% classificationExamplesMarch2020.m
% ----------------------------------
% Blair - March 22, 2020
%
% Running master branch (v1) of MatClassRsa on small sample of OCED data to
% test out impact of the following factors:
% - reordered trials and labels
% - 10-fold versus leave-one-out cross validation

% Vaidehi data: 5 classes, 10 trials per class, 14-sec trials

clear all; close all; clc
load '../S06.mat'

% Subset the data from classes 1:5 so we have a 5-class problem.
fullIdx = find(labels6 < 6);
fullData = X(:, :, fullIdx);
fullLabels = labels6(fullIdx);

% Center each feature: We subtract the mean from every feature (on the full
% dataset for now).
fullData_cent = centerFeatures(fullData);

%% Sample 10 trials from each of five categories
% Get the data down to a size comparable to Vaidehi's

% Set random number generator for reproducibility
rng(1)

% Sample 10 trials from each of (6-class) categories 1 through 5
sampIdx = [];
for i = 1:5
    sampIdx = [sampIdx; randsample(find(labels6==i),10)];
end

sampledData = centerFeatures(X(:, :, sampIdx)); % Center this sample
sampledLabels = labels6(sampIdx);

% Confirm that our sampled labels are as expected:
% sampledLabels'
%   Columns 1 through 13
%      1     1     1     1     1     1     1     1     1     1     2     2     2
%   Columns 14 through 26
%      2     2     2     2     2     2     2     3     3     3     3     3     3
%   Columns 27 through 39
%      3     3     3     3     4     4     4     4     4     4     4     4     4
%   Columns 40 through 50
%      4     5     5     5     5     5     5     5     5     5     5

%% %%%%% 5-class: Compare full dataset and small sample %%%%%

% The following examples compare classification output using all available
% data (864 trials per class) versus a small sample (10 trials per class).

%% Classify full dataset - 5 class
% Classify the full 5-class data: We do 10-fold cross validation because we
% have a lot of data (and leave-one-out would take a very long time).
[Full10.CM, Full10.acc, ~] = classifyEEG(fullData_cent, fullLabels,...
    'classify', 'LDA', 'randomSeed', 5, 'PCA', 0.99,...
    'nFolds', 10);

% PCA retains around 1500 features for each fold's training set.
% acc: 0.5968
%    469    39   100   125   131
%     48   712    30    25    49
%    122    23   473   142   104
%    117    45   137   458   107
%    133    62    85   118   466

%% Small sample, original ordering, multi-class, 10-fold cross validation
[MultiOrig10.CM, MultiOrig10.acc, ~] = classifyEEG(sampledData, sampledLabels,...
    'classify', 'LDA', 'randomSeed', 5, 'PCA', 0.99,...
    'nFolds', 10);

% Results are substantially worse than when we had all the trials. They
% also seem to be favoring class 3:
% acc: 0.2400
%      1     3     3     2     1
%      0     3     6     0     1
%      1     3     3     3     0
%      3     1     1     4     1
%      1     1     5     2     1

%% Small sample, original ordering, multi-class, leave-one-out cross validation
[MultiOrigLOO.CM, MultiOrigLOO.acc, ~] = classifyEEG(sampledData, sampledLabels,...
    'classify', 'LDA', 'randomSeed', 5, 'PCA', 0.99,...
    'nFolds', length(sampledLabels));

% Retaining 47 PCs in each fold (max is 50).
% Results are a bit worse than 10-fold, again favoring class 3:
% acc: 0.1800
%      0     2     6     0     2
%      0     2     6     1     1
%      1     3     5     0     1
%      0     2     5     2     1
%      2     1     7     0     0

% Note that we can't compute the RDM in the usual way because there are
% zeros along the diagonal.

%% Small sample, shuffled ordering, multi-class, leave-one-out cross validation

% Confirming that shuffling the order of trials (while keeping them
% associated with their labels) does not affect the output of the
% classifier for leave-one-out cross validation. 

rng(1)
shufIdx = randperm(length(sampledLabels));
shufData = sampledData(:, :, shufIdx);
shufLabels = sampledLabels(shufIdx);

[MultiShufLOO.CM, MultiShufLOO.acc, ~] = classifyEEG(shufData, shufLabels,...
    'classify', 'LDA', 'randomSeed', 5, 'PCA', 0.99,...
    'nFolds', length(sampledLabels));

% Results are identical to leave-one-out without shuffling:
% acc: 0.1800
%      0     2     6     0     2
%      0     2     6     1     1
%      1     3     5     0     1
%      0     2     5     2     1
%      2     1     7     0     0

%% %%%%% Pairwise: Compare full dataset and small sample %%%%%

% The following examples attempt pairwise classification to see whether
% results are more informative than multiclass. We do pairwise on the full
% dataset, and then on the small sample.

%% Pairwise classification - full dataset, 10-fold cross validation

% Initialize the RDM - we'll store each pairwise accuracy in here
PairRDM = zeros(5,5);

% Iterate through pairs and classify. Fill in the RDM as element (i,j) is
% the classification accuracy between class i and j (fills in lower
% triangle of the matrix). Doing 10-fold since we have so many trials
for i = 2:5
    for j = 1:(i-1)
        disp(['Classifying ' num2str(i) ' vs ' num2str(j) ':'])
        tempIdx = find(ismember(fullLabels, [i j]));
        tempData = fullData_cent(:, :, tempIdx);
        tempLabels = fullLabels(tempIdx);
        [tempCM, tempAcc] = classifyEEG(tempData, tempLabels,...
            'classify', 'LDA', 'randomSeed', 5, 'PCA', 0.99,...
            'nfolds', 10)
        PairRDM(i, j) = tempAcc;
        clear temp*
    end
end

% Now fill in the upper triangle by summing the matrix and its transpose.
% We see that pairwise distances are generally high, especially for pairs
% involving category 2 (human faces).
PairRDM_full = PairRDM + PairRDM'
%          0    0.8970    0.7506    0.7413    0.7367
%     0.8970         0    0.9045    0.8958    0.8628
%     0.7506    0.9045         0    0.7512    0.7946
%     0.7413    0.8958    0.7512         0    0.7633
%     0.7367    0.8628    0.7946    0.7633         0

% (Just FYI, not going to do this in general in this script) Expected 
% classification accuracy at chance level is 0.5. We can make this zero 
% distance by subtracting 0.5 from the matrix. We then add 0.5 back to the 
% diagonal so it remains zero-valued.
PairRDM_centered = PairRDM_full - 0.5 + 0.5*eye(5)
%          0    0.3970    0.2506    0.2413    0.2367
%     0.3970         0    0.4045    0.3958    0.3628
%     0.2506    0.4045         0    0.2512    0.2946
%     0.2413    0.3958    0.2512         0    0.2633
%     0.2367    0.3628    0.2946    0.2633         0

%% Pairwise classification, small sample, leave-one-out cross validation

% Initialize the RDM - we'll store each pairwise accuracy in here
PairRDM = zeros(5,5);

% Iterate through pairs and classify. Fill in the RDM as element (i,j) is
% the classification accuracy between class i and j (fills in lower
% triangle of the matrix).
for i = 2:5
    for j = 1:(i-1)
        disp(['Classifying ' num2str(i) ' vs ' num2str(j) ':'])
        tempIdx = find(ismember(sampledLabels, [i j]));
        tempData = sampledData(:, :, tempIdx);
        tempLabels = sampledLabels(tempIdx);
        [tempCM, tempAcc] = classifyEEG(tempData, tempLabels,...
            'classify', 'LDA', 'randomSeed', 5, 'PCA', 0.99,...
            'nfolds', length(tempLabels))
        PairRDM(i, j) = tempAcc;
        clear temp*
    end
end

% Now fill in the upper triangle by summing the matrix and its transpose.
% We see that pairwise classifications are much lower than when we had the
% full set of data to work with, and not necessarily highest for pairs
% involving class 2 (human faces). Not good!
PairRDM_full = PairRDM + PairRDM'
%          0    0.4500    0.6500    0.5500    0.6500
%     0.4500         0    0.7000    0.7000    0.6000
%     0.6500    0.7000         0    0.5500    0.5500
%     0.5500    0.7000    0.5500         0    0.8000
%     0.6500    0.6000    0.5500    0.8000         0

% (Again, just FYI) Expected classification accuracy at chance level is 
% 0.5. We can make this zero distance by subtracting 0.5 from the matrix. 
% We then add 0.5 back to the diagonal so it remains zero-valued. Now, the
% pairs that classified below chance level are highlighted as negative
% distances.
PairRDM_centered = PairRDM_full - 0.5 + 0.5*eye(5)
%          0   -0.0500    0.1500    0.0500    0.1500
%    -0.0500         0    0.2000    0.2000    0.1000
%     0.1500    0.2000         0    0.0500    0.0500
%     0.0500    0.2000    0.0500         0    0.3000
%     0.1500    0.1000    0.0500    0.3000         0

%% %%%%% Improving classifier performance by pre-selecting temporal features %%%%%

% Examples up to now have shown that the small sample does not classify as
% well as the full dataset. In this next section we attempt to mitigate
% this problem by not inputting data from negative and early latencies,
% since those will not implicate cortical processing of the stimulus.

%% Multi-class classification, excluding known uninformative time samples

% We have a really low trial count, which means that our trial-by-feature
% matrix that is input to the classifier is very low rank. This in turn
% impacts the calculation of singular values during PCA. Our epochs also
% include some data from time points that are known to not classify well
% (i.e., negative time points, times before 80 msec).
% Thus we can see whether excluding these time points (lowering the
% dimensionality of our feature vector) is helpful.

% The variable t tells us the time (latency), in msec, associated with each
% sample in our epoch. We'll retain response latencies of 80 msec or
% greater.

[MultiOrigLOOT.CM, MultiOrigLOOT.acc, ~] = classifyEEG(...
    sampledData(:, t >= 80, :), sampledLabels,...
    'classify', 'LDA', 'randomSeed', 5, 'PCA', 0.99,...
    'nFolds', length(sampledLabels));

% PCA was retaining 46 PCs
% Accuracy is better than before (cf. 0.1800, line 82), but still not very 
% good. At least we don't have any zeros on the diagonal, so it would be 
% possible to construct an RDM from this. However, it's a bit suspicious 
% that the CM is still favoring class 3.
% acc: 0.2600

MultiOrigLOOT.CM
%      2     0     5     0     3
%      2     2     3     0     3
%      1     0     7     0     2
%      1     0     6     1     2
%      1     2     5     1     1

%% Pairwise classification, excluding known uninformative time samples

% Maybe this mitigates the attraction toward class 3?

% Initialize the RDM - we'll store each pairwise accuracy in here
PairRDMT = zeros(5,5);

% Iterate through pairs and classify. Fill in the RDM as element (i,j) is
% the classification accuracy between class i and j (fills in lower
% triangle of the matrix).
for i = 2:5
    for j = 1:(i-1)
        disp(['Classifying ' num2str(i) ' vs ' num2str(j) ':'])
        tempIdx = find(ismember(sampledLabels, [i j]));
        tempData = sampledData(:, :, tempIdx);
        tempLabels = sampledLabels(tempIdx);
        [tempCM, tempAcc] = classifyEEG(...
            tempData(:, t >= 80, :), tempLabels,...
            'classify', 'LDA', 'randomSeed', 5, 'PCA', 0.99,...
            'nfolds', length(tempLabels))
        PairRDMT(i, j) = tempAcc;
        clear temp*
    end
end

% Now fill in the upper triangle by summing the matrix and its transpose.
% Results are a little better but still not great; and we're still seeing
% below-chance classification for class 2 vs class 1, a pair we thought
% would classify well because class 2 is human faces.
PairRDMT_full = PairRDMT + PairRDMT'
%          0    0.4500    0.7000    0.6000    0.7500
%     0.4500         0    0.8000    0.6500    0.6500
%     0.7000    0.8000         0    0.8000    0.7500
%     0.6000    0.6500    0.8000         0    0.6000
%     0.7500    0.6500    0.7500    0.6000         0

% For comparison, here is the RDM when we input all of the time samples:
%          0    0.4500    0.6500    0.5500    0.6500
%     0.4500         0    0.7000    0.7000    0.6000
%     0.6500    0.7000         0    0.5500    0.5500
%     0.5500    0.7000    0.5500         0    0.8000
%     0.6500    0.6000    0.5500    0.8000         0

%% %%%%% Producing more stable distance measures with bootstrapping %%%%%

% Because our sample size is small, it may be the case that characteristics
% of our sample may be influencing the classification results. Let's see
% whether pairwise accuracies are different once we implement a boostrap
% procedure.

%% Bootstrap pairwise, excluding known uninformative time samples

% First we separate our data and labels into each of the 5 classes, to make
% sampling with replacement easier.
for cl = 1:5
    bData{cl} = sampledData(:, :, sampledLabels==cl);
    bLabels{cl} = sampledLabels(sampledLabels==cl);
end

%%% Specify bootstrap parameters %%%
% Set the number of boostrap iterations
nBoot = 10;
% Specify how many samples to draw in each iteration (for each class).
% Since we know we have 10 trials per class, we'll just set explicitly.
% Otherwise would set based on observed number of trials per class.
nToSample = 10;

% Initialize the RDM - we'll store each pairwise accuracy in here. We now
% have a 3D matrix to account for all of our boostrap iterations.
allAcc = zeros(5,5,nBoot);

% Params for testing
i = 2; j = 1; % Do just one pair (comment our i and j loops below)
bCount = 1; % rng specification - increment in every bootstrap iteration

clc
bStart = tic;
for i = 2:5
    for j = 1:(i-1)
        disp(['Classifying ' num2str(i) ' vs ' num2str(j) ':'])
        disp(['Starting ' num2str(nBoot) ' bootstrap iterations.'])
        for b = 1:nBoot
            % Set the random seed to shuffle in each bootstrap iteration since it
            % also gets set each time we do classification.
            rng(bCount) % For testing, in practice recommend 'shuffle'
            bCount = bCount + 1; % For testing
            
            % Get indices of current trials to classify from each class -- given T
            % trials per class, we'll sample T trials, with replacement.
            sI = randsample(nToSample, nToSample, 1)
            sJ = randsample(nToSample, nToSample, 1)
            thisData = cat(3,...
                bData{i}(:, :, sI),...
                bData{j}(:, :, sJ));
            %     thisData = cat(3, bData{i}, bData{j}); % For testing
            thisLabels = [bLabels{i}; bLabels{j}];
            [~, allAcc(i, j, b)] = classifyEEG(...
                thisData(:, t>=80, :), thisLabels,...
                'classify', 'LDA', 'randomSeed', 5, 'PCA', 0.99,...
                'nFolds', length(thisLabels));
            clear this* sI sJ
            if ~mod(b,10)
                disp(['*** Finished ' num2str(b) ' of ' num2str(nBoot) ' iterations. ***']);
            end
        end
    end
end
bEnd = toc(bStart)

meanAcc0 = mean(allAcc, 3);
meanAcc = meanAcc0 + meanAcc0'
% Here is the pairwise matrix from 10 bootstrap iterations:
%          0    0.7800    0.8200    0.8150    0.8650
%     0.7800         0    0.8800    0.8550    0.8700
%     0.8200    0.8800         0    0.8100    0.8400
%     0.8150    0.8550    0.8100         0    0.8200
%     0.8650    0.8700    0.8400    0.8200         0

% Here is the pairwise matrix from 100 bootstrap iterations:
%          0    0.7880    0.8190    0.8140    0.8740
%     0.7880         0    0.8760    0.8565    0.8550
%     0.8190    0.8760         0    0.8440    0.8395
%     0.8140    0.8565    0.8440         0    0.8285
%     0.8740    0.8550    0.8395    0.8285         0

% For reference, here is the pairwise matrix when using all of the data 
% (10-fold cross validation, no bootstrap:
%          0    0.8970    0.7506    0.7413    0.7367
%     0.8970         0    0.9045    0.8958    0.8628
%     0.7506    0.9045         0    0.7512    0.7946
%     0.7413    0.8958    0.7512         0    0.7633
%     0.7367    0.8628    0.7946    0.7633         0


function [obj, V, nPC, colMeans, colScales] = cvData(X, Y, trainDevTestSplit, ip, center, scale, nFolds)
% cvDataObj = cvData(X, Y, trainDevTestSplit, ip, center, scale, nFolds);
% --------------------------------
% 
% cvData is an object that stores data to be used for cross validation.  It
% It takes as input the data matrix, X, and the label vector Y, the 
% trainDevTestSplit object and the PCA parameters specificed in the 
% classifyCrossValidate() function call.  It formats the data into 
% partitions to enable convineint cross validationlater.  
% 
% INPUT ARGS:
%   - X: training data (2D)
%   - Y: labels
%   - partition: object of class trainDevTestSplit
%   - ip: User input parsed as ip, with ip.Results.PCA parameter and
%         ip.Results.PCAinFold paramter
%   - scale: boolean (True/False) for data scaling
%   - center: boolean (True/False) for data centering
%
% OUTPUT ARGS:
%   - obj:  an object of the trainDevTestSplit class

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

is3D = 0;
isPCA = 0;

if ndims(X) == 3
    is3D = 1;
    X3D = X;
    % add reshape data to 2D
    X = Utils.cube2trRows(X);
end
    
    nbins = length(unique(Y));
    counts = histcounts(Y, nbins);

    % check that length of counts is the same as nClasses
    assert(length(counts) == length(unique(Y)), 'length of counts is not the same as the number of unique classes');
    
    % check that there are no classes with only 1 observation
    assert(min(counts) > 1, 'The number of observations for each class must be larger than 1');
    
    PCA = ip.Results.PCA;
    PCAinFold = ip.Results.PCAinFold;
    

    if (isfield(ip.Results,'nFolds'))
        nFolds = ip.Results.nFolds;
         % check that nObservationsPerClass > nFolds
        assert(min(counts) >= nFolds, 'the number of observations for each class must be larger than nFolds');
    elseif (isfield(ip.Results,'nFolds_opt'))
        nFolds = ip.Results.nFolds_opt;
         % check that nObservationsPerClass > nFolds
        assert(min(counts) >= nFolds, 'the number of observations for each class must be larger than nFolds');
    else 
        nFolds = 1;
    end

    obj = struct();
    obj.optimize = trainDevTestSplit.optimize;

    trainXall = {};
    devXall = {};
    testXall = {};
    trainYall = {};
    devYall = {};
    testYall = {};
    
    % initialize return variables for train functions
    V = NaN;
    nPC = NaN;
    colMeans = NaN;
    colScales = NaN;
    

    if (strcmp(center, 'on'))
        center = true;
    else
        center = false;
    end
    if (strcmp(scale, 'on'))
        scale = true;
    else
        scale = false;
    end
    
    %parpool;
    % DO PCA
    if (PCA >0)
        isPCA = 1;
        % outside of folds
        if (PCAinFold == 0)
%             disp('Conducting PCA on once on entire dataset');
            [X, colMeans, colScales] = Utils.centerAndScaleData(X, center, scale);
            [X, V, nPC] = Utils.getPCs(X, PCA);

            for i = 1:trainDevTestSplit.NumTestSets
                trainIndx = find(trainDevTestSplit.train{i});
                devIndx = find(trainDevTestSplit.dev{i});
                testIndx = find(trainDevTestSplit.test{i});

                trainX = X(trainIndx, :);
                trainY = Y(trainIndx);
                devX = X(devIndx, :);
                devY = Y(devIndx);
                testX = X(testIndx, :);
                testY = Y(testIndx);
                
            
                trainXall = [trainXall {trainX}];
                devXall = [devXall {devX}];
                testXall = [testXall {testX}];
                trainYall = [trainYall {trainY}];
                devYall = [devYall {devY}];
                testYall = [testYall {testY}];
            end
        % inside folds    
        else
            [r c] = size(X);

            for i = 1:nFolds
%                 disp(['  fold ' num2str(i) ' of ' num2str(trainDevTestSplit.NumTestSets)]);                
                trainIndx = find(trainDevTestSplit.train{i});
                devIndx = find(trainDevTestSplit.dev{i});
                testIndx = find(trainDevTestSplit.test{i});

                trainX = X(trainIndx, :);
                
                % center and scale training data
                [trainX, colMeans, colScales] = ...
                    Utils.centerAndScaleData(trainX, center, scale);
                trainY = Y(trainIndx);

                devX = X(devIndx, :);
                testX = X(testIndx, :);
                % accordingly center and scale test data
                    [testX, ~, ~] = Utils.centerAndScaleData(testX, colMeans, colScales);
                    [devX, ~, ~] = Utils.centerAndScaleData(devX, colMeans, colScales);
                devY = Y(devIndx);    
                testY = Y(testIndx);

                % PCA after data center/scaling
                if (PCAinFold == 1)
                    [trainX, V, nPC] = Utils.getPCs(trainX, PCA);
                    testX = testX*V;
                    testX = testX(:,1:nPC);
                    devX = devX*V;
                    devX = devX(:,1:nPC);
                end
                trainXall = [trainXall {trainX}];
                devXall = [devXall {devX}];
                testXall = [testXall {testX}];
                trainYall = [trainYall {trainY}];
                devYall = [devYall {devY}];
                testYall = [testYall {testY}];        
            end

        end
    % DONT DO PCA
    
    else
        if (~isnan(center) && ~isnan(scale))
            [X, ~, ~] = Utils.centerAndScaleData(X, center, scale);
        end
                    
        for i = 1:nFolds
            
            %debugging
            disp(i)
            
            trainIndx = find(trainDevTestSplit.train{i});
            devIndx = find(trainDevTestSplit.dev{i});
            testIndx = find(trainDevTestSplit.test{i});
            trainX = X(trainIndx, :);
            trainY = Y(trainIndx);
            devX = X(devIndx, :);
            devY = Y(devIndx);
            testX = X(testIndx, :);
            testY = Y(testIndx);

            trainXall = [trainXall {trainX}];
            devXall = [devXall {devX}];
            testXall = [testXall {testX}];
            trainYall = [trainYall {trainY}];
            devYall = [devYall {devY}];
            testYall = [testYall {testY}];
        end
        
        colMeans = 0;
        colScales = 0;
        [r c] = size(X);
        nPC = c;

    end
    if is3D
        % Get sizes to initialize the output
        nCh = size(X3D, 1); % Number of electrodes
        N = size(X3D, 2); % Number of time samples per trial
        
        if (PCA >0)
            N = nPC;
        end
        
        for i = 1:nFolds
        
            nTrialsTrain = size(trainXall{i}, 1); % Number of trials train
            nTrialsTest = size(testXall{i}, 1); % Number of trials test
            nTrialsDev = size(devXall{i}, 1); % Number of trials dev
            
            if (PCA >0)
                % Reshape into [numTrials x numSamples x numElectrodes]
                data3DTrain = reshape(trainXall{i}', [N, nTrialsTrain]);
                data3DTest = reshape(testXall{i}', [N, nTrialsTest]);
                data3DDev = reshape(devXall{i}', [N, nTrialsDev]);
                
                data3DTrain = data3DTrain';
                data3DTest = data3DTest';
                data3DDev = data3DDev';
                
            else
                % Reshape into [numTrials x numSamples x numElectrodes]
                data3DTrain = reshape(trainXall{i}', [nCh, N, nTrialsTrain]);
                data3DTest = reshape(testXall{i}', [nCh, N, nTrialsTest]);
                data3DDev = reshape(devXall{i}', [nCh, N, nTrialsDev]);
            end

            
            obj.trainXall{i} = data3DTrain;
            obj.devXall{i} = data3DDev;
            obj.testXall{i} = data3DTest;
        end
        
        obj.trainYall = trainYall;
        obj.devYall = devYall;
        obj.testYall = testYall;
      
    else
        obj.trainXall = trainXall;
        obj.devXall = devXall;
        obj.testXall = testXall;
        obj.trainYall = trainYall;
        obj.devYall = devYall;
        obj.testYall = testYall;

    end
end
      

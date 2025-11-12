% example_Classification_predict.m
% --------------------------------
% Example function calls for predict() function within
% the +Classification module
%
% This example requires one or more example data files. Run the 
% illustrative_0_downloadExampleData script in the IllustrativeAnalyses 
% folder if you have not already downloaded the example data. 

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

clear all; close all; clc;

load('exampleModel.mat');
trainParticipant = load('S01.mat');
testParticipant = load('TestData2016Paper');
rngSeed = 6;

%% Partitioning Data of Single Participant, tainMulti(), LDA Model, no PCA

% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(trainParticipant.X, trainParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 10, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

% (90% Train, 0 Development, 10% Test) data partitioning
partition = Utils.trainDevTestPart(xAvg, 1, [0.9, 0, 0.1]);

% needed for cvData() function call
ip.Results.PCA = 0;
ip.Results.PCAinFold = 0;

[cvDataObj,V,nPCs] = Utils.cvData(xAvg, yAvg, partition, ip, 1, 0);

% LDA classificaiton
M = Classification.trainMulti(cvDataObj.trainXall{1}, cvDataObj.trainYall{1}, 'rngType', rngSeed, 'PCA' , 0);

P = Classification.predict(M, cvDataObj.testXall{1}, 'actualLabels', cvDataObj.testYall{1});
disp(P.accuracy);
disp(P.CM);
%% Partitioning Data of Single Participant, tainMulti(), LDA Model, PCA on all data

% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(trainParticipant.X, trainParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 10, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

% (70% Train, 0 Development, 30% Test) data partitioning
partition = Utils.trainDevTestPart(xAvg, 1, [0.7, 0, 0.3]);

% needed for cvData() function call
ip.Results.PCA = 0.99;
ip.Results.PCAinFold = 0;

[cvDataObj,V,nPCs] = Utils.cvData(xAvg, yAvg, partition, ip, 1, 0);

% LDA classificaiton
M = Classification.trainMulti(cvDataObj.trainXall{1}, cvDataObj.trainYall{1}, 'rngType', rngSeed, 'PCA' , 0);

P = Classification.predict(M, cvDataObj.testXall{1}, 'actualLabels', cvDataObj.testYall{1});
disp(P.accuracy);
disp(P.CM);
%% Partitioning Data of Single Participant, tainMulti(), LDA Model, PCA on partitioned data
% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(trainParticipant.X, trainParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 5, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

% (70% Train, 0 Development, 30% Test) data partitioning
partition = Utils.trainDevTestPart(xAvg, 1, [0.7, 0, 0.3]);

% needed for cvData() function call
ip.Results.PCA = 0;
ip.Results.PCAinFold = 0;

[cvDataObj,V,nPCs] = Utils.cvData(xAvg, yAvg, partition, ip, 1, 0);

% LDA classificaiton
M = Classification.trainMulti(cvDataObj.trainXall{1}, cvDataObj.trainYall{1}, 'rngType', rngSeed, 'PCA' , 0.99);

P = Classification.predict(M, cvDataObj.testXall{1}, 'actualLabels', cvDataObj.testYall{1});
disp(P.accuracy);
disp(P.CM);

%% Partitioning Data of Single Participant, trainMulti(), SVM Model, no PCA, pre-identified hyperparameters

% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(testParticipant.X, testParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 5, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

% (90% Train, 0 Development, 10% Test) data partitioning
partition = Utils.trainDevTestPart(xAvg, 1, [0.9, 0, 0.1]);

% needed for cvData() function call
ip.Results.PCA = 0;
ip.Results.PCAinFold = 0;

[cvDataObj,V,nPCs] = Utils.cvData(xAvg, yAvg, partition, ip, 0, 0);

% SVM classificaiton hyperparameters
gamma_opt = 1.0000e-5;
C_opt = 100000;

M = Classification.trainMulti(cvDataObj.trainXall{1}, cvDataObj.trainYall{1}, 'PCA', 0, ...
   'classifier', 'SVM', 'gamma', gamma_opt, 'C', C_opt, 'rngType', rngSeed);

P = Classification.predict(M, cvDataObj.testXall{1}, 'actualLabels', cvDataObj.testYall{1});
disp(P.accuracy);
disp(P.CM);


%% Partitioning Data of Single Participant, trainMulti_opt(), SVM Model -- PCA on all data

% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(testParticipant.X, testParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 5, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

% (90% Train, 0 Development, 10% Test) data partitioning
partition = Utils.trainDevTestPart(xAvg, 1, [0.9, 0, 0.1]);

% needed for cvData() function call
ip.Results.PCA = 0.99;
ip.Results.PCAinFold = 0;

[cvDataObj,V,nPCs] = Utils.cvData(xAvg, yAvg, partition, ip, 1, 0);

% since PCA has already been done, 'PCA' optional input argument is set to
% 0
M = Classification.trainMulti_opt(cvDataObj.trainXall{1}, cvDataObj.trainYall{1}, 'PCA', 0, ...
   'classifier', 'SVM', 'rngType', rngSeed);

P = Classification.predict(M, cvDataObj.testXall{1}, 'actualLabels', cvDataObj.testYall{1});

disp(P.accuracy);
disp(P.CM);
%% Partitioning Data of Single Participant, trainMulti_opt(), SVM Model, PCA on partitioned data

% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(testParticipant.X, testParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 5, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

% (90% Train, 0 Development, 10% Test) data partitioning
partition = Utils.trainDevTestPart(xAvg, 1, [0.9, 0, 0.1]);

% needed for cvData() function call
ip.Results.PCA = 0;
ip.Results.PCAinFold = 0;

[cvDataObj,V,nPCs] = Utils.cvData(xAvg, yAvg, partition, ip, 0, 0);

% SVM classification hyperparameters
gamma_opt = 1.0000e-5;
C_opt = 100000;

M = Classification.trainMulti(cvDataObj.trainXall{1}, cvDataObj.trainYall{1}, 'PCA', .99, ...
   'classifier', 'SVM', 'gamma', gamma_opt, 'C', C_opt, 'rngType', rngSeed);

P = Classification.predict(M, cvDataObj.testXall{1}, 'actualLabels', cvDataObj.testYall{1});
disp(P.accuracy);
disp(P.CM);


%% Partitioning Data of Single Participant, trainMulti_opt(), SVM Model -- PCA on partitioned train data

% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(testParticipant.X, testParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 5, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

% (90% Train, 0 Development, 10% Test) data partitioning
partition = Utils.trainDevTestPart(xAvg, 1, [0.9, 0, 0.1]);

% needed for cvData() function call
ip.Results.PCA = 0;
ip.Results.PCAinFold = 0;

[cvDataObj,V,nPCs] = Utils.cvData(xAvg, yAvg, partition, ip, 1, 0);

% PCA on partitioned data
M = Classification.trainMulti_opt(cvDataObj.trainXall{1}, cvDataObj.trainYall{1}, 'PCA', 0.99, ...
   'classifier', 'SVM', 'rngType', rngSeed);

P = Classification.predict(M, cvDataObj.testXall{1}, 'actualLabels', cvDataObj.testYall{1});

disp(P.accuracy);
disp(P.CM);

%% Transfer Learning: SVM model from Participant to Predict Classes of Another

% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(trainParticipant.X, trainParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 5, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

% SVM classificaiton
M = Classification.trainMulti_opt(xAvg, yAvg, 'PCA', 0.90, ...
   'classifier', 'SVM', 'rngType', rngSeed);

% Preprocessing steps for test participant
[xShuf, yShuf] = Preprocessing.shuffleData(testParticipant.X, testParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 5, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

P = Classification.predict(M, xAvg, 'actualLabels', yAvg);

% P.predY contains all predicted class labels for X

confMat = confusionmat(yAvg, P.predY);
confusionchart(confMat);
disp(P.accuracy);
disp(P.CM);


%% Partitioning Data of Single Participant, trainPairs(), LDA Model, PCA on all data

% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(trainParticipant.X, trainParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 10, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

% (80% Train, 0 Development, 20% Test) data partitioning
partition = Utils.trainDevTestPart(xAvg, 1, [0.8, 0, 0.2]);

% needed for cvData() function call
ip.Results.PCA = 0.99;
ip.Results.PCAinFold = 0;

[cvDataObj,V,nPCs] = Utils.cvData(xAvg, yAvg, partition, ip, 1, 0);

% LDA classificaiton
M = Classification.trainPairs(cvDataObj.trainXall{1}, cvDataObj.trainYall{1}, 'rngType', rngSeed, 'PCA' , 0);

P = Classification.predict(M, cvDataObj.testXall{1}, 'actualLabels', cvDataObj.testYall{1});

disp(P.AM);

%% Partitioning Data of Single Participant, trainPairs()_opt, SVM Model, PCA on all data

% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(trainParticipant.X, trainParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 10, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

% (80% Train, 0 Development, 20% Test) data partitioning
partition = Utils.trainDevTestPart(xAvg, 1, [0.8, 0, 0.2]);

% needed for cvData() function call
ip.Results.PCA = 0.99;
ip.Results.PCAinFold = 0;

[cvDataObj,V,nPCs] = Utils.cvData(xAvg, yAvg, partition, ip, 1, 0);

% LDA classificaiton
M = Classification.trainPairs_opt(cvDataObj.trainXall{1}, cvDataObj.trainYall{1}, 'rngType', rngSeed, 'PCA' , 0);

P = Classification.predict(M, cvDataObj.testXall{1}, 'actualLabels', cvDataObj.testYall{1});

disp(P.accuracy)
disp(P.CM);

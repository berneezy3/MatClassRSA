% example_Classification_predict()
% ---------------------
% Ray - April, 2025
%
% Example function calls for predict() function within
% the +Classification module

clear all; close all; clc;

load('exampleModel.mat');
trainParticipant = load('S01.mat');
testParticipant = load('TestData2016Paper');
rngSeed = 6;

%% Partitioning Data of Single Participant

% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(trainParticipant.X, trainParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 10, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

partition = Utils.trainDevTestPart(xAvg, 1, [0.9, 0, 0.1]);

ip.Results.PCA = 0;
ip.Results.PCAinFold = 0;

[cvDataObj,V,nPCs] = Utils.cvData(xAvg, yAvg, partition, ip, 0, 0);

% LDA classificaiton
M = Classification.trainMulti(cvDataObj.trainXall{1}, cvDataObj.trainYall{1}, 'rngType', rngSeed);

P = Classification.predict(M, cvDataObj.testXall{1}, 'actualLabels', cvDataObj.testYall{1});
disp(P.accuracy);
disp(P.CM);

%% Train model on one participant and predict class labels for another

% Preprocessing steps for train participant
[xShuf, yShuf] = Preprocessing.shuffleData(trainParticipant.X, trainParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 30, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

% LDA classificaiton
M = Classification.trainMulti(xAvg, yAvg, 'rngType', rngSeed);

% Preprocessing steps for test participant
[xShuf, yShuf] = Preprocessing.shuffleData(testParticipant.X, testParticipant.labels6, 'rngType', rngSeed);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 30, 'handleRemainder', 'append', 'rngType', rngSeed);  % Apply group averaging

P = Classification.predict(M, xAvg, 'actualLabels', yAvg);

% P.predY contains all predicted class labels for X

confMat = confusionmat(yAvg, P.predY);
confusionchart(confMat);
P.accuracy;

%%



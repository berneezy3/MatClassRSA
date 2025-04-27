% example_Classification_predict()
% ---------------------
% Ray - April, 2025
%
% Example function calls for predict() function within
% the +Classification module

clear all; close all; clc;

load('exampleModel.mat');
load('S01.mat');
rngSeed = 3;

%%
% Preprocessing Steps
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6);  % Shuffle Data
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);  % Normalize Data
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 20, 'handleRemainder', 'append');  % Apply group averaging

M = Classification.crossValidateMulti(xAvg, yAvg);

%% Basic Function Call with SVM Model
% Trained using trainMulti_opt() on SO1 dataset (124 electrode x 40 time x 5184 trials)
% using 6 class labels


P = Classification.predict(M.modelsConcat{1}, X, 'actualLabels', labels6);

% P.predY contains all predicted class labels for X
%%

confMat = confusionmat(labels6, P.predY);
confusionchart(confMat);

%%

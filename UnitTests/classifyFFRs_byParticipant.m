% classify FFR data
% Steven Losorelli
% ACLS1_2

clear all; close all; clc

inDir = './'
cd(inDir) 

%load('aggrResp500_time_FFT_13subs_5to145ms_4096zeroPad_12172018');
load('aggrResp500_time_FFT_lessThan1000Hz_13subs_5to145ms');

%% load the X matrix (time, FFT, etc.) to classify

currX = X;%magFFT_imagReal;

Y = round(Y,0);


%%
Sx1 = [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4 5 5 5 5 5 6 6 6 6 6 7 7 7 7 7 8 8 8 8 8 9 9 9 9 9 10 10 10 10 10 11 11 11 11 11 12 12 12 12 12 13 13 13 13 13];
S = [Sx1 Sx1 Sx1 Sx1 Sx1 Sx1];

%% ensure X and Y match along the trial dimension

if ~any(length(Y) == size(currX)) 
    error('length of Y does not correspond to any length of X')
end

if size(currX,1) ~= length(Y)
    disp('transposing X!')
    currX=currX';
end


%%

accuracies = []

for i=1:13
    thisTrainX = currX;
    thisTrainY = Y;
    thisTrainX(S==i, :) = [];
    thisTestX = currX(S==i,:);
    thisTrainY(S==i) = [];
    thisTestY = Y(S==i);
    
    [CM, accuracy, ~, pVal, classifierInfo] = classifyEEG({thisTrainX, thisTestX}, {thisTrainY, thisTestY}, 'classify',...
        'LDA', 'averageTrials', 0, 'NFolds', 13, 'PCA', 0.99, 'shuffleData', 1);
    
    accuracies = [accuracies accuracy];
    
end



%% [CM, accuracy, predY, pVal, classifierInfo, varargout]


[CM, accuracy, ~, pVal, classifierInfo] = classifyEEG(currX, Y, 'classify', 'LDA', 'averageTrials', 0, 'NFolds', 13,...
        'PCA', 0.99, 'shuffleData', 1)%, 'permutations', 1000, 'pValueMethod', 'permuteFullModel');

%%
[CM, accuracy, ~, pVal, classifierInfo] = classifyEEG(currX, Y, 'classify', 'LDA', 'averageTrials', 0, 'NFolds', 10,...
        'PCA', 0.99, 'permutations', 1000, 'pValueMethod', 'permuteFullModel');

%[CM, accuracy] = classifyEEG(currX, Y, 'classify', 'LDA', 'NFolds', 10)
    

%% save output CM

dataDir = '/Users/slosorelli/Desktop/SEI/ACLS1_2/ABRdata/manuscriptCode/code/classificationData'
cd(dataDir)

save('ClassifierData_FFTImagReal_5to145ms_500respAvg_13subs_4096zeroPad_lessthan100Hz_12182018', 'CM', 'pVal', 'accuracy', 'classifierInfo');


%save('CM_FFTmagImagReal_FFR_0to140ms_500avg_13subs_20181102', 'CM', 'pVal', 'accuracy', 'classifierInfo');




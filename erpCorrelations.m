% erpCorrelations.m
% --------------------
% Blair - Nov. 6, 2016
%
% This script loads 1 or all data frames, computes averaged ERPs, and plots
% the correlation of the averages with or without PC dimensionality
% reduction.

clear all; close all; clc

%%%%%%%% Edit stuff %%%%%%%%%%%
s = 10; % 1:10 or 0 to load all subs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataDir = '/Users/berneezy/Projects/researchCCRMA/MatlabEEGToolbox/Kaneshiro_etAl_objectCategoryEEG';
cd(dataDir)

if s == 0
    X0 = [];
    catLabels = [];
    exLabels = [];
    for i = 1:10
        fnIn = ['S' num2str(i) '.mat'];
        load(fnIn)
        X0 = [X0; X]; % Concatenate the data frame
        catLabels = [catLabels categoryLabels];
        exLabels = [exLabels exemplarLabels];
        sub = 'all';
    end
else
    fnIn = ['S' num2str(s) '.mat'];
    load(fnIn)
    X0 = X; catLabels = categoryLabels; exLabels = exemplarLabels;
end
clear X categoryLabels exemplarLabels
%{
xTrialMaxes = max(abs(X0), [], 2);
%hist(xTrialMaxes);
badTrials = find(xTrialMaxes >= 2);
X0(badTrials,:) = [];
%}

%%
%%%%%% Edit - category or exemplar labels %%%%%%
labUse = exLabels;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%labUse(badTrials) = [];
nClass = length(unique(labUse));
% Initialize the averaged ERP matrix - each class is a row
avgERPMatrix = nan(nClass, size(X0, 2));

for i = 1:nClass
   currIdx = find(labUse == i);
   avgERPMatrix(i,:) = mean(X0(currIdx, :));
end

figure(1)
subplot 211
% Plot the correlation matrix - no PCA
corrMatrixNoPCA = corr(avgERPMatrix');
imagesc(corrMatrixNoPCA)
%%

varExp = 0.9; % Proportion of variance to explain with PCs
% Do PCA
[U, S, V] = svd(avgERPMatrix);
diagS2 = diag(S).^2;
componentVarExp = diagS2/sum(diagS2);
cumulativeVarExp = cumsum(diagS2)/sum(diagS2);
nPCVarExp = find(cumulativeVarExp >= varExp, 1)

figure(2)
subplot 211; plot(componentVarExp); grid on; xlim([0 200])
subplot 212; plot(cumulativeVarExp); grid on; xlim([0 200])
%%
% Transform the data to PC space (columnwise)
XPc = avgERPMatrix*V;
xPCUse = XPc(:,1:nPCVarExp);
figure(1)
subplot 212
imagesc(corr(xPCUse'))

%%
%{
figure(3)
for pc = 2:nClass
    imagesc(corr(XPc(:,1:pc)'))
    pause
end
%}
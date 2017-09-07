% compute_pDist_RDMs.m
% --------------------
% Blair - Nov. 6, 2016
%
% This script loads 1 or all data frames, computes averaged ERPs by
% category, and then computes pairwise distances among the categories using
% a few different methods. You can plot the RDMs and save to .mat.
%
% May need to change the catLabels exLabels variables when transitioning
% from vision data to music data.
%
% Recommend doing this for each subject separately and averaging the
% matrices across subjects later on (in a different script).

%clear all; close all; clc

%%%%%%%% Edit stuff %%%%%%%%%%%
% Which subject to look at - 1:10 for vision, 1:2 for music
s = 0; % 0 to load all subs

checkBadTrial = 0; % Whether to check for bad trials (keep zero for now)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fSize = 16;

% Directory containing the preprocessed EEG data
dataDir = '/Users/berneezy/Projects/researchCCRMA/shortChordEEG';
cd(dataDir)

% Directory to write out the RDMs
outDir = '/Users/berneezy/Projects/researchCCRMA/shortChordEEG/RDMs';

if s == 0
    X0 = [];
    
    % Not sure if these variables are present in the music data
    catLabels = [];
    exLabels = [];
    for i = 1:2
        % May need to edit the next line for music data
        %fnIn = '/Users/berneezy/Projects/researchCCRMA/shortChordEEG/data.mat';
        
        %load(fnIn)
        X0 = [corrX1; corrX2]; % Concatenate the data frame
        catLabels = [Y1category; Y2category];
        exLabels = [Y1exemplar; Y2exemplar];
        exLabels = exLabels/5 - 4;
        sub = 'all';
    end
else
    fnIn = '/Users/berneezy/Projects/researchCCRMA/shortChordEEG/data.mat';
    load(fnIn)
    X0 = [X i]; catLabels = ['Y' i 'category']; exLabels = ['Y' i 'exemplar'];
end
%clear X categoryLabels exemplarLabels

addpath('/Users/berneezy/Projects/researchCCRMA/MatlabEEGClassification/');
% X0 = trRows2cube(X0, 39);
% X0 = X0(:,[16 17 18 19 20 21], :);
% X0 = cube2trRows(X0);

% X0 = trRows2cube(X0, 39);
% X0 = X0(:,[1 2 3 4 5 6], :);
% X0 = cube2trRows(X0);

%%
%close all
%%%%%% Edit - catLabels or exLabels %%%%%%
labUse = exLabels;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% This is if checking for/excluding bad trials
if checkBadTrial
    xTrialMaxes = max(abs(X0), [], 2);
    badTrials = find(xTrialMaxes >= 5);
    X0(badTrials, :) = [];
    disp(['number of bad trials: ' num2str(length(badTrials))])
    labUse(badTrials) = [ ];
else
    disp('Not checking for bad trials.')
end
%%%%%%%%%%%%%%%%%%%%%%%%

% How many categories we are looking at
nClass = length(unique(labUse));

% Initialize the averaged ERP matrix - each class is a row
X_ERP = nan(nClass, size(X0, 2)); % <-- this is the ERP matrix

for i = 1:nClass
    currIdx = find(labUse == i);
    X_ERP(i,:) = mean(X0(currIdx, :));
end

%%% Do PCA
varExp = 0.9; % Proportion of variance to explain with PCs
% Do PCA
[U, S, V] = svd(X_ERP);
diagS2 = diag(S).^2;
componentVarExp = diagS2/sum(diagS2);
cumulativeVarExp = cumsum(diagS2)/sum(diagS2);
nPCVarExp = find(cumulativeVarExp >= varExp, 1)
X_PC_0 = X_ERP * V;
X_PC = X_PC_0(:, 1:nPCVarExp); % <-- this is the PC ERP matrix

figure(1)
subplot 211; plot(componentVarExp); grid on; xlim([0 200])
title('Component var explained')
subplot 212; plot(cumulativeVarExp); grid on; xlim([0 200])
title('Cumulative var explained' )

%%% Compute some RDMs of the data
% Regular correlation
rdm_corr = pdist2(X_ERP, X_ERP, 'correlation');
rdm_corr_PC = pdist2(X_PC, X_PC, 'correlation');

% Rank correlation
rdm_spear = pdist2(X_ERP, X_ERP, 'spearman');
rdm_spear_PC = pdist2(X_PC, X_PC, 'spearman');

% Euclidean distance
rdm_eucl = pdist2(X_ERP, X_ERP, 'euclidean');
rdm_eucl_PC = pdist2(X_PC, X_PC, 'euclidean');

%% Plot the different kinds of RDMs

figure(2)
subplot 211
imagesc(rdm_corr); title('Correlation', 'fontsize', fSize)
subplot 212
imagesc(rdm_corr_PC)

figure(3)
subplot 211; imagesc(rdm_spear); title('Spearman', 'fontsize', fSize)
subplot 212; imagesc(rdm_spear_PC)

figure(4)
subplot 211; imagesc(rdm_eucl); title('Euclidean', 'fontsize', fSize)
subplot 212; imagesc(rdm_eucl_PC)

%%
close all
cd(outDir)
save(['rdm_corr_' num2str(s)], 'rdm_corr')
save(['rdm_PC_corr_' num2str(s)], 'rdm_corr_PC')
save(['rdm_spear_' num2str(s)], 'rdm_spear')
save(['rdm_PC_spear_' num2str(s)], 'rdm_spear_PC')
save(['rdm_eucl_' num2str(s)], 'rdm_eucl')
save(['rdm_PC_eucl_' num2str(s)], 'rdm_eucl_PC')
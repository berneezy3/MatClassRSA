% classificationExample.m
% -------------------------
% Illustrative example for MatClassRSA toolbox. 
%
% This script loads a Matlab data file that has been downloaded from a 
% public EEG repository (https://purl.stanford.edu/bq914sc3730) and 
% performs 6-class classification of the 3D EEG data frame. In the first
% analysis, single trials are classified. In the second analysis, trials
% are averaged in groups of 5 (within-class) before classification. The
% function calls use the default settings, except to group-average the
% trials.
%
% The output confusion matrix from each classification is then converted to
% an RDM. The RDM is then visualized as a matrix image, in an MDS plot, as
% a dendrogram, and as a minimum spanning tree.
%
% (c) Bernard Wang and Blair Kaneshiro, 2017. 
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com

uiwait(msgbox('In the next window, select the directory containing the .mat file ''S6.mat.'''))
inDir = uigetdir(pwd);
%%
cd(inDir)
load S6.mat

%%%%% Analysis 1: Classification of single trials.
% X_3D is the electrodes x time x trial data matrix.
% categoryLabels is the vector of labels (6 categories)

% Call the classification function
[CM, acc, predY, pVal, classifierInfo] = classifyEEG(X_3D, ...
    categoryLabels);

%%
% Convert the confusion matrix to an RDM
RDM = computeRDM(CM);


% Create the four visualizations
f1 = plotMatrix(RDM, 'matrixLabels', 1, 'colormap', 'summer', ...
    'axisLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
     'axisColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
f2 = plotMDS(RDM, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
f3 = plotDendrogram(RDM, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
f4 = plotMST(RDM, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
%%

%%%%% Anaysis 2: Classification of group-averaged trials.
% Call the classification function
[CM5, acc5, predY5, pVal5, classifierInfo5] = classifyEEG(X_3D, ...
categoryLabels, 'averageTrials', 5);

%%
% Convert the confusion matrix to an RDM
RDM5 = computeRDM(CM5);

% Create the four visualizations
f5 = plotMatrix(RDM5, 'matrixLabels', 1, 'colormap', 'summer', ...
    'axisLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
     'axisColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
f6 = plotMDS(RDM5, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
f7 = plotDendrogram(RDM5, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
f8 = plotMST(RDM5, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
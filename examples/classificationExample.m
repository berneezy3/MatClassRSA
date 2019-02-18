
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

% This software is licensed under the 3-Clause BSD License (New BSD License), 
% as follows:
% -------------------------------------------------------------------------
% Copyright 2017 Bernard C. Wang, Anthony M. Norcia, and Blair Kaneshiro
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
% this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice, 
% this list of conditions and the following disclaimer in the documentation 
% and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
% contributors may be used to endorse or promote products derived from this 
% software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ?AS IS?
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

uiwait(msgbox('In the next window, select the directory containing the .mat file ''S6.mat.'''))
inDir = uigetdir(pwd);
%%
cd(inDir)
load S6.mat

%%
%%%%% Analysis 1: Classification of single trials.
% X_3D is the electrodes x time x trial data matrix.
% categoryLabels is the vector of labels (6 categories)

% Call the classification function
[C] = classifyCrossValidate(X_3D, ...
    categoryLabels, 'randomSeed', 'default');

%%
% Convert the confusion matrix to an RDM
RDM = computeRDM(CM);
 

% Create the four visualizations
f1 = plotMatrix(RDM, 'colormap', 'summer', ...
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
[CM5, acc5, predY5, pVal5, classifierInfo5] = classifyCrossValidate(X_3D, ...
categoryLabels, 'averageTrials', 5, 'randomSeed', 'default');

%%
% Convert the confusion matrix to an RDM
RDM5 = computeRDM(CM5);

% Create the four visualizations
f5 = plotMatrix(RDM5, 'colormap', 'summer', ...
    'axisLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
     'axisColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
f6 = plotMDS(RDM5, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
f7 = plotDendrogram(RDM5, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
f8 = plotMST(RDM5, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
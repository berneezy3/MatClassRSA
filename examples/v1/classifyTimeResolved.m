% classifyTimeResolved.m
% -----------------------------
% Illustrative example for MatClassRSA toolbox. 
%
% This script loads a Matlab data file that has been downloaded from a 
% public EEG repository (https://purl.stanford.edu/bq914sc3730) and 
% performs category-level (6-class) classifications on the data in
% overlapping short time windows. The per-category and across-category
% accuracies over time are then plotted.

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
clear all; close all; clc
uiwait(msgbox('In the next window, select the directory containing the .mat file ''S6.mat.'''))
inDir = uigetdir(pwd);

cd(inDir)
load S10.mat
%%
winLenSamp = 6; % Temporal window length, in samples
winHopSamp = 3; % Temporal window hop size, in samples
[nSpace, nTime, nTrial] = size(X_3D); % Dimensions of input data matrix
nWins = floor((nTime - winLenSamp) / winHopSamp + 1); % # classifications

allCM = nan(6, 6, nWins); % 3D array to store confusion matrices
allCP = nan(6, 6, nWins); % 3D array to store scaled confusion matrices
allAcc = nan(nWins, 1); % Store accuracies
allWins = nan(nWins, winLenSamp);

% Classify the data in each time window
for i = 1:nWins
    disp([sprintf('\nTIME-RESOLVED CLASSIFICATION: WINDOW ') num2str(i) ' OF ' num2str(nWins)])
    
    % Current time samples to classify
    currSamp = (i-1)*winHopSamp + (1:winLenSamp);
    allWins(i,:) = currSamp; % Store in matrix for visualization later
    
    % Do the classification
    [currCM, allAcc(i), ~, ~, ~] = classifyEEG(...
        X_3D(:, currSamp, :), categoryLabels, 'randomSeed', 'default');
    
    % Create estimated conditional probability matrix (each row sums to 1)
    currCP = computeRDM(currCM, 'normalize', 'sum',...
        'symmetrize', 'none', 'distance', 'none', 'rankdistances', 'none');
    allCM(:, :, i) = currCM; allCP(:, :, i) = currCP; % Aggregate results
    clear curr*
    
end

%% Plot classification results 

% Create time axis out of window midpoints (msec)
windowMidptMsec = mean(allWins-1, 2) / Fs * 1000;


close all; figure(); hold on; box off; 
set(gca, 'fontsize', 16)
% Plot time-resolved accuracies for each category as percentages
for i = 1:6
   plot(windowMidptMsec, squeeze(allCP(i,i,:))*100, '*-', 'linewidth', 2)
end
% Plot time-resolved mean accuracy (across categories) as percentages
plot(windowMidptMsec, allAcc*100, '-*k', 'linewidth', 4)
grid on
legend({'HB', 'HF', 'AB', 'AF', 'FV', 'IO', 'Mean'}, 'location', 'northeast')
xlabel('Time (msec)'); ylabel('Classifier accuracy (%)')

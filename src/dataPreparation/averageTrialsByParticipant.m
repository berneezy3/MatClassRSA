function [xOut, yOut, pOut] = averageTrialsByParticipant(xIn, yIn, pIn, avgFactor, shuffleTrials)
% xOut = averageTrialsByParticipant(xIn, yIn, pIn, avgFactor, [shuffleTrials])
% ----------------------------------------------------------------------
% Blair - Feb 20, 2019
% This function takes in a matrix of data observations xIn, plus
% corresponding labels vector Y and participants vector P, and performs
% within-participant computation of pseudo-trials. Sets of avgFactor trials
% for a given stimulus are averaged. For now we assume always a 2D input
% data matrix.

if nargin < 5
    disp('Shuffle trials not specified; shuffling trials.')
    shuffleTrials = 1; 
end

if size(xIn,1) ~= length(yIn)
    disp('transposing xIn')
    xIn=xIn';
end

xOut = []; yOut = []; pOut = [];

nParticipants = length(unique(pIn));

if shuffleTrials
    rIdx = randperm(length(yIn));
    xIn = xIn(rIdx, :); yIn = yIn(rIdx); pIn = pIn(rIdx);
end

for i = 1:nParticipants
   disp(['Computing ' num2str(avgFactor) '-trial averages for participant ' num2str(i) ' of ' num2str(nParticipants) '.']) 
   tempIdx = find(pIn == i);
   tempXIn = xIn(tempIdx, :);
   tempYIn = yIn(tempIdx);
   [tempXOut, tempYOut] = averageTrials(tempXIn, tempYIn, avgFactor,...
       'handleRemainder', 'discard');
   xOut = [xOut; tempXOut]; 
   yOut = [yOut; tempYOut(:)];
   pOut = [pOut; i * ones(length(tempYOut), 1)];
   clear temp*
end


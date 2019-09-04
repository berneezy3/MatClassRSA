function [averagedX, averagedY, averagedP, whichObs] = averageTrials(X, Y, groupSize, varargin)
%-------------------------------------------------------------------
% [averagedX, averagedY, averagedP] = averageTrials(X, Y, groupSize, varargin)
%-------------------------------------------------------------------
% Bernard Wang - April 30, 2017
% Revised by Blair Kaneshiro - August 2019
%
% [averagedX, averagedY, averagedP] = averageTrials(X, Y, groupSize, varargin) 
% average trials for training data matrix X, labels vector Y, and,
% optionally, participants vector P. If the user wishes to shuffle the
% ordering of data prior to averaging (while preserving labeling of data
% observations), they should call the shuffleData function prior to calling
% this function.
%
% Required inputs:
%       X - training data matrix. Can be either a 2D (trial x feature) or
%           3D (space x time x trial) matrix.
%       Y - labels vector. Length should match the length of the trials
%           dimension of X.
%       groupSize - number of trials you wish each group to average
%
% Optional inputs: 
%       P - optional participants vector. Must be the same length as Y.
%           Can be numeric or a string array. If not entered or is empty, 
%           a vector of zeros (same size as Y) will be returned.
% 
% Optional name-value inputs: 
%       'handleRemainder' - method to handle remainder trials.
%           For example if you have 21 rows with label 1, and set averaging
%           group size to 5, you would have 4 groups (20/5), and 1 remainder
%           row with label 1. If not specified, defaults to 'discard'.
%           --- options ---
%               'discard'
%                   disregard the remaining data (default).
%               'newGroup'
%                   Creates a new averaged row with the remainder trials,
%                   despite the rows not fulfilling the group size.
%               'append'
%                   Appends the remaining data to the last averaged row of
%                   the same label.
%               'distribute'
%                   Distributes the remaining data to the different groups
%                   of the same label.
%       'endShuffle' - whether to shuffle the data after averaging. This
%           shuffling process preserves the mapping of data to
%           corresponding labels and participants. This step is recommended 
%           as the main function loops through participants (if input) and 
%           stimulus labels during computation of averages, so this step
%           redistributes observations from each stimulus category (e.g.,
%           as input to cross-validated classification). If not specified,
%           defaults to 1.
%           --- options ---
%               0, 'false': Do not perform end shuffling
%               1, 'true': Perform end shuffling (default)
%       'rngType' - specify random number generator (rng) if end shuffling
%           is being performed. If not entered, rng will be assigned as
%           ('shuffle', 'twister').
%           --- options ---
%               Single acceptable rng specification input (e.g., 1, 
%                   'default', 'shuffle'); in these cases, the generator 
%                   will be set to 'twister'.
%               Dual-argument specifications as either a 2-element cell 
%                   array (e.g., {'shuffle', 'twister'}) or string array 
%                   (e.g., ["shuffle", "twister"].
%               rng struct as assigned by r = rng.
%
% Output Args:
%       averagedX - the data matrix after trial averaging. Will match the
%           shape (2D or 3D) of the input data matrix.
%       averagedY - the label vector for the trials in averagedX.
%       averagedP - the participants vector corresponding to trials in
%           averagedY.
%       whichObs - a matrix that contains information on which trials in
%       the input matrix X were used to create trial in
%       averagedX.  The size of whichObs should be length(averagedY) by
%       groupSize.
%
% Example:
%

% This software is licensed under the 3-Clause BSD License (New BSD License),
% as follows:
% -------------------------------------------------------------------------
% Copyright 2019 Bernard C. Wang, Nathan C. L. Kong, Anthony M. Norcia, 
% and Blair Kaneshiro
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parse inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ip = inputParser;
ip.FunctionName = 'averageTrials';
ip.addRequired('X', @isnumeric);
ip.addRequired('Y', @isvector);

%parse group size
checkInt = @(x) (rem(x,1)==0);
ip.addRequired('groupSize', checkInt);

%parse optional participants vector
defaultP = zeros(size(Y));
addOptional(ip, 'P', defaultP);

% parse optional inputs
defaultHandleRemainder = 'discard';
validHandleRemainder = {'discard','newGroup', 'append', 'distribute'};
checkHandleRemainder = @(x) any(validatestring(x, validHandleRemainder));
defaultEndShuffle = 1;
defaultRngType = {'shuffle', 'twister'}; 
if verLessThan('matlab', '8.2')
    addParamValue(ip, 'handleRemainder', defaultHandleRemainder, checkHandleRemainder);
    addParamValue(ip, 'endShuffle', defaultEndShuffle);
    addParamValue(ip, 'rngType', defaultRngType);
else
    addParameter(ip, 'handleRemainder', defaultHandleRemainder, checkHandleRemainder);
    addParameter(ip, 'endShuffle', defaultEndShuffle);
    addParameter(ip, 'rngType', defaultRngType);
end

parse(ip, X, Y, groupSize, varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end parse inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assign P based on input parser or convert to zeros if empty input
if isempty(ip.Results.P), P = zeros(size(Y));
else, P = ip.Results.P;
end

% THROW ERROR if length of P does not equal length of Y
assert(length(P) == length(Y), ...
    'Length of participants vector must equal length of labels vector.');

% THROW ERROR if X has more than 3 dimensions.
if length(size(X)) > 3
    error('Input data matrix may have no more than 3 dimensions.')
% If X is entered in 3D form, flag it and convert to 2D.
elseif length(size(X)) == 3
    xTransform = 1;
    [~,trialTime,~] = size(X);
    X = cube2trRows(X);
else
    xTransform = 0;
end

% THROW ERROR if number of trials (X height) does not equal  number of
% labels (Y length)
[r, c] = size(X);
numTrials = length(Y);
assert(r == numTrials, ['number of trials in X does not equal ' ...
    'number of labels in Y'] );

% Initialize return parameters averagedX, averagedY
averagedX = [];
averagedY = [];
averagedP = [];

% Move input vars into new var names so that we can add participant looping
% with old var names.
XALL = X;
YALL = Y;
PALL = P;
whichObs = {};
clear X Y P

% Get participant information
uP = sort(unique(PALL));
nP = length(uP);

for pp = 1:nP % Iterate through the participants
    % Print message of which participant we are processing
    thisParticip = uP(pp);
    if any(PALL~=0)
        disp(['Computing ' num2str(groupSize) '-trial averages for participant ' ...
            num2str(thisParticip) ' (' num2str(pp) ' of ' num2str(nP) ').'])
    end
    
    % Subset data from that participant
    thisIdx = find(PALL == thisParticip);
    X = (XALL(thisIdx,:));
    Y = YALL(thisIdx);
    
    % the original data set with data from other participants set as zero,
    % to preserve original data indexing
    notThisInd = find(PALL ~= thisParticip);
    Xalt = XALL;
    Xalt(notThisInd, :) = 0;
    Yalt = YALL;
    Yalt(notThisInd) = 0;
    
    % create dictionary to store labels and their corresponding counts
    uniqueLabels = unique(Y);
    labelCounts = containers.Map();
    for i = 1:length(uniqueLabels)
        labelCounts(num2str(uniqueLabels(i))) = nnz(Y==uniqueLabels(i));
    end
    k = keys(labelCounts) ;
    val = cell2mat(values(labelCounts));
    
    % THROW ERROR if group size is greater than number of trials for that
    % label
    for i=1:length(k)
        assert(nnz(Y==str2num(k{i})) >= groupSize, ...
            'Label %s has fewer trials than specified group size.', k{i});
    end
    
    % create dictionary to store labels and their corresponding number of
    % groups
    labelNumGroups = containers.Map(k, floor(val/groupSize));
    
    % create dictionary to store labels and their corresponding number of
    % remainders
    labelNumRemains = containers.Map(k, rem(val, groupSize));
    
    
    % store the indecies of current label
    tempInd = [];
    averagedRow = NaN(1,c);
    summedRow = NaN(1,c);
    for i = 1:length(uniqueLabels)
        %refresh temp index vector
        tempInd = [];
        tempInd = find(Yalt==uniqueLabels(i));
        % iterate on each group with the same label
        for j=1:labelNumGroups(num2str(uniqueLabels(i)))
            % iterate on each index within a group of the same label
            summedRow = zeros(1,c);
            thisAvgObs = zeros(1, groupSize);
            for k=1:groupSize
                summedRow = summedRow + Xalt(tempInd(k + (j-1)*groupSize), :);
                thisAvgObs(k) = tempInd(k + (j-1)*groupSize);
            end
            averagedRow = summedRow/groupSize;
%             whichObs = [whichObs; thisAvgObs];
            whichObs{end + 1} =thisAvgObs ;
            averagedX = [averagedX ; averagedRow];
            averagedY = [averagedY; uniqueLabels(i)];
            averagedP = [averagedP; thisParticip];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Handle remainders
        % iterate from the first element that is not contained in a group
        % to the last element
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (labelNumRemains(num2str(uniqueLabels(i))) > 0)
            
            remInd = find(Y==uniqueLabels(i), ...
                labelNumRemains(num2str(uniqueLabels(i))),...
                'last');
            
            
            
            % Initialize return parameters remX, remY
            remX = [];
            remY = [];
            remSummedRow = zeros(1,c);
            remAveragedRow = zeros(1,c);
            remTempRow = zeros(1,c);
            remY = uniqueLabels(i);
            
            for j=1:labelNumRemains(num2str(uniqueLabels(i)))
                % CASE: DISCARD REMAINDERS (DO NOTHING)
                if (strcmp(ip.Results.handleRemainder, 'discard'))
                    ;
                    
                    % CASE: CREATE NEW GROUP W/ REMAINDER
                elseif (strcmp(ip.Results.handleRemainder, 'newGroup'))
                    % sum remainder rows with the same label
                    for k = 1:length(remInd)
                        remSummedRow = remSummedRow + X(remInd(k), :);
                    end
                    % create a new group for them
                    remAveragedRow = remSummedRow/length(remInd);
                    averagedX = [averagedX; remAveragedRow];
                    averagedY = [averagedY; uniqueLabels(i)];
                    averagedP = [averagedP; thisParticip];
                    
                    whichObs{end + 1} = remInd;

                    
                    % CASE: APPEND TO LAST GROUP W/ REMAINDER
                elseif (strcmp(ip.Results.handleRemainder, 'append'))
                    % sum remainder rows with the same label
                    for k = 1:length(remInd)
                        remSummedRow = remSummedRow + X(remInd(k), :);
                    end
                    % remove the last row, so we can re-add it with the
                    % remainder values in the calculation
                    averagedX = averagedX(1:end-1,:);
                    
                    % append them to the last group with same label
                    remSummedRow = summedRow * groupSize + ...
                        remSummedRow * labelNumRemains(num2str(uniqueLabels(i)));
                    remAveragedRow = remSummedRow/(groupSize + ...
                        labelNumRemains(num2str(uniqueLabels(i))));
                    averagedX = [averagedX; remAveragedRow];
                    whichObs{end} = [whichObs{end} remInd];
                    
                    % CASE: DISTRIBUTE REMAINDER TO GROUPS W/ SAME LABEL
                elseif (strcmp(ip.Results.handleRemainder, 'distribute'))
                    % append each remainder row to a separate averaged row and
                    % divide
                    averagedInd = find(averagedY==uniqueLabels(i));
                    
                    for k = 1:length(remInd)
                        remTempRow = X(remInd(k), :) + averagedX(averagedInd(k),:) * groupSize;
                        X(averagedInd(k), :) = remTempRow/(groupSize+1);
                        whichObs{averagedInd(k)} = [whichObs{end} remInd(k)]
                    end
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % End Handle remainders
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    clear this* X Y k val
end

% Shuffle all the data if requested
if ip.Results.endShuffle
    disp('averageTrials: Shuffling order of averaged data.')
    %%%% Set the random number generator %%%%
    thisRng = ip.Results.rngType;
    setUserSpecifiedRng(thisRng);
    %%%% End set random number generator %%%%
    
    % Do the randomization
    randIdx = randperm(length(averagedY));
    averagedX = averagedX(randIdx,:);
    averagedY = averagedY(randIdx);
    averagedP = averagedP(randIdx);
end

% If the input data was 3D to begin with, convert it back to 3D
if xTransform
    averagedX = trRows2cube(averagedX, trialTime);
end
end

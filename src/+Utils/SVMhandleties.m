function [winnerIndex, tallies, tieFlag] = SVMhandleties(dec_vals, labels)
%-------------------------------------------------------------------
% [winnerIndex, tallies, tieFlag] = SVMhandleties(dec_vals, labels)
% --------------------------------
%
% This function is an auxiliary function to libSVM to handle ties.
% libSVM's multiclass classification is implemented using one-to-one
% classification.  However, in the event that a trial's most classified
% class is tied by two or more different classes, this function is used to break 
% the tie.  This function is important because otherwise, during a
% multiclass tie, libSVM would default to the first class amongst the ties,
% inducing a bias in classification.
% 
% INPUT ARGS:
%   - dec_vals: decision values from libSVM
%   - labels: the labels vector from libSVM
%
% OUTPUT ARGS:
%   - winnerIndex: index of the winning label
%   - tallies: number of votes
%   - tieFlag: flag indicating if tie was detected.  This is debugging output

% This software is released under the MIT License, as follows:
%
% Copyright (c) 2025 Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, 
% Feng Ruan, Anthony M. Norcia, and Blair Kaneshiro.
% 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to 
% permit persons to whom the Software is furnished to do so, subject to 
% the following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    if length(dec_vals) ~= length(labels) * (length(labels) -1) /2
        error('Number of decision values must equal nLabels * (nLabels-1) /2');
    end

    tallies = zeros(1, length(labels));
    tieFlag = 0;

    for i = 1:length(dec_vals)
        firstInd = i;
        % get the first index
        for j = (length(labels)-1):-1:1
            if (firstInd - j <= 0)
                secondInd = length(labels) + firstInd - j;
                firstInd = length(labels)-j; 
                break;
            else
                firstInd = firstInd -j;
            end
        end
        
        % add tallies
        if dec_vals(i) > 0
           tallies(firstInd) =  tallies(firstInd) + 1;
        elseif dec_vals(i) < 0
           tallies(secondInd) =  tallies(secondInd) + 1;
        else % equal distance!!!!!!
            if rand(1) > .5
                tallies(firstInd) =  tallies(firstInd) + 1;
            else
                tallies(secondInd) =  tallies(secondInd) + 1;
            end
        end
        
        %disp(['i: ' num2str(i) ', 1st val: ' num2str(firstInd)  ', 2nd val: ' num2str(secondInd)]);
       
         
    end
    
    %return class index of highest tallies
    winnerIndex = find(tallies == max(tallies));    
    
    % if there is a tie, we randomly select the class
    if length(winnerIndex) > 1
        tieFlag = 1;
        %disp(['Ties between classes: ' num2str(labels([winnerIndex])) '.  Randomizing winner']);
        randIdx=randperm(length(winnerIndex),1);
        winnerIndex = winnerIndex(randIdx);
    end
    

end

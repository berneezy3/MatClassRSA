function [winnerIndex, tallies, tieFlag] = SVMhandleties(dec_vals, labels)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% [winnerIndex, tallies, tieFlag] = SVMhandleties(dec_vals, labels)
% --------------------------------
% Bernard Wang, Sept 28, 2019
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
%
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

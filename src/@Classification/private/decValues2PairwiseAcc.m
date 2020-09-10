function [pairwiseAccuracies, pairwiseCMs, pairwiseCell] = decValues2PairwiseAcc(pairwiseCMs, testY, labels, decVals, pairwiseCell )
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% [pairwiseAccuracies, pairwiseCMs, pairwiseCell] = ...
%   decValues2PairwiseAcc(pairwiseCMs, testY, labels, decVals, pairwiseCell )
% --------------------------------
% Bernard Wang, Sept 28, 2019
%
% When conducting pairwise classification using libSVM, this function is
% used to convert the decision values output from libSVM to
% pairwise accuracies.  
% 
% INPUT ARGS:
%   - pairwiseCMs: a 2 x 2 x (N choose 2) matrix to store the pairwise CMs 
%   - testY: labels vector Y
%   - labels: labels vector from svm_predict()
%   - decVals: decision values matrix from svm_predict()
%   - pairwiseCell: from initPairwiseCellMat(numClasses)
%
% OUTPUT ARGS:
%   - pairwiseAccuracies: accuracies of pairwise CV
%   - pairwiseCMs: updated pairwiseCMs
%   - pairwiseCell: updated pairwiseCell
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

    numDecBounds = nchoosek(length(labels) ,2);
    [firstInds, secondInds] = getNChoose2Ind(length(labels));
    for j = 1:length(testY) % loop through all test observations
        % get actual label of observation
        actualLabel = testY(j);
        thisDecVals = decVals(j, :);
        for k = 1:numDecBounds
            % first and second Label are the labels that the
            % current decision boundary splits between
            firstLabel = labels(firstInds(k));
            secondLabel = labels(secondInds(k));
            if (firstLabel == actualLabel || ...
                secondLabel == actualLabel)
                % now check which box in the 2-by-2 conf mat to add tally to.
                thisBoundClasses = sort([firstLabel, secondLabel]);
                tallyCoordX = find(thisBoundClasses == actualLabel);

                if thisDecVals(k) > 0
                    predictedLabel = firstLabel;
                elseif thisDecVals(k) <= 0
                    predictedLabel = secondLabel;
                end
                tallyCoordY = find(thisBoundClasses == predictedLabel);


                % convert 2 class Ind to n choose 2 index
                tallyCoordZ = classTuple2Nchoose2Ind(thisBoundClasses, length(labels));
                this2x2cm = pairwiseCell{thisBoundClasses(1), thisBoundClasses(2)}.CM;
                this2x2cm(tallyCoordX, tallyCoordY) =  this2x2cm(tallyCoordX, tallyCoordY) + 1;
                thisAcc = (this2x2cm(1,1) + this2x2cm(2,2)) / sum(sum(this2x2cm));
                pairwiseCell{thisBoundClasses(1), thisBoundClasses(2)}.CM = this2x2cm;
                pairwiseCell{thisBoundClasses(1), thisBoundClasses(2)}.accuracy = thisAcc;
                                
                % increment
                pairwiseCMs(tallyCoordX, tallyCoordY, tallyCoordZ) = ...
                     pairwiseCMs(tallyCoordX, tallyCoordY, tallyCoordZ) + 1;

            end

        end
    end
    
    
    [d1 d2 d3] = size(pairwiseCMs);
    [r c] = size(pairwiseCell);
    AM = NaN(r,c);
    denom = 0;
    numer = 0;
    indPairs = nchoosek([1 2 3 4 5 6],2);
    tempCM = [];
    for i = 1:d3
        ind = indPairs(i, :);
        tempCM = pairwiseCell{ind(1), ind(2)}.CM;
        numer = tempCM(1,1) + tempCM(2,2);
        denom = sum(sum(tempCM));
        AM(ind(1), ind(2)) = numer / denom;
        AM(ind(2), ind(1)) = numer / denom;
    end
    
    pairwiseAccuracies = AM;
    
end
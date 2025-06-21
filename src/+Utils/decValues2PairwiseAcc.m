function [pairwiseAccuracies, pairwiseCMs, pairwiseCell] = decValues2PairwiseAcc(pairwiseCMs, testY, labels, decVals, pairwiseCell )
%-------------------------------------------------------------------
% [pairwiseAccuracies, pairwiseCMs, pairwiseCell] = ...
%   decValues2PairwiseAcc(pairwiseCMs, testY, labels, decVals, pairwiseCell )
% ------------------------------------------------------------------
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
%                 pairwiseCell{thisBoundClasses(1), thisBoundClasses(2)}.actualLables = ;
                                
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
    indPairs = nchoosek(1:length(labels), 2);
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
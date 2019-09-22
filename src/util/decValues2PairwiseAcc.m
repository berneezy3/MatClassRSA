function [pairwiseAccuracies, pairwiseCMs, pairwiseCell] = decValues2PairwiseAcc(pairwiseCMs, testY, labels, decVals, pairwiseCell )

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
                pairwiseCell{thisBoundClasses(2), thisBoundClasses(1)}.CM = this2x2cm;
                pairwiseCell{thisBoundClasses(2), thisBoundClasses(1)}.accuracy = thisAcc;
                                
                % increment
                pairwiseCMs(tallyCoordX, tallyCoordY, tallyCoordZ) = ...
                     pairwiseCMs(tallyCoordX, tallyCoordY, tallyCoordZ) + 1;
                
%                 disp('%%')
%                 disp(['current actual Label: ' num2str(actualLabel)]);
%                 disp(['current predicted Label: ' num2str(predictedLabel())]);
%                 disp(['current classifier splits classes: ' num2str(thisBoundClasses)]);
%                 disp(['decision boundary loop k: ' num2str(k)]);
%                 disp(['index of the 2-by-2 pairwise mat dervied from dec boundary: ' num2str(tallyCoordZ)]);
%                 disp(['2-by-2 pairwise mat after increment: ' ]);
%                 disp(num2str(pairwiseCMs(:,:, tallyCoordZ)));

            end

        end
%                 disp('%%%%%%%%%%%%%%%%%%%%%%%%')
%                 disp('End decision boundary analysis for current observation.  There should have been 5 analyses for current obs')
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